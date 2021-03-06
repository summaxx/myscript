#!/usr/bin/env python
# -*- coding: utf-8 -*-

import socket
import urllib,urllib2
import string
import threading
import sys,json
import os,time

SERVER = "j1.vpsee.tk" #服务器IP
CHANGE_ALL = 0 #是否替换所有 IP
PORT = 10240 #服务器端口
HOST =  ''#ddns 子域名
DOMAIN =  ''#ddns 主域名
PASSWD = ''#ddns 密码


'''
查询ip 地址的归属地信息
aip 查询的ip
返回 归属地信息
'''
def getIpcountry():
    url = "https://ifconfig.co/json"
    # print(url)
    try:
        headers = { 'User-Agent': 'Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.1.6) Gecko/20091201 Firefox/3.5.6'}
        req = urllib2.Request(url=url, headers=headers)
        res = urllib2.urlopen(req, timeout=10)
        res = res.read()
        if res != "":
            r = json.loads(res)
            return r["ip"]
    except urllib2.HTTPError, ex:
        print "ask error ", ex.message
    except urllib2.URLError, e1:
        print "url error", e1.message
    except ssl.SSLError , e2:
	    print "ssl error", e2.message
    return "null"

def ddnsip(ip):
    url = 'https://dynamicdns.park-your-domain.com/update?host=%s&domain=%s&password=%s&ip=%s' % (HOST, DOMAIN, PASSWD, ip)
    #print(url)
    try:
            req = urllib2.Request(url)
            res = urllib2.urlopen(req, timeout=10)
            res = res.read()
            #print res
            # 更换成功
            if res.find('error') == -1:
                return 1
    except Exception, ex:
            print "chang ddns ip error " + ex.message
    return 0

if __name__ == "__main__":
    '''
	server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(("0.0.0.0", int(port)))
    server.listen(5)
	'''
    print "client start!"
    while True:
        try:
            ip = getIpcountry()
            print ip
            if ip == 'null':
                time.sleep(5)
                continue
            if not os.path.exists('/tmp/ip'):
                with open('/tmp/ip', 'w') as f:
                    f.write(ip)
            else:
                with open('/tmp/ip', 'r') as f:
                    aip = f.readline()
                if not aip is None:
                    if ip.strip() != aip.strip():
                        data = { 'ip' : aip, 's' : CHANGE_ALL }
                        js = json.dumps(data)
                        print js
                        try:
                            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                            s.connect((SERVER, PORT))
                            s.send(js)
                            d = s.recv(32).strip()
                            #print d
                            s.close()
                            if HOST != '':
                                ddnsip(ip)
                            if d == '1':
                                print "IP change ok"
                                with open('/tmp/ip', 'w') as f:
                                    f.write(ip)
                                os.system('reboot')
                        except socket.error:
                            print("Disconnected...")
                            # keep on trying after a disconnect
                            s.close()
        except KeyboardInterrupt, e:
            pass
        time.sleep(300)
    print "server stop"


