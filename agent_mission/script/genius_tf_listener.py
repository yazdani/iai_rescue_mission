#! /usr/bin/env python

import rospy
import roslib
import tf
from agent_mission.srv import GeniusMsg
import geometry_msgs.msg 

def genius_callback(req):
  #  print "Returning Genius Msg"
  #  print req
    rate = rospy.Rate(10.0)
    listener = tf.TransformListener()

    listener.waitForTransform(req.msg, "/world", rospy.Time(), rospy.Duration(4.0))
  #  print type(listener)
   # while not rospy.is_shutdown():

  
    (trans,rot) = listener.lookupTransform("/world", req.msg, rospy.Time(0))

    cmd = geometry_msgs.msg.Transform()
    cmd.translation.x = trans[0]
    cmd.translation.y = trans[1]
    cmd.translation.z = trans[2]

    cmd.rotation.x = rot[0]
    cmd.rotation.y = rot[1]
    cmd.rotation.z = rot[2]
    cmd.rotation.w = rot[3]

   # print cmd
    return cmd

def add_to_genius():
    rospy.init_node('genius_position_listener')
    s = rospy.Service('genius_pose', GeniusMsg, genius_callback)
    print "Give me the genius position."
    rospy.spin()

if __name__ == "__main__":
    add_to_genius()
    

