data "template_file" "ec2userdata" {
  template = "${file("./modules/ec2/templates/ec2userdata.tpl")}"
}
