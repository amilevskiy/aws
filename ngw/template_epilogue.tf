#https://www.terraform.io/docs/providers/template/d/file.html
data "template_file" "epilogue" {
  ###############################
  count = local.enable

  #"hostname=\"${lower(var.jump["name"])}-${lower(var.env)}$($$${SED} -rn 's,^[[:space:]]*search[[:space:]]+([-[:alnum:].]+).*,.\1,p' /etc/resolv.conf)\""\

  template = <<-TEMPLATE
#	nohup nice -n32 /usr/local/sbin/pkg delete --yes --glob autoconf bison cmake cunit ec2-scripts freetype2 gettext-tools gmake groff gsfonts help2man libatomic_ops libmetalink libpthread-stubs libtool meson pkgconf rsync ruby svnup tcl86 texinfo xmlto docbook-xsl getopt jsoncpp libltdl libtextstyle libunwind libuv libxslt ninja psutils rhash uchardet w3m xxhash boehm-gc docbook libgcrypt libpaper libxml2 autoconf-wrapper docbook-sgml docbook-xml libgpg-error m4 sdocbook-xml >/var/log/pkg.log 2>&1 &

	#вот хер он читается в это время!.. old=$(sysrc -n -f /etc/rc.conf ifconfig_DEFAULT 2>/dev/null)
	for i in $(ifconfig -l ether); do
		ifconfig -v "$$${i}" -lro
		sysrc -v -f /etc/rc.conf.local ifconfig_$$${i}='SYNCDHCP -lro'
	done

	kldload -v ipfw_nat

	#'net.inet.ip.fw.default_to_accept="1"'
	am_sysrc /boot/loader.conf 'ipfw_nat_load="YES"'

	am_sysrc /etc/sysctl.conf	\
		'net.inet.tcp.tso=0'			\
		'net.inet.ip.fw.dyn_max=32768'		\
		'net.inet.ip.fw.dyn_udp_lifetime=60'	\
		'net.inet.ip.fw.dyn_syn_lifetime=30'	\
		'net.inet.ip.fw.dyn_short_lifetime=60'	\
		'net.inet.ip.fw.dyn_fin_lifetime=4'	\
		'net.inet.ip.fw.dyn_rst_lifetime=4'

	am_sysrc /etc/rc.conf	\
		"hostname=\"jump-${lower(var.env)}$($$${SED} -rn 's,^[[:space:]]*search[[:space:]]+([-[:alnum:].]+).*,.\1,p' /etc/resolv.conf)\"" \
		'gateway_enable="YES"'		\
		'firewall_enable="YES"'		\
		'blacklistd_enable="YES"'	\
		'blacklistd_flags="-r"'		\
		'ntpd_sync_on_start="YES"'	\
		'ntpd_enable="YES"'

	sysrc -v sshd_flags+=' -oUseBlacklist=yes'

	echo "ipfw_offset='11000'" >/etc/ipfw-blacklist.rc

	test -z '${var.dns_zone_name != "" ? 1 : ""}' || am_sysrc /etc/rc.conf.d/route53	\
		'route53_enable="YES"'	\
		'route53_host_name="jump-${lower(var.env)}"'	\
		'route53_domain_name=${var.dns_zone_name}'

	am_sysrc /etc/rc.conf.d/amazon_ssm_agent amazon_ssm_agent_enable="YES"

	service sysctl start
	service hostname start
	service syslogd reload
	service routing start
	service ipfw start
	service blacklistd start
	service sshd restart
	service ntpd start
	service route53 start
	#service amazon-ssm-agent start

	for i in $($$${GET}/meta-data/network/interfaces/macs); do
		test -n "$$${VPC_ID}" || VPC_ID=$($$${GET}/meta-data/network/interfaces/macs/$$${i}vpc-id)
		test -n "$$${SUBNET_ID}" || SUBNET_ID=$($$${GET}/meta-data/network/interfaces/macs/$$${i}subnet-id)
		ENI=$($$${GET}/meta-data/network/interfaces/macs/$$${i}interface-id) &&
			$$${AWS} ec2 modify-network-interface-attribute --network-interface-id $$${ENI} --no-source-dest-check &&
			echo "$$${ENI}: source-destination check disabled"
	done

	#1. Получаем id [нашей] route_table, которую модифицировать не будем
	MY_RTB_ID=$($$${AWS} ec2 describe-route-tables	\
			--filters "Name=vpc-id,Values=$$${VPC_ID}" "Name=association.subnet-id,Values=$$${SUBNET_ID}"	\
			--query 'RouteTables[].RouteTableId')
	test -n "$$${MY_RTB_ID}" || MY_RTB_ID=$($$${AWS} ec2 describe-route-tables	\
			--filters "Name=vpc-id,Values=$$${VPC_ID}" "Name=association.main,Values=true"	\
			--query 'RouteTables[].RouteTableId')
	echo "my_route_table_id: $$${MY_RTB_ID}"

	# Возможно здесь нужно покурить тему, что выбирать все rtb в данной vpc.
	# Только исключить свою и, наверное, те, у которых нет маршрута 0/0
	if [ -n "$$${MY_RTB_ID}" ]; then
		#2. Получаем список id всех subnet в нашей Availability Zone (в нашей VPC)
		set -- $($$${AWS} ec2 describe-subnets		\
			--filters "Name=vpc-id,Values=$$${VPC_ID}" "Name=availabilityZone,Values=$$${AZ}"		\
			--query 'Subnets[].SubnetId')
		echo "subnet_ids: $$${@}"

		#3. По каждой subnet получаем её route_table
		for i in $$${@}; do
			test "$$${i}" != "$$${SUBNET_ID}" || continue
			rtb_id=$($$${AWS} ec2 describe-route-tables	\
				--filters "Name=vpc-id,Values=$$${VPC_ID}" "Name=association.subnet-id,Values=$$${i}"	\
				--query 'RouteTables[].RouteTableId')
			test -n "$$${rtb_id}" || continue
			#4. Добавляем в список [только ту] route_table, которая "не наша" и которой в списке ещё нет
			test "$$${rtb_id}" != "$$${MY_RTB_ID}" || continue
			test "$$${RTB_IDS%%$$${rtb_id}*}" = "$$${RTB_IDS}" && RTB_IDS="$$${RTB_IDS}$$${rtb_id} "
		done

		CIDR='0.0.0.0/0'
		for i in $$${RTB_IDS}; do
			$$${AWS} ec2 delete-route --route-table-id $$${i} --destination-cidr-block $$${CIDR} 2>/dev/null &&
				echo "$$${i}: delete $$${CIDR}"

			$$${AWS} ec2 create-route --route-table-id $$${i} --destination-cidr-block $$${CIDR} --instance-id $$${ID} >/dev/null &&
				echo "$$${i}: add $$${CIDR} $$${ID}"
		done
	fi

	TEMPLATE
}
