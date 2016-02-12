#!/usr/bin/env python

#****************************************************************************
#
# Sherpa World Model Interface
#
# This software was developed at:
# PRISMA Lab.
# Napoli, Italy
#
# Description:
#  Interface node with SWM
#
# Authors:
# Jonathan Cacace <jonathan.cacace@gmail.com>
#
# Created in 05/02/2016.
#
#
# Copyright (C) 2015 PRISMA Lab. All rights reserved.
#****************************************************************************/


#---Ros lib
import rospy
import roslib
import actionlib
#---

import os.path
import ConfigParser
import zmq
import random
import sys
import time
import json

import sys
import time
import re
import os
import thread
import multiprocessing


sys.path.append('/home/yazdani/Desktop/pySWM_r20160209')
import swm

from geometry_msgs.msg import *
from std_msgs.msg import *
from sensor_msgs.msg import Joy
'''
from pyutil.fipa import *
from pyutil.wdbutil import *
from pyutil.consutil import *
'''

#-Receive the busy genius position from Ros Topic -> update SWM
class swm_interface_bg( object ):

	def __init__( self ):

		#---Subscriber
		rospy.Subscriber("/CREATE/swm/sherpa_pose", Pose, self.set_bg_pose, queue_size = 1)
		#---

	#Update bg position + orientation
	def set_bg_pose(self, pose_data):

		##---Translate bg pose from (lat, lon, alt), (quat) to -> H_s = [ R, (lat, lon, alt ]
		print "set genius geopose"
		#---

		swm.run('set genius geopose %.6f %.6f %.2f %.2f %.2f %.2f %.2f' % (pose_data.position.x, pose_data.position.y, pose_data.position.z, pose_data.orientation.w, pose_data.orientation.x, pose_data.orientation.y, pose_data.orientation.z))


	def run(self):	
		rospy.spin()		

if __name__ == '__main__':

	rospy.init_node('CREATE_SWM_busy_genius')
	bg_interface = swm_interface_bg()
	bg_interface.run()


