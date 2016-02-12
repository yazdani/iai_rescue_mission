#include <ros/ros.h>
#include <actionlib/server/simple_action_server.h>
#include <hector_quadrotor_msgs/followerAction.h>
#include <geometry_msgs/Pose.h>
#include <geometry_msgs/PoseStamped.h>
#include <geometry_msgs/Twist.h>
#include <gazebo_msgs/GetModelState.h>
#include <gazebo_msgs/SetModelState.h>
#include <geometry_msgs/Twist.h>
#include <sstream>
#include <string>
#include <std_msgs/String.h>
#include <iostream>
#include <tf/LinearMath/Quaternion.h>
#include <stdio.h> 
#include <math.h>


int main (int argc, char **argv)
{

  ros::init(argc, argv, "interactor");

  ros::NodeHandle n;
  ros::NodeHandle nh;
  

  ros::Publisher c_pub = n.advertise<multimodal_interpreter::multimodal_values>("CMDtalker", 1000);
  ros::Subscriber sub = nh.subscribe("multimodal_msgs", 1000, callback);
  ros::Rate loop_rate(10);

  while (ros::ok())
  {
    std_msgs::String msg;
    std::stringstream ss;

    c_pub.publish(msg);
    ros::spinOnce();
    
    loop_rate.sleep();
  }
  //gms_c = nh_.serviceClient<gazebo_msgs::GetModelState>("/gazebo/get_model_state");

  return 0;

}

void callback(const std_msgs::String::ConstPtr& msg)
{
  ROS_INFO("I heard: [%s]", msg->data.c_str());
}
