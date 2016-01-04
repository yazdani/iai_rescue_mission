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
#include "instruct_mission/multimodal_msgs.h"
#include "instruct_mission/multimodal_values.h"
#include <cstdlib>
#include "geometry_msgs/Pose.h"
#include "geometry_msgs/Vector3.h"
#include "std_msgs/Float64.h"

int main(int argc, char **argv)
{
  ros::init(argc, argv, "multimodal_cmd_client");
 
 ros::NodeHandle n;
 ros::ServiceClient client = n.serviceClient<instruct_mission::multimodal_msgs>("multimodal_cmd");
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
 dir.push_back(14);
 dir.push_back(1);
 dir.push_back(0);
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

 
 srv.request.selected = "blue hawk";
 srv.request.type = "Go";
 srv.request.command = "Go right of this tree";
 srv.request.data = 0.2;
 srv.request.direction = dir;
 srv.request.location = loc;
 srv.request.confidence = conf;
 srv.request.polygonal_area = poly;
 srv.request.segment = seg;
 srv.request.circ_area = vec;
 srv.request.radius = 0.2;
 srv.request.source = "gesture";
 srv.request.sample = p;

if (client.call(srv))
  {
    ROS_INFO_STREAM(srv.response.trans_cmd);
  }
 else
   {
     ROS_ERROR("Failed: maybe you have to start the server");
     return 1;
   }
 
 return 0;
}
