#include "ros/ros.h"
#include "instruct_mission/multimodal_parser.h"
#include <cstdlib>

int main(int argc, char **argv)
{
  ros::init(argc, argv, "client_paser");
 
  ros::NodeHandle n;
  ros::ServiceClient client = n.serviceClient<instruct_mission::multimodal_parser>("tldl_parser");
  instruct_mission::multimodal_parser srv;
  srv.request.goal = "Go right of that tree";
  if (client.call(srv))
  {
    ROS_INFO_STREAM(srv.response.result);
  }
  else
  {
    ROS_ERROR("Failed to call service tldl_parser");
    return 1;
  }

  return 0;
}
