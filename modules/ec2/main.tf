
resource "aws_instance" "web" {
  ami                  = "${var.instanceAmi}"
  instance_type        = "${var.instanceType}"
  vpc_security_group_ids      = ["${var.sgec2}"]
  key_name             = "USE_YOUR_OWN_KEY_PAIR"
  subnet_id            = "${var.subnetId}"

  user_data = "${data.template_file.ec2userdata.rendered}"

  tags = {
    Name = "${var.namePrefix}-instance"
  }
}
