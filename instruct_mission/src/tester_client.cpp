#include "ros/ros.h"
#include "instruct_mission/multimodal_lisp.h"
#include <cstdlib>

int main(int argc, char **argv)
{
  ros::init(argc, argv, "multimodal_lisp_client");
  ros::NodeHandle n;
  ros::ServiceClient client = n.serviceClient<instruct_mission::multimodal_lisp>("multimodal_lisp");
  instruct_mission::multimodal_lisp srv;
  srv.request.selected = "agent";
  ROS_INFO_STREAM("heellooo");
  srv.request.command = "move(right, pointed_at(tree))";
 ROS_INFO_STREAM("heellooo6");
  srv.request.type = "order";
  std::vector<float> vgesture;
  vgesture.push_back(1);
  vgesture.push_back(0);
  vgesture.push_back(14);
 ROS_INFO_STREAM("heellooo3");
  srv.request.gesture.push_back(vgesture[0]);
  srv.request.gesture.push_back(vgesture[1]);
  srv.request.gesture.push_back(vgesture[2]);
  std::vector<float> mgesture;
  mgesture.push_back(1);
  mgesture.push_back(0);
  mgesture.push_back(14);
 ROS_INFO_STREAM("heellooo5");
  srv.request.location.push_back(mgesture[0]);
  srv.request.location.push_back(mgesture[1]);
  srv.request.location.push_back(mgesture[2]);
 ROS_INFO_STREAM("heelloodddo");
  if (client.call(srv))
  {
    ROS_INFO_STREAM(srv.response.mlisp);
  }
  else
  {
    ROS_ERROR("Failed to call service add_two_ints");
    return 1;
  }

  return 0;
}
