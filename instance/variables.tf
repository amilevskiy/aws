variable "env" {
  type        = string
  description = "The prefix for all environments [e.g. IPUMB, CORE, etc.] (required)."
}

variable "name" {
  default     = ""
  description = "(Optional) The component of tag-name"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "(Optional) A mapping of tags which should be assigned to all module resources"
}


variable "enable" {
  default     = false
  description = "Destroy all module resources if false (optional)."
}

variable "ec2_price" {
  type = map(number)
  default = {
    "c3.large"   = 0.129
    "c3.xlarge"  = 0.258
    "c3.2xlarge" = 0.516
    "c3.4xlarge" = 1.032
    "c3.8xlarge" = 2.064

    "c4.large"   = 0.114
    "c4.xlarge"  = 0.227
    "c4.2xlarge" = 0.454
    "c4.4xlarge" = 0.909
    "c4.8xlarge" = 1.817

    "c5.large"    = 0.097
    "c5.xlarge"   = 0.194
    "c5.2xlarge"  = 0.388
    "c5.4xlarge"  = 0.776
    "c5.9xlarge"  = 1.746
    "c5.18xlarge" = 3.492

    "c5d.large"    = 0.111
    "c5d.xlarge"   = 0.222
    "c5d.2xlarge"  = 0.444
    "c5d.4xlarge"  = 0.888
    "c5d.9xlarge"  = 1.998
    "c5d.18xlarge" = 3.996

    "c5n.large"    = 0.123
    "c5n.xlarge"   = 0.246
    "c5n.2xlarge"  = 0.492
    "c5n.4xlarge"  = 0.984
    "c5n.9xlarge"  = 2.214
    "c5n.18xlarge" = 4.428

    "d2.xlarge"  = 0.794
    "d2.2xlarge" = 1.588
    "d2.4xlarge" = 3.176
    "d2.8xlarge" = 6.352

    "g2.2xlarge" = 0.772
    "g2.8xlarge" = 3.088

    "g3.4xlarge"  = 1.425
    "g3.8xlarge"  = 2.85
    "g3.16xlarge" = 5.7

    "g3s.xlarge" = 0.938

    "i2.xlarge"  = 1.013
    "i2.2xlarge" = 2.026
    "i2.4xlarge" = 4.051
    "i2.8xlarge" = 8.102

    "i3.large"    = 0.186
    "i3.xlarge"   = 0.372
    "i3.2xlarge"  = 0.744
    "i3.4xlarge"  = 1.488
    "i3.8xlarge"  = 2.976
    "i3.16xlarge" = 5.952
    "i3.metal"    = 5.952

    "i3en.large"    = 0.27
    "i3en.xlarge"   = 0.54
    "i3en.2xlarge"  = 1.08
    "i3en.3xlarge"  = 1.62
    "i3en.6xlarge"  = 3.24
    "i3en.12xlarge" = 6.48
    "i3en.24xlarge" = 12.96
    "i3en.metal"    = 12.96

    "m3.medium"  = 0.079
    "m3.large"   = 0.158
    "m3.xlarge"  = 0.315
    "m3.2xlarge" = 0.632

    "m4.large"    = 0.12
    "m4.xlarge"   = 0.24
    "m4.2xlarge"  = 0.48
    "m4.4xlarge"  = 0.96
    "m4.10xlarge" = 2.4
    "m4.16xlarge" = 3.84

    "m5.large"    = 0.115
    "m5.xlarge"   = 0.23
    "m5.2xlarge"  = 0.46
    "m5.4xlarge"  = 0.92
    "m5.12xlarge" = 2.76
    "m5.24xlarge" = 5.52
    "m5.metal"    = 5.52

    "m5a.large"    = 0.104
    "m5a.xlarge"   = 0.208
    "m5a.2xlarge"  = 0.416
    "m5a.4xlarge"  = 0.832
    "m5a.12xlarge" = 2.496
    "m5a.24xlarge" = 4.992

    "m5d.large"    = 0.136
    "m5d.xlarge"   = 0.272
    "m5d.2xlarge"  = 0.544
    "m5d.4xlarge"  = 1.088
    "m5d.12xlarge" = 3.264
    "m5d.24xlarge" = 6.528
    "m5d.metal"    = 6.528

    "p2.xlarge"   = 1.326
    "p2.8xlarge"  = 10.608
    "p2.16xlarge" = 21.216

    "p3.2xlarge"  = 3.823
    "p3.8xlarge"  = 15.292
    "p3.16xlarge" = 30.584

    "r3.large"   = 0.2
    "r3.xlarge"  = 0.4
    "r3.2xlarge" = 0.8
    "r3.4xlarge" = 1.6
    "r3.8xlarge" = 3.201

    "r4.large"    = 0.16005
    "r4.xlarge"   = 0.3201
    "r4.2xlarge"  = 0.6402
    "r4.4xlarge"  = 1.2804
    "r4.8xlarge"  = 2.5608
    "r4.16xlarge" = 5.1216

    "r5.large"    = 0.152
    "r5.xlarge"   = 0.304
    "r5.2xlarge"  = 0.608
    "r5.4xlarge"  = 1.216
    "r5.12xlarge" = 3.648
    "r5.24xlarge" = 7.296
    "r5.metal"    = 7.296

    "r5a.large"    = 0.137
    "r5a.xlarge"   = 0.274
    "r5a.2xlarge"  = 0.548
    "r5a.4xlarge"  = 1.096
    "r5a.12xlarge" = 3.288
    "r5a.24xlarge" = 6.576

    "r5d.large"    = 0.173
    "r5d.xlarge"   = 0.346
    "r5d.2xlarge"  = 0.692
    "r5d.4xlarge"  = 1.384
    "r5d.12xlarge" = 4.152
    "r5d.24xlarge" = 8.304
    "r5d.metal"    = 8.304

    "t2.nano"    = 0.0067
    "t2.micro"   = 0.0134
    "t2.small"   = 0.0268
    "t2.medium"  = 0.0536
    "t2.large"   = 0.1072
    "t2.xlarge"  = 0.2144
    "t2.2xlarge" = 0.4288

    "t3.nano"    = 0.006
    "t3.micro"   = 0.012
    "t3.small"   = 0.024
    "t3.medium"  = 0.048
    "t3.large"   = 0.096
    "t3.xlarge"  = 0.192
    "t3.2xlarge" = 0.384

    "x1.16xlarge" = 9.337
    "x1.32xlarge" = 18.674

    "x1e.xlarge"   = 1.167
    "x1e.2xlarge"  = 2.334
    "x1e.4xlarge"  = 4.668
    "x1e.8xlarge"  = 9.336
    "x1e.16xlarge" = 18.672
    "x1e.32xlarge" = 37.344

    "z1d.large"    = 0.225
    "z1d.xlarge"   = 0.45
    "z1d.2xlarge"  = 0.9
    "z1d.3xlarge"  = 1.35
    "z1d.6xlarge"  = 2.7
    "z1d.12xlarge" = 5.4
    "z1d.metal"    = 5.4
  }

  description = "The map of on-demand prices."
}
