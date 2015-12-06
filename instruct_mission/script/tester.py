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
        #   str1.selected = "blue hawk"
        #  str1.type = "go"
        #  str1.command = "Go right"
        #  str1.data = 1.0
        #  str1.direction = [2.0, 0.0, 0.0]
        #   str1.location = [3.0, 0.0, 0.0]
        #    str1.confidence = 1.98
        #     str1.polygonal_area = []
        # str1.segment = []
        # str1.circ_area.x = 0.0 
        # str1.circ_area.y = 0.0
        #str1.circ_area.z = 0.0
        # str1.radius = 0.0
        # str1.source = "gesture"
        # str1.sample.position.x = 0.0
        # str1.sample.position.y  = 0.0
        # str1.sample.position.z = 0.0
        ## str1.sample.orientation.x = 0.0       
        # str1.sample.orientation.y = 0.0        
        # str1.sample.orientation.z = 0.0
        # str1.sample.orientation.w = 0.0
        # rospy.loginfo(str1)
        # pub.publish(str1)
        # rate.sleep()
        ##str1.selected = "blue hawk"
        #str1.type = "go"
        # str1.command = "Go left"
        # str1.data = 1.0
        # str1.direction = [2.0, 0.0, 0.0]
        # str1.location = [3.0, 0.0, 0.0]
        # str1.confidence = 1.98
        # str1.polygonal_area = []
        ## str1.segment = []
        #str1.circ_area.x = 0.0 
        #str1.circ_area.y = 0.0
        # str1.circ_area.z = 0.0
        # str1.radius = 0.0
        # str1.source = "gesture"
        #  str1.sample.position.x = 0.0
        #  str1.sample.position.y  = 0.0
        #  str1.sample.position.z = 0.0
        #  str1.sample.orientation.x = 0.0       
        ##  str1.sample.orientation.y = 0.0        
        #str1.sample.orientation.z = 0.0
        # str1.sample.orientation.w = 0.0
        # rospy.loginfo(str1)
        # pub.publish(str1)
        # rate.sleep()
        # str1.selected = "red hawk"
        # str1.type = "go"
        # str1.command = "Go ahead"
        # str1.data = 1.0
        # str1.direction = [2.0, 0.0, 0.0]
        ## str1.location = [3.0, 0.0, 0.0]
        #str1.confidence = 1.98
        #str1.polygonal_area = []
        #str1.segment = []
        #str1.circ_area.x = 0.0 
        #str1.circ_area.y = 0.0
        #str1.circ_area.z = 0.0
        #str1.radius = 0.0
        #str1.source = "gesture"
        #str1.sample.position.x = 0.0
        #str1.sample.position.y  = 0.0
        #str1.sample.position.z = 0.0
        #str1.sample.orientation.x = 0.0       
        #str1.sample.orientation.y = 0.0        
        str1.sample.orientation.z = 0.0
        #str1.sample.orientation.w = 0.0
        #rospy.loginfo(str1)
        #pub.publish(str1)
        ##rate.sleep()
        #str1.selected = "red hawk"
        #str1.type = "go"
        #str1.command = "Take off"
        #str1.data = 1.0
        #str1.direction = [2.0, 0.0, 0.0]
        #str1.location = [3.0, 0.0, 0.0]
        #str1.confidence = 1.98
        #str1.polygonal_area = []
        ##str1.segment = []
        #str1.circ_area.x = 0.0 
        #str1.circ_area.y = 0.0
        #str1.circ_area.z = 0.0
        ##str1.radius = 0.0
        #str1.source = "gesture"
        #str1.sample.position.x = 0.0
        #str1.sample.position.y  = 0.0
        #str1.sample.position.z = 0.0
        #str1.sample.orientation.x = 0.0       
        #str1.sample.orientation.y = 0.0        
        #str1.sample.orientation.z = 0.0
        #str1.sample.orientation.w = 0.0
        #rospy.loginfo(str1)
        #pub.publish(str1)
        #rate.sleep()
        #str1.selected = "blue hawk"
        #str1.type = "report"
        #str1.command = "Report me the location"
        #str1.data = 1.0
        #str1.direction = [2.0, 0.0, 0.0]
        #str1.location = [3.0, 0.0, 0.0]
        #str1.confidence = 1.98
        #str1.polygonal_area = []
        #str1.segment = []
        #str1.circ_area.x = 0.0 
        #str1.circ_area.y = 0.0
        #str1.circ_area.z = 0.0
        ##str1.radius = 0.0
        #str1.source = "gesture"
        #str1.sample.position.x = 0.0
        #str1.sample.position.y  = 0.0
        ##str1.sample.position.z = 0.0
        #s#tr1.sample.orientation.x = 0.0       
        #str1.sample.orientation.y = 0.0        
        #str1.sample.orientation.z = 0.0
        #str1.sample.orientation.w = 0.0
        #r#ospy.loginfo(str1)
        #pub.publish(str1)
        #rate.sleep()
        #str1.selected = "blue hawk"
        #str1.type = "where"
        #str1.command = "Where is the victim located"
        #str1.data = 1.0
        #str1.direction = [2.0, 0.0, 0.0]
        #str1.location = [3.0, 0.0, 0.0]
        #str1.confidence = 1.98
        #str1.polygonal_area = []
        #str1.segment = []
        #s#tr1.circ_area.x = 0.0 
        #str1.circ_area.y = 0.0
        #str1.circ_area.z = 0.0
        #str1.radius = 0.0
        ##str1.source = "gesture"
        #s#tr1.sample.position.x = 0.0
        #str1.sample.position.y  = 0.0
        #str1.sample.position.z = 0.0
        #str1.sample.orientation.x = 0.0       
        #str1.sample.orientation.y = 0.0        
        #str1.sample.orientation.z = 0.0
        #str1.sample.orientation.w = 0.0
        #rospy.loginfo(str1)
        #pub.publish(str1)
        #rate.sleep()
        #str1.selected = "blue hawk"
        #str1.type = "how"
        #str1.command = "How are the conditions around the survivor"
        #str1.data = 1.0
        #str1.direction = [2.0, 0.0, 0.0]
        #s#tr1.location = [3.0, 0.0, 0.0]
        # s#tr1.confidence = 1.98
        ##str1.polygonal_area = []
        #str1.segment = []
        #str1.circ_area.x = 0.0 
        #str1.circ_area.y = 0.0
        #str1.circ_area.z = 0.0
        #str1.radius = 0.0
        #str1.source = "gesture"
        #str1.sample.position.x = 0.0
        #str1.sample.position.y  = 0.0
        #str1.sample.position.z = 0.0
        #str1.sample.orientation.x = 0.0       
        #str1.sample.orientation.y = 0.0        
        #str1.sample.orientation.z = 0.0
        #str1.sample.orientation.w = 0.0
        #rospy.loginfo(str1)
        #pub.publish(str1)
        #rate.sleep()


        #str1.selected = "blue hawk"
        #str1.type = "how"
        #str1.command = "How are the weather conditions there"
        #str1.data = 1.0
        #str1.direction = [2.0, 0.0, 0.0]
        #str1.location = [3.0, 0.0, 0.0]
        #str1.confidence = 1.98
        #str1.polygonal_area = []
        #str1.segment = []
        #str1.circ_area.x = 0.0 
        #str1.circ_area.y = 0.0
        #str1.circ_area.z = 0.0
        #str1.radius = 0.0
        #str1.source = "gesture"
        #str1.sample.position.x = 0.0
        #str1.sample.position.y  = 0.0
        #str1.sample.position.z = 0.0
        #str1.sample.orientation.x = 0.0       
        #str1.sample.orientation.y = 0.0        
        #str1.sample.orientation.z = 0.0
        #s#tr1.sample.orientation.w = 0.0
        #rospy.loginfo(str1)
        #pub.publish(str1)
        #rate.sleep() 

        #str1.selected = "blue hawk"
        #str1.type = "how"
        ##str1.command = "Have you seen any victims"
        #s##tr1.data = 1.0
        #str1.direction = [2.0, 0.0, 0.0]
        #str1.location = [3.0, 0.0, 0.0]
        #str1.confidence = 1.98
        #str1.polygonal_area = []
        #str1.segment = []
        #str1.circ_area.x = 0.0 
        #str1.circ_area.y = 0.0
        #str1.circ_area.z = 0.0
        #str1.radius = 0.0
        #str1.source = "gesture"
        #str1.sample.position.x = 0.0
        #str1.sample.position.y  = 0.0
        #str1.sample.position.z = 0.0
        #str1.sample.orientation.x = 0.0       
        #str1.sample.orientation.y = 0.0        
        #str1.sample.orientation.z = 0.0
        #str1.sample.orientation.w = 0.0
        #rospy.loginfo(str1)
        #pub.publish(str1)
        #rate.sleep()


        str1.selected = "blue hawk"
        str1.type = "how"
        str1.command = "Go to this tree to this victim"       
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

       # hello_str = "Have you seen any victims"
       # pub.publish(hello_str)
       # rate.sleep()
       # hello_str = "How are the weather conditions there"
       # pub.publish(hello_str)
       # rate.sleep()
       # hello_str = "Take a picture"
       # pub.publish(hello_str)
      #  rate.sleep()
       # hello_str = "Take a video"
      #  pub.publish(hello_str)
      #  rate.sleep()
       # hello_str = "Where is the victim located"
        #pub.publish(hello_str)
        #rate.sleep()
       # hello_str = "Report me the location"
       # pub.publish(hello_str)
       # rate.sleep()
       # hello_str = "How are the conditions around the survivor"
       # pub.publish(hello_str)
       # rate.sleep()
       # hello_str = "Go further"
       # pub.publish(hello_str)
       # rate.sleep()
       # hello_str = "Look for some victims"
       # pub.publish(hello_str)
       # rate.sleep()
       # hello_str = "Tell me the conditions"
       # pub.publish(hello_str)
       # rate.sleep()
       # hello_str = "Search for a cap"
       # pub.publish(hello_str)
       # rate.sleep()
       # hello_str = "What do you see"
       # pub.publish(hello_str)
       # rate.sleep()
       # hello_str = "Search for a yellow cap"
       # pub.publish(hello_str)
       # rate.sleep()

if __name__ == '__main__':
  try:
    talker()
  except rospy.ROSInterruptException:
    pass
        
