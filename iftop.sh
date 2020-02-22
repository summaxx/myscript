#!/bin/bash
# Description: install iftop

yum install -y flex byacc  libpcap ncurses ncurses-devel libpcap-devel byacc ncurses-devel make autoconf cmake gcc gcc-c++ gcc-g77

wget -c http://www.ex-parrot.com/~pdw/iftop/download/iftop-0.17.tar.gz
tar zxvfp iftop-0.17.tar.gz
cd iftop-0.17
./configure
make && make install