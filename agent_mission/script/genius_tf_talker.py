#!/usr/bin/env python

import sys
import rospy
import tf
from agent_mission.srv import *

if __name__ == "__main__":
    print "Requesting"
    x = "/genius_link"
    rospy.wait_for_service('genius_pose')
   # print 'hello'
   # print x
    try:
        genius_pose = rospy.ServiceProxy('genius_pose', GeniusMsg)
        resp1 = genius_pose(x)
        print resp1.end
    except rospy.ServiceException, e:
        print "Service call failed: %s"%e

