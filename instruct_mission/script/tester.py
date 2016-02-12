#!/usr/bin/env python

import rospy
from instruct_mission.msg import multimodal_msgs
from std_msgs.msg import String
from geometry_msgs.msg import Vector3
from geometry_msgs.msg import Pose
from std_msgs.msg import String


def talker():
    pub = rospy.Publisher('test_msgs',multimodal_msgs, queue_size=10)
    rospy.init_node('tf_transforms')
    rate = rospy.Rate(0.1) 
    circ = Vector3()
    str1 = multimodal_msgs()
    pose = Pose()
    hello_str = "hello world %s" % rospy.get_time()
    rospy.loginfo(hello_str)
    while not rospy.is_shutdown():

        str1.selected = "blue hawk"
        str1.type = "how"
        str1.command = "Go close to this house"
        str1.data = 1.0
        str1.direction = [2.0, 0.0, 0.0]
        str1.location = [3.0, 0.0, 0.0]
        str1.confidence = 1.98
        str1.polygonal_area = []
        str1.segment = []
        str1.circ_area.x = 0.0 
        str1.circ_area.y = 0.0
        str1.circ_area.z = 0.0
        str1.radius = 0.0
        str1.source = "gesture"
        str1.sample.position.x = 0.0
        str1.sample.position.y  = 0.0
        str1.sample.position.z = 0.0
        str1.sample.orientation.x = 0.0       
        str1.sample.orientation.y = 0.0        
        str1.sample.orientation.z = 0.0
        str1.sample.orientation.w = 0.0
        rospy.loginfo(str1)
        pub.publish(str1)
        rate.sleep()


if __name__ == '__main__':
  try:
    talker()
  except rospy.ROSInterruptException:
    pass
        
