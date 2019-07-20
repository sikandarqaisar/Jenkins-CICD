output "sgAlb" {
  value = "${aws_security_group.sgAlb.id}"
}

output "sgECS" {
  value = "${aws_security_group.sgECS.id}"
}

output "vpcId" {
  value = "${aws_vpc.mainVPC.id}"
}

# For count>1 in subnet
# output "subnetIds" {
#   value = "${join(",", aws_subnet.subnet.*.id)}"
# }

# For count=1 in subnet
output "subnetId" {
  value = "${aws_subnet.subnet.id}"
}

output "sgec2" {
  value = "${aws_security_group.sgec2.id}"
}



