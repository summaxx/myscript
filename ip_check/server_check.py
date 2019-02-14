#!/usr/bin/env python
# -*- coding: utf-8 -*-

import socket
import urllib,urllib2
import random
import string
import threading
import telegram
import sys,json


IPURL = ''
BOTTOKEN = ''
ADMINID = ''


'''
通过http接口更换IP，对接sspanel面板
u sspanel 对接url
s 是否服务ip和节点ip同时更换
ip 旧ip
nip 新ip
'''
def httpchangip(s, ip, nip):
    #ccc = 0
    #for u in IPURL:
    url = '%s&s=%s&ip=%s&nip=%s' % (IPURL, s, ip, nip)
    print(url)
    #ccc += 1
    try:
        req = urllib2.Request(url)
        res = urllib2.urlopen(req, timeout=10)
        # print res.read()
        res = res.read()
        # 更换成功
        if res.find('1') > 0:
            return 1
    except Exception, ex:
        print "Not found IP" + ex.message
    return 0

'''
查询ip 地址的归属地信息
aip 查询的ip
返回 归属地信息
'''
def getIpcountry(aip):
    url = "http://ipinfo.io/%s" % (aip)
    # print(url)
    try:
        req = urllib2.Request(url)
        res = urllib2.urlopen(req, timeout=10)
        res = res.read()
        if not res is None:
            r = json.loads(res)
            return r["region"] + "/" + r["country"]
    except Exception, ex:
        print "ask error " + ex.message
    return "unknown"


'''
client tcp对像
aip ip对像
'''
def cServer(client, aip):
    data = client.recv(512).strip()
    # print(aip[0] + ': ' + data)
    if len(data) > 0:
        js = json.loads(data)
        print  js
        ret = httpchangip(int(js['s']), js['ip'], aip)
        bot = telegram.Bot(token=BOTTOKEN)
        if ret == 0:
            client.send('0')
            bot.sendMessage(ADMINID, "new IP:" + aip + " old ip:" + js['ip'] + " change fail!")
        else:
            client.send('1')
            print 'chang ok'
            try:
                ipinfo = getIpcountry(js['ip'])
                bot.sendMessage(ADMINID, "NAT:" + str(ret) + "old IP: " + js['ip'] + " changed,Replaced new IP: "
                                + aip + "[" + ipinfo + "] completed!")
            except Exception, ex:
                print ex.message
    client.close()


'''
查询ip 地址的归属地信息
aip 查询的ip
返回 归属地信息
'''
def getIpcountry(aip):
    url = "http://ipinfo.io/%s" % (aip)
    # print(url)
    try:
        req = urllib2.Request(url)
        res = urllib2.urlopen(req, timeout=10)
        res = res.read()
        if res != "":
            r = json.loads(res)
            return r["region"] + "/" + r["country"]
    except Exception, ex:
        print "ask error " + ex.message
    return "unknown"

if __name__ == "__main__":
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(("0.0.0.0", 10240))
    server.listen(5)
    print "server start!"
    try:
        while True:
            c, addr = server.accept()
            t = threading.Thread(target=cServer, args=(c, addr[0]))
            t.start()
    except KeyboardInterrupt, e:
        pass
    server.close()
    print "server stop"
