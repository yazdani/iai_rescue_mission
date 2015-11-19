#include "ros/ros.h"
#include "instruct_mission/multimodal_msgs.h"
#include <cstdlib>
#include "geometry_msgs/Pose.h"
#include "geometry_msgs/Vector3.h"
#include "std_msgs/Float64.h"

int main(int argc, char **argv)
{
  ros::init(argc, argv, "show_my_string_client");
  ros::NodeHandle n;
  ros::ServiceClient client = n.serviceClient<instruct_mission::multimodal_msgs>("show_the_string");
  ros::Rate r(0.1); 
  instruct_mission::multimodal_msgs srv;
  geometry_msgs::Pose p;
  geometry_msgs::Vector3 vec;
  vec.x = 0.2;
  vec.y = 0.4;
  vec.z = 0.5;
  p.position.x = 5;
  p.position.y = 0;
  p.position.z = 0;
  p.orientation.x = 0;
  p.orientation.y = 0;
  p.orientation.z = 0;
  p.orientation.w = 1;
  std::vector<float> dir;
  dir.push_back(0.3);
  dir.push_back(0.2);
  dir.push_back(0.1);
  std::vector<float> loc;
  loc.push_back(0.3);
  loc.push_back(0.2);
  loc.push_back(0.1);
  std::vector<float> poly;
  poly.push_back(0.23);
  poly.push_back(0.22);
  poly.push_back(0.21);
  float conf = 0.5;
  std::vector<float> seg;
  seg.push_back(0.23);
  seg.push_back(0.22);
  seg.push_back(0.21);
  
 
 srv.request.selected = "red_hawk";
  srv.request.type = "order";
  srv.request.command = "Go there";
  srv.request.data = 0.2;
  srv.request.direction = dir;
  srv.request.location = loc;
  srv.request.confidence = conf;
  srv.request.polygonal_area = poly;
  srv.request.segment = seg;
  srv.request.circ_area = vec;
  srv.request.source = "gesture";
  srv.request.sample = p;
  /*
  srv.request.location[0] = 0.3;
  srv.request.location[1] = 0.4;
  srv.request.location[2] = 0.5;
  srv.request.confidence = 0.4;
  srv.request.polygonal_area[0] = 0.2;
  srv.request.polygonal_area[1] = 0.3;
  srv.request.polygonal_area[3] = 0.4;
  srv.request.segment[0] = 0.6;
  srv.request.segment[1] = 0.7;
  srv.request.segment[2] = 0.8;
  srv.request.circ_area = vec;
  srv.request.radius = 0.4;
  srv.request.source = "und ein test";
  srv.request.sample =  p;*/
  ROS_INFO_STREAM("test");
  while(ros::ok())
    {
    
      if(client.call(srv))
	{  
	  ROS_INFO_STREAM("MSG IS:" << srv.request.selected << srv.request.type);

//"<< srv.response.agent 
	  //	  << srv.response.command 
	  //		  << srv.response.type);
	  //<< srv.response.gesture); 
			  //<< srv.response.gps);
	}else 
	{
	  ROS_ERROR("Failed to call service show_the_string");
	  return 1;
	}
      r.sleep();
     
    }
  // else
  //   {
  //  ROS_ERROR("Failed to call service show_the_string");
  // return 1;

  return 0;
}
