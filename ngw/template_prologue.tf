#
# ПРОЛОГ.
#
# Который делает следующее:
# 0. shebang (#!/bin/sh)
# 1. Устанавливает system timezone в Europe/Kiev (/etc/localtime).
# 2. В соответствии с типом OS устанавливает переменные:
#    * GET - префикс URL для доступа к метаданным инстанса в AWS
#    * PW - префикс при запуске useradd, groupadd.
#      Может использоваться для быстрого определения FreeBSD: [ -n "${PW}" ]
#    * AWS - префикс для запуска AWS CLI
#    * AZ - Availability Zone
# 3. Инициализирует пользователей OS из файла local.admins_file (user:uid:ssh_key)
#
#0.11 >> 0.12
# %{ > %%{
# $$$$( $$(
#
#https://www.terraform.io/docs/providers/template/d/file
data "template_file" "prologue" {
  ###############################
  count = local.enable

  vars = {
    # url_exec = "https://fuib-devops.s3.eu-central-1.amazonaws.com/1stboot.d/01.sh"
    url_exec = ""
  }

  template = <<-TEMPLATE
#!/bin/sh
	cp -afv /usr/share/zoneinfo/Europe/Kiev /etc/localtime

	# 6 переменных определены [прежде всего] для того,
	# чтобы сформировать правильное содержание alias
	if [ "_$(uname -s)" = _FreeBSD ]; then
		GET='/usr/bin/fetch --quiet --output=- --timeout=5 http://169.254.169.254/latest'
		SHRC='.shrc'
		AWS='/usr/local/bin/aws'
		SED='/usr/bin/sed'
		LESS='/usr/bin/less'
		#
		PW='/usr/sbin/pw'
#		$$${SED} -ri '' -e '$a\
#nameserver 8.8.8.8
#' -e '/^[[:space:]]*nameserver/d' /etc/resolv.conf
	else
		GET='curl --silent --connect-timeout 5 http://169.254.169.254/latest'
		SHRC='/etc/profile.d/aws.sh'
		AWS='aws'
		SED='sed'
		LESS='less'
		CHK_PREFIX="test \$($$${GET}/meta-data/public-ipv4 -o /dev/null -w %%%{http_code}) -eq 200 2>/dev/null && "
		#
		mkdir -p -m 755 "$$${SHRC%/*}" /etc/modprobe.d
		echo 'install dccp /bin/true' >/etc/modprobe.d/disable-dccp.conf
	fi

	AZ=$($$${GET}/meta-data/placement/availability-zone)
	AWS="$$${AWS}$$${AZ:+ --region $$${AZ%?}} --output text"

	BODY="
	alias aws_log='$$${LESS} -S /var/log/cloud-init-output.log'
	alias aws_user_data='$$${GET}/user-data | $$${LESS} -S'
	alias aws_id='for i in \$($$${GET}/meta-data/network/interfaces/macs/); do \
	for ii in \$($$${GET}/meta-data/network/interfaces/macs/\$$${i}vpc-id) \
		\$($$${GET}/meta-data/instance-type) \
		\$($$${GET}/meta-data/instance-id); do \
	echo -n \"\$$${ii} \"; done; echo; break; done'
	alias aws_ip='for i in \$($$${GET}/meta-data/network/interfaces/macs/); do \
	for ii in \$($$${GET}/meta-data/network/interfaces/macs/\$$${i}device-number) \
		\$($$${GET}/meta-data/network/interfaces/macs/\$$${i}interface-id) \
		\$($$${GET}/meta-data/network/interfaces/macs/\$$${i}subnet-id) \
		\$($$${GET}/meta-data/network/interfaces/macs/\$$${i}local-ipv4s)\$($$${GET}/meta-data/network/interfaces/macs/\$$${i}subnet-ipv4-cidr-block | $$${SED} -rn 's/[0-9.]+//p') \
		\$($$${CHK_PREFIX}$$${GET}/meta-data/network/interfaces/macs/\$$${i}public-ipv4s 2>/dev/null); do \
	echo -n \"\$$${ii} \"; done; echo; done'"

	LIST='${chomp(file(var.admins_file))}'
	for s in $$${LIST}; do
		IFS=:
		set -- $$${s%%#*}
		user="$$${1}"; uid="$$${2}"; key="$$${3}"
		unset IFS

		test -n "$$${user}" -a -n "$$${uid}" || continue

		$$${PW} groupadd "$$${user}" -g "$$${uid}"
		$$${PW} useradd "$$${user}" -m -u "$$${uid}" -g "$$${uid}" -G 0

		if [ -n "$$${PW}" ]; then
			grep -q "^[[:space:]]*$$${user}[[:space:]]" /usr/local/etc/sudoers 2>/dev/null ||
				echo "$$${user} ALL=(ALL) NOPASSWD: ALL" >>/usr/local/etc/sudoers
		else
			mkdir -p -m 755 /etc/sudoers.d
			echo "$$${user} ALL=(ALL) NOPASSWD: ALL" >"/etc/sudoers.d/$$${user}"
		fi

		home=$(getent passwd "$$${user}" | cut -d: -f6)
		test -n "$$${key}" -a -n "$$${home}" || continue

		mkdir -p -m 700 "$$${home}/.ssh"
		echo "ssh-rsa $$${key} $$${user}" >"$$${home}/.ssh/authorized_keys"
		chmod 600 "$$${home}/.ssh/authorized_keys"
		chown -R "$$${user}:$$${user}" "$$${home}/.ssh"

		test -z "$$${PW}" || echo "$$${BODY}" | while read s; do
			set -- $$${s}
			test -n "$$${*}" || continue
			grep -Eq "^[[:space:]]*$$${1}[[:space:]]+$$${2%%=*}=" "$$${home}/$$${SHRC}" 2>/dev/null ||
				echo "$$${@}" >>"$$${home}/$$${SHRC}"
		done
		rm -f -- "$$${home}/.bash_logout"
	done

	test -n "$$${PW}" || echo "$$${BODY}" | while read s; do
		set -- $$${s}
		test -n "$$${*}" || continue
		echo "$$${@}" >>"$$${SHRC}"
	done

	unset BODY LIST SHRC CHK_PREFIX LESS



	ID=$($$${GET}/meta-data/instance-id)
	TYPE=$($$${GET}/meta-data/instance-type)

	am_sysrc() {
		test -n "$$${PW}" || return 0
		local i file="$$${1}"
		shift
		for i in $$${@}; do
			local k=$(echo $$${i%%=*} | $$${SED} 's,\.,\\.,g')
			$$${SED} -ri '' -e "s,^[[:space:]#]*$$${k}.*,$$${i}," "$$${file}"
			if ! grep -q "^$$${k}" "$$${file}"; then
				test -s "$$${file}" && echo >>"$$${file}"
				echo "$$${i}" >>"$$${file}"
			fi
			echo "$$${file}: $$${i}" >&2
		done
	}

	disable_modules() {
		test -n "$$${PW}" || return 0
		local m
		for m in $$${@}; do
			kldunload -v "$$${m}"
			sysrc -v -f /boot/loader.conf -x "$$${m}_load"
		done
	}

	case "$$${TYPE}" in
		t[23].*|t3a.*)
			if $$${AWS} ec2 modify-instance-credit-specification --instance-credit-specification "InstanceId=$$${ID},CpuCredits=standard" >/dev/null; then
				echo "$$${ID}: standard CPU credits SET"
			else
				echo "$$${ID}: standard CPU credits set FAILED!"
			fi

			if [ "$$${TYPE}" = "$$${TYPE#t2.}" ]; then
				$(/sbin/sysctl -n kern.ipc.nmbjumbo16) -lt 6144 2>/dev/null &&
					am_sysrc /etc/sysctl.conf 'kern.ipc.nmbjumbo16="6144"' #t3
			else
				disable_modules if_ena nvd nvme	#t2
			fi

			disable_modules if_ixv ;;

		[cmr]4.*)
			disable_modules if_ena nvd nvme ;;

		[cmr]5*.*)
			$(/sbin/sysctl -n kern.ipc.nmbjumbo16) -lt 6144 2>/dev/null &&
				am_sysrc /etc/sysctl.conf 'kern.ipc.nmbjumbo16="6144"'

			disable_modules if_ixv ;;
	esac

	#am_sysrc /etc/rc.conf.d/iperf_tcp 'iperf_tcp_enable="YES"'
	#service iperf-tcp start
	#am_sysrc /etc/rc.conf.d/iperf_udp 'iperf_udp_enable="YES"'
	#service iperf-udp start
	#am_sysrc /etc/rc.conf.d/iperf3 'iperf3_enable="YES"'
	#service iperf3 start

	#if [ -n '$${url_exec}' ]; then
	#	F_TMP=$(mktemp -q "/tmp/$$${$}.XXXXXX")
	#	/usr/bin/fetch --quiet --output=- --timeout=5 "$$${F_TMP:=/tmp/$$${$}}" '$${url_exec}' && test -s "$$${F_TMP}" && . "$$${F_TMP}"
	#	rm -f -- "$$${F_TMP}"
	#fi
	TEMPLATE
}
