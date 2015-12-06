#!/usr/bin/env python

import socket, pickle
import rospy
import os, sys
import os.path
from std_msgs.msg import String
from instruct_mission.msg import multimodal_msgs
from instruct_mission.msg import multimodal_values

action=''
directive=''
cmd_typ=''
pub=''
#interpreted_cmd=''
#str1=''
agent=''
#dat=''
cmd_typ=''
#dire=''
#loc=''
#poly=''
#seg=''
#circ=''
pose=''
#artest=''
#artest2=''
item = ''
command = ''
loc = ''
def callback(msg):
     global agent 
     global pose
     global loc
     agent = msg.selected
     tmp = msg.command
     cmd = tmp.replace("_", " ")
     checkCmdType(cmd)
     checkCommand(cmd)
     pose = msg.direction
     loc = msg.location
     pub.publish(agent,command,cmd_typ,pose,loc)

def checkCmdType(date):
     global cmd_typ
     data = date.split(" ")
     a = ''.join(['a', 'r', 'e'])
     b = ''.join(['d', 'o'])
     c = ''.join(['d', 'o', 'e', 's'])
     d = ''.join(['h', 'a', 'v', 'e'])
     e = ''.join(['h', 'a', 's'])
     f = ''.join(['h', 'o', 'w'])
     g = ''.join(['w', 'h', 'a', 't'])
     h = ''.join(['w', 'h', 'i', 'c', 'h'])
     i = ''.join(['w', 'h', 'e', 'r', 'e'])
     j = ''.join(['w', 'h', 'o'])
     k = ''.join(['w', 'h', 'o', 's', 'e'])
     l = ''.join(['w', 'h', 'y'])   
     
     if data[0] == a or data[0] == b or data[0] == c or data[0] == d or data[0] == e or data[0] == f or data[0] == g or data[0] == h or data[0] == i or data[0] == j or data[0] == k or data[0] == l:
          cmd_typ = "ask"
     else:
          cmd_typ = "order"
          

def checkCommand(date):
     global command
     tmp = date + '\n'
     c.send(tmp)
     sys.stdout.flush()
     interpreted_cmd = c.recv(1024)
     command = interpreted_cmd   
   

def startConnection():
    global pub
    global c
    pub = rospy.Publisher('multimodal_msgs', multimodal_values, queue_size=10)
    rospy.init_node('multimodal')
    rate = rospy.Rate(10)
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind(("", 1234))
    s.listen(1)
    server = ""
    c, address = s.accept()
    rospy.Subscriber("test_msgs", multimodal_msgs, callback)
    rospy.spin()
    s.shutdown(socket.SHUT_RDWR)
    s.close()



if __name__ == '__main__':
     startConnection()
