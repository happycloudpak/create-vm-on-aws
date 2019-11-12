#################################################################
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Licensed Materials - Property of IBM
#
# ©Copyright IBM Corp. 2017, 2018.
#
#################################################################

provider "aws" {
  version = "~> 1.2"
  region  = "${var.aws_region}"
}

module "camtags" {
  source = "../Modules/camtags"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "ap-northeast-2"
}

variable "vpc_name_tag" {
  description = "Name of the Virtual Private Cloud (VPC) this resource is going to be deployed into"
  default = ""
}

variable "subnet_name" {
  description = "Subnet Name"
  default = ""
}

variable "aws_image_size" {
  description = "AWS Image Instance Size"
  default     = "t2.micro"
}

data "aws_vpc" "selected" {
  state = "available"

  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name_tag}"]
  }
}

data "aws_subnet" "selected" {
  filter {
    name   = "tag:Name"
    values = ["${var.subnet_name}"]
  }
}

variable "public_ssh_key_name" {
  description = "Name of the public SSH key used to connect to the virtual guest"
  default = "sshkey"
}

variable "public_ssh_key" {
  description = "Public SSH key used to connect to the virtual guest"
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDH+Z1xF3RG7xgxX8pATI0VmYPI5uEb5aAHnEm0POe6jtUcYZRWm5L88WX53UeQsNknkbt1LSn6vGaUEVYicd0Rr8NYY5mLD1T14wVi4H1bKOyJggR5D46gzXZcggGRvkAE9iz/ldCZvMqSF/YBDPQ01JS/zObizJ0xgJWwV4mAghrcrS8N5qmQMtBsQoecoGOmE6pAXUpLcPAQQe/XSFswA31xMgeBclnX24614iQ4WNjuuBnycgF2k+BhkLhJZcfEW5jTDbcFuxhoI74YkNSiOk8xuIngTOfCAkFw/S3YpCTxxwkAhkaEgnWRfLtvowveyP7hovhBc1ku36lEQvGN root@nfs"
}

#Variable : AWS image name
variable "aws_image" {
  type        = "string"
  description = "Operating system image id / template that should be used when creating the virtual image"
  default     = "ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"
}

variable "aws_ami_owner_id" {
  description = "AWS AMI Owner ID"
  default     = "099720109477"
}

# Lookup for AMI based on image name and owner ID
data "aws_ami" "aws_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.aws_image}*"]
  }

  owners = ["${var.aws_ami_owner_id}"]
}

resource "aws_key_pair" "orpheus_public_key" {
  key_name   = "${var.public_ssh_key_name}"
  public_key = "${var.public_ssh_key}"
}

resource "aws_instance" "orpheus_ubuntu_micro" {
  instance_type = "${var.aws_image_size}"
  ami           = "${data.aws_ami.aws_ami.id}"
  subnet_id     = "${data.aws_subnet.selected.id}"
  key_name      = "${aws_key_pair.orpheus_public_key.id}"
  tags          = "${module.camtags.tagsmap}"
}

