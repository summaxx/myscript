#!/bin/bash

yum install curl-devel -y
yum install expat-devel -y 
yum install gettext-devel -y 
yum install openssl-devel -y
yum install zlib-devel -y
yum install gcc -y 
yum install perl-ExtUtils-MakeMaker -y
yum update nss curl libcurl -y
yum remove git -y

wget -N --no-check-certificate  https://www.kernel.org/pub/software/scm/git/git-2.1.2.tar.gz
tar xzf git-2.1.2.tar.gz
cd git-2.1.2

./configure --prefix=/usr/local/git --with-iconv=/usr/local/libiconv
make && make install

echo "export PATH=$PATH:/usr/local/git/bin" >> /etc/bashrc
source /etc/bashrc