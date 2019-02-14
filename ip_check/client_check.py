#!/usr/bin/env python
# -*- coding: utf-8 -*-

import socket
import urllib,urllib2
import string
import threading
import sys,json
import os,time

SERVER = ""
CHANGE_ALL = 0
PORT = 10240

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
        print "ask error ", ex.code
    return "null"

if __name__ == "__main__":
    '''
	server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(("0.0.0.0", int(port)))
    server.listen(5)
	'''
    print "client start!"
    try:
        while True:
            ip = getIpcountry()
            print ip
            if ip == 'null':
                time.sleep(2)
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
                            print d
                            s.close()
                            if d == '1':
                                print "IP change ok"
                                with open('/tmp/ip', 'w') as f:
                                    f.write(ip)
                        except socket.error:
                            print("Disconnected...")
                            # keep on trying after a disconnect
                            s.close()
            time.sleep(60)
    except KeyboardInterrupt, e:
        pass
    print "server stop"


