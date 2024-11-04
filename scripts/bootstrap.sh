#! /bin/bash
yum update -y
yum -y install nginx
systemctl enable nginx
systemctl start nginx
