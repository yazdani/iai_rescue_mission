#include "ros/ros.h"
#include "instruct_mission/multimodal_msgs.h"

bool interpreter(instruct_mission::multimodal_msgs::Request  &req,
         instruct_mission::multimodal_msgs::Response &res)
{
  res.agent = req.selected;
  res.command = req.type;
  res.type = "doch nicht order";
  float test = req.direction[0];
  
  ROS_INFO_STREAM("Agent: "<< res.agent );
  ROS_INFO_STREAM("Instruction: "<< res.command );
  ROS_INFO_STREAM("Type: "<< res.type );
  ROS_INFO_STREAM("Data : "<< req.data );
  ROS_INFO_STREAM("Gesture.x " <<  req.direction[0]);
  ROS_INFO_STREAM("Gesture.y " <<  req.direction[1]);
  ROS_INFO_STREAM("Gesture.z " <<  req.direction[2]);
  ROS_INFO_STREAM("location.x " <<  req.location[0]);
  ROS_INFO_STREAM("location.y " <<  req.location[1]);
  ROS_INFO_STREAM("location.z " <<  req.location[2]);
  ROS_INFO_STREAM("confidence " <<  req.confidence);
  ROS_INFO_STREAM("poly_area.x " <<  req.polygonal_area[1]);
  ROS_INFO_STREAM("poly_area.y " <<  req.polygonal_area[2]);
  ROS_INFO_STREAM("poly_area.z " <<  req.polygonal_area[0]);
  ROS_INFO_STREAM("segment.x " <<  req.segment[0]);
  ROS_INFO_STREAM("segment.y " <<  req.segment[1]);
  ROS_INFO_STREAM("segment.z " <<  req.segment[2]);
  ROS_INFO_STREAM("circ_area.x " <<  req.circ_area.x);
  ROS_INFO_STREAM("circ_area.y " <<  req.circ_area.y);
  ROS_INFO_STREAM("circ_area.z " <<  req.circ_area.z);
  ROS_INFO_STREAM("radius " <<  req.radius);
  ROS_INFO_STREAM("source " <<  req.source);
  ROS_INFO_STREAM("sample " <<  req.sample.position.x);
  return true;
}

int main(int argc, char **argv)
{
  ros::init(argc, argv, "show_the_string_server");
  ros::NodeHandle n;

  ros::ServiceServer service = n.advertiseService("show_the_string", interpreter);
  ROS_INFO_STREAM("Show my String.");
  ros::spin();

  return 0;
}
