#!/usr/bin/env python  
import rospy
import tf
import tf_conversions
import geometry_msgs.msg


class FixedTFBroadcaster:

    def __init__(self):
        self.pub_tf = rospy.Publisher("/tf", tf.msg.tfMessage, queue_size=1)

        while not rospy.is_shutdown():
            # Run this loop at about 10Hz
            rospy.sleep(0.1)

            t = geometry_msgs.msg.TransformStamped()
            t.header.frame_id = "human_frame"
            t.header.stamp = rospy.Time.now()
            t.child_frame_id = "map"
            t.transform.translation.x = 16.0
            t.transform.translation.y = 0.0
            t.transform.translation.z = 0.0

            t.transform.rotation.x = 0.0
            t.transform.rotation.y = 0.0
            t.transform.rotation.z = -1.5
            t.transform.rotation.w = 1.0

            tfm = tf.msg.tfMessage([t])
            self.pub_tf.publish(tfm)

if __name__ == '__main__':
    rospy.init_node('my_tf_broadcaster')
    tfb = FixedTFBroadcaster()

    rospy.spin()
