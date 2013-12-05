#!/usr/bin/env python

import os
import sys
import datetime
import commands

DTIME=datetime.datetime.now()
APP_LOCATION=os.path.dirname(os.path.abspath(__file__))
APPNAME='wiki'
print APP_LOCATION
print APPNAME

def start():
    s = os.system('nohup python ' + os.path.join(APP_LOCATION, 'wikiserver.py') + ' &')
    if s == 0:
        print APPNAME + " restarted"

def stopApp(pid=None):
    if pid == None:
        getPID=commands.getoutput('ps uwwx | grep -v grep | grep ' + APPNAME + ' | awk \'{print$2}\'')
        if getPID == "":
            start()
    else:
        getPID=pid
        print "Got PID:" + getPID
    try:
        os.system('kill -9 ' + getPID)
        start()
    except Exception, e:
        print "ERROR: " + DTIME + " : " + APPNAME + " : " + e + "..."
        start()

def restartApp(pid):
    print "Restarting " + APPNAME + "..."
    stopApp(pid)

try:
    getPID=open('/tmp/%s.pid'%APPNAME, 'r').readline()
    restartApp(getPID)
except Exception, e:
    print "ERROR: %s : %s"%(DTIME, e)
    print "Didn't find PID file... will check for app running..."
    stopApp()