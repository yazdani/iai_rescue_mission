#include <ros/ros.h>
#include <actionlib/server/simple_action_server.h>
#include <quadrotor_controller/cmdVelAction.h>
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

class cmdVelAction
{
protected:

  ros::NodeHandle nh_;
  ros::NodeHandle nh;
  actionlib::SimpleActionServer<quadrotor_controller::cmdVelAction> action_; 
  std::string action_name_;
  quadrotor_controller::cmdVelFeedback feedback_;
  quadrotor_controller::cmdVelResult result_;
  ros::ServiceClient gms_c;  
  gazebo_msgs::SetModelState setmodelstate;
  gazebo_msgs::GetModelState getmodelstate; 
  ros::Publisher publisher;
  ros::ServiceClient smsl;
  geometry_msgs::Pose end_pose;
  geometry_msgs::Twist end_twist;

public:

 cmdVelAction(std::string name) :
    action_(nh_, name, boost::bind(&cmdVelAction::executeCB, this, _1), false),
    action_name_(name)
  {
      action_.start();
      ROS_INFO("Waiting for the Client to start the process");
  }

  ~cmdVelAction(void)
  {
  }

  void executeCB(const quadrotor_controller::cmdVelGoalConstPtr &goal)
  {
 
    ROS_INFO("Client is registered, lets start the executing");
    publisher = nh.advertise<geometry_msgs::Twist>("/cmd_vel", 1);
    gms_c = nh_.serviceClient<gazebo_msgs::GetModelState>("/gazebo/get_model_state");
    getmodelstate.request.model_name="red_hawk";
    
    geometry_msgs::Twist tw;
    publisher.publish(tw);
    ros::Duration(5.0).sleep();
    
    gms_c.call(getmodelstate);
    double now_x =  getmodelstate.response.pose.position.x;
    double now_y =  getmodelstate.response.pose.position.y;
    double now_z =  getmodelstate.response.pose.position.z;
    
    double new_x = goal->goal.position.x;
    double new_y = goal->goal.position.y;
    double new_z = goal->goal.position.z;
    ROS_INFO_STREAM(now_x);
    ROS_INFO_STREAM(now_y);
    ROS_INFO_STREAM(now_z);
    ROS_INFO_STREAM(new_x);
    ROS_INFO_STREAM(new_y);
    ROS_INFO_STREAM(new_z);
    ros::Rate r(1);
    bool success = true;
      
    ROS_INFO("%s: Executing!", action_name_.c_str());
        
    if (action_.isPreemptRequested() || !ros::ok())
      {
	ROS_INFO("%s: Preempted", action_name_.c_str());
	action_.setPreempted();
	success = false;
	//break;
      }
    
    publisher.publish(tw);
    ros::Duration(2.0).sleep();
       
       
    ROS_INFO(" Come Up Hector! ");
   
    if(now_z < new_z)
      {
	ROS_INFO(" now_z is bigger ");
	if(now_z < 10)
	  {
	    while(now_z < new_z)
	      {
		tw.linear.z = 0.6;
		publisher.publish(tw);
		ros::Duration(1.0).sleep();
		gms_c.call(getmodelstate);
		now_z =  getmodelstate.response.pose.position.z;
	      }
	ros::Duration(1.0).sleep();
	tw.linear.z = 0;
	tw.linear.x = 0;
	tw.linear.y = 0;
	publisher.publish(tw);
	std::cout << "haha2" << std::endl;
	  }
      }else if(now_z > new_z)
      {
	ROS_INFO(" now_z is smaller ");
	while(now_z > new_z)
	  {
	    std::cout << "hahaww" << std::endl;
	    tw.linear.z = -0.2;
	    publisher.publish(tw);
	    ros::Duration(1.0).sleep();
	    gms_c.call(getmodelstate);
	    now_z =  getmodelstate.response.pose.position.z;
	  }
	
	ros::Duration(1.0).sleep();
	tw.linear.z = 0;
	tw.linear.x = 0;
	tw.linear.y = 0;
	publisher.publish(tw);
      }else if(now_z == new_z)
      {
	if(now_z < 8){
	tw.linear.z = 0.5;
	publisher.publish(tw);
	
	ros::Duration(1.0).sleep();
	tw.linear.z = 0;
	tw.linear.x = 0;
	tw.linear.y = 0;
	publisher.publish(tw);
	}
      }

    if(now_x < new_x)
      {
	ROS_INFO(" now_x is bigger");
	while(now_x < new_x)
	  {
	    tw.linear.x = 0.2;
	    publisher.publish(tw);
	    ros::Duration(1.0).sleep();
	    gms_c.call(getmodelstate);
	    now_x =  getmodelstate.response.pose.position.x;
	  }
	
	ros::Duration(2.0).sleep();
	tw.linear.z = 0;
	tw.linear.x = 0;
	tw.linear.y = 0;
	publisher.publish(tw);
      }
	else if(now_x > new_x)
	  {
	ROS_INFO(" now_x is smaller ");
	    while(now_x > new_x)
	      {
		tw.linear.x = -0.1;
		publisher.publish(tw);
		ros::Duration(1.0).sleep();
		gms_c.call(getmodelstate);
		now_x =  getmodelstate.response.pose.position.x;
	      }
	    
	    ros::Duration(1.0).sleep();
	    tw.linear.z = 0;
	    tw.linear.x = 0;
	    tw.linear.y = 0;
	    publisher.publish(tw);
	  }else if(now_x == new_x)
	  {
	ROS_INFO(" now_x is equal ");
	    tw.linear.x = 0.5;
	    publisher.publish(tw);
	    
	    ros::Duration(1.0).sleep();
	    tw.linear.z = 0;
	    tw.linear.x = 0;
	    tw.linear.y = 0;
	    publisher.publish(tw);

	  }

    if(now_y < new_y)
      {
	ROS_INFO(" now_y is smaller ");
	while(now_y < new_y)
	  {
	    tw.linear.y = 0.2;
	    publisher.publish(tw);
	    ros::Duration(1.0).sleep();
	    gms_c.call(getmodelstate);
	    now_y =  getmodelstate.response.pose.position.y;
	  }
	ros::Duration(1.0).sleep();
	tw.linear.z = 0;
	tw.linear.x = 0;
	tw.linear.y = 0;
	publisher.publish(tw);
      }else if(now_y > new_y)
      {
	ROS_INFO(" now_y is bigger ");
	while(now_y > new_y)
	  {
	    tw.linear.y = -0.2;
	    publisher.publish(tw);
	    ros::Duration(1.0).sleep();
	    gms_c.call(getmodelstate);
	    now_y =  getmodelstate.response.pose.position.y;
	  }
	
	ros::Duration(1.0).sleep();
	tw.linear.z = 0;
	tw.linear.x = 0;
	tw.linear.y = 0;
	publisher.publish(tw); 
      }
    action_.publishFeedback(feedback_);
    // this sleep is not necessary, the sequence is computed at 1    }
    
    if(success)
      {
	result_.result = feedback_.feedback;
	ROS_INFO("%s: Succeeded", action_name_.c_str());
	// set the action state to succeeded
	action_.setSucceeded(result_);
      }}
  
};




int main(int argc, char** argv)
{
  ros::init(argc, argv, "cmdVel_tmp");

  cmdVelAction twister(ros::this_node::getName());
  ros::spin();

  return 0;
}
