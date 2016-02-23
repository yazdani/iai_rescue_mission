/*
 * Copyright (c) 2015, Fereshta Yazdani <yazdani@cs.uni-bremen.de>
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the Institute for Artificial Intelligence/
 *       Universitaet Bremen nor the names of its contributors may be used to 
 *       endorse or promote products derived from this software without 
 *       specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#include "ros/ros.h"
#include "mhri_srvs/multimodal_srv.h"
#include "mhri_msgs/multimodal_action.h"
#include "instruct_mission/multimodal_values.h"
#include <cstdlib>
#include "geometry_msgs/Pose.h"
#include "geometry_msgs/Vector3.h"
#include "std_msgs/Float64.h"
#include "mhri_msgs/point3d.h"
int main(int argc, char **argv)
{
  ros::init(argc, argv, "multimodal_cmd_client");
 
 ros::NodeHandle n;
 ros::ServiceClient client = n.serviceClient<mhri_srvs::multimodal_srv>("multimodal_cmd");
 mhri_srvs::multimodal_srv srv;
 mhri_msgs::multimodal_action action;
 geometry_msgs::Pose p;
 p.position.x =  41.000;
 p.position.y = 12.1233;
 p.position.z = 41.000;
 p.orientation.x = 0;
 p.orientation.y = 0;
 p.orientation.z = 0;
 p.orientation.w = 1;
 std::vector<float> dir;
 dir.push_back(1);
 dir.push_back(0);
 dir.push_back(0);
 std::vector<float> loc;
 loc.push_back(0.3);
 loc.push_back(0.2);
 loc.push_back(0.1);
 mhri_msgs::circumference vec;
 std::vector<mhri_msgs::point3d> poly;
 float conf = 0.5;
 std::vector<mhri_msgs::point3d> seg;
 
 
 action.selected = "blue hawk";
 action.type = "Go";
 action.command = "Go right of this mountain";
 action.data = 2;
 action.direction[0] = dir[0.8];// = dir;
 action.direction[1] = dir[0];// = dir;
 action.direction[2] = dir[0];// = dir;
 action.location[0] = loc[0];
 action.location[1] = loc[1];
 action.location[2] = loc[2];
 action.confidence = conf;
 action.polygonal_area = poly;
 action.segment = seg;
 action.circ_area = vec;
 action.source = "gesture";
 //action.sample = p;

 srv.request.action = action;
if (client.call(srv))
  {
    ROS_INFO_STREAM(srv.response.interpretation);
  }
 else
   {
     ROS_ERROR("Failed: maybe you have to start the server");
     return 1;
   }
 
 return 0;
}
