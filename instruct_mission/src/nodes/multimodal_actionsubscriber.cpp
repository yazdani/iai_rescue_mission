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
#include "instruct_mission/multimodal_srv.h"
#include "instruct_mission/multimodal_values.h"
#include "instruct_mission/multimodal_lisp.h"
#include "instruct_mission/multimodal_parser.h"
#include "mhri_msgs/multimodal_action.h"
#include "mhri_msgs/multimodal.h"
#include "mhri_srvs/multimodal_srv.h"

//#include "agent_mission/GeniusMsg.h"
#include <iostream>
#include <vector>
#include <string>
#include <sstream>
#include <iterator>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdio.h>
#include <string.h>
#include "ros/ros.h"
#include "std_msgs/String.h"
#include "std_msgs/Float64.h"
#include "geometry_msgs/Transform.h"
#include "geometry_msgs/PoseStamped.h"
#include "geometry_msgs/Twist.h"
#include <gazebo_msgs/SetModelState.h>
#include <gazebo_msgs/GetModelState.h>
#include <gazebo_msgs/GetPhysicsProperties.h>
#include <geographic_msgs/GeoPose.h>
#include <sstream>

//Hector in simulation

/*#include <actionlib/client/simple_action_client.h>
#include <actionlib/client/terminal_state.h>
#include <quadrotor_controller/cmdVelAction.h>
#include <geometry_msgs/Pose.h>*/

using namespace std;

const float ANTON = 6378137;    
const float BERTA = 6356752.3124;
const float LAT = 44.153278;    
const float LON = 12.241426;
const float ALT = 41.0;
int pointer = 5;
int sockfd, newsockfd, portno, clilen;
char buffer[512];
struct sockaddr_in serv_addr, cli_addr;
int  no;
string cmd_interpreted;
string cmd_type;
ros::Publisher pub;

mhri_msgs::multimodal multi;
mhri_msgs::multimodal malti;

int var = 0;
geometry_msgs::Transform transforming;

void multimodalCallback(const mhri_msgs::multimodal::ConstPtr& msg)
{
  var = 0;
  ROS_INFO_STREAM("GO INTO MULTIMODALCALLBACK METHOD");
  std::cout << msg << std::endl;
  multi.action = msg->action;
  

  ROS_INFO_STREAM("HAHA IN DA FACE");
}

std::vector<float> wgs84ToNed(float latitude, float longitude, float altitude, float latitude_home, float longitude_home, float altitude_home)
{
  double euler = sqrt(1-pow(BERTA,2)/pow(ANTON,2));
  double lat_rad = latitude*M_PI/180.0f;
  double lon_rad = longitude*M_PI/180.0f;
  double lat_home_rad = latitude_home*M_PI/180.0f;
  double lon_home_rad = longitude_home*M_PI/180.0f;
  double radius = ANTON/sqrt(1-pow(euler,2)*pow(sin(lat_home_rad),2));
  double x,y,z;
  x = (lat_rad-lat_home_rad)*radius;
  y = (lon_rad-lon_home_rad)*radius*cos(lat_home_rad);
  z = altitude - altitude_home;
  x = -x;
  y = -y;
  std::vector<float> vec;
  vec.push_back(x);
  vec.push_back(y);
  vec.push_back(z);
  return vec;
}

std::vector<float> nedToWgs84(float x, float y, float z, float latitude_home, float longitude_home, float altitude_home)
{
  x = -x;
  y = -y;
  double euler = sqrt(1-pow(BERTA,2)/pow(ANTON,2));
  double lat_home_rad = latitude_home*M_PI/180.0f;
  double lon_home_rad = longitude_home*M_PI/180.0f;
  double radius = ANTON/sqrt(1-pow(euler,2)*pow(sin(lat_home_rad),2));
  double latitude = x/radius*180.0f/M_PI + latitude_home;
  double longitude = y/radius*180.0f/M_PI/cos(lat_home_rad) + longitude_home;
  double altitude = altitude_home + z;
  std::vector<float> vec;
  vec.push_back(latitude);
  vec.push_back(longitude);
  vec.push_back(altitude);
  return vec;
}



string checkCommandType(string cmd)
{
  std::stringstream ss(cmd);
  std::istream_iterator<std::string> begin(ss);
  std::istream_iterator<std::string> end;
  std::vector<std::string> vstrings(begin, end);
  string elem = vstrings.front();				    
  
  if(elem.compare("Is") == 0 || elem.compare("is") == 0 || elem.compare("IS") == 0 ||
     elem.compare("Are") == 0 || elem.compare("are") == 0 || elem.compare("ARE") == 0 ||
     elem.compare("Do") == 0 || elem.compare("do") == 0 || elem.compare("DO") == 0 ||
     elem.compare("Does") == 0 || elem.compare("does") == 0 || elem.compare("DOES") == 0 ||
     elem.compare("Have") == 0 || elem.compare("have") == 0 || elem.compare("HAVE") == 0 ||
     elem.compare("Has") == 0 || elem.compare("has") == 0 || elem.compare("HAS") == 0 ||
     elem.compare("How") == 0 || elem.compare("how") == 0 || elem.compare("HOW") == 0 ||
     elem.compare("What") == 0 || elem.compare("what") == 0 || elem.compare("WHAT") == 0 ||
     elem.compare("Which") == 0 || elem.compare("which") == 0 || elem.compare("WHICH") == 0 ||
     elem.compare("Where") == 0 || elem.compare("where") == 0 || elem.compare("WHERE") == 0 ||
     elem.compare("Who") == 0 || elem.compare("who") == 0 || elem.compare("WHO") == 0 ||
     elem.compare("Whose") == 0 || elem.compare("whose") == 0 || elem.compare("WHOSE") == 0 ||
     elem.compare("Why") == 0 || elem.compare("why") == 0 || elem.compare("WHY") == 0 )
    return "question";
  
  if(elem.compare("Give") == 0 || elem.compare("give") == 0 || elem.compare("GIVE") == 0 ||
     elem.compare("Show") == 0 || elem.compare("show") == 0 || elem.compare("SHOW") == 0)
    return "query";
  if(elem.compare(" ") == 0 || elem.compare("") == 0)
    return "";
  else
    return "order";
}

string interpretCommand(string cmd)
{
  ROS_INFO_STREAM("interpretCommand");  
 /* If connection is established then start communicating */
  bzero(buffer,512);
  string cmd2 = cmd+'\n';
  cmd2.copy(buffer, 512);
  
  no = write(newsockfd,buffer,sizeof(buffer));
  
   if (no < 0) {
     perror("ERROR writing to socket");
     exit(1);
   }
   no = read( newsockfd,buffer,512 );
   
   if (no < 0) {
     perror("ERROR reading from socket");
     exit(1);
   }
   ROS_INFO_STREAM("End interpretCommand");  
   ROS_INFO_STREAM(buffer);  
   return buffer;
}

/** 
  * This is the callback function of the server!
  *
  *
  *
  *
 **/
void startChecking(const mhri_msgs::multimodal_action::ConstPtr& msg)
{
  ROS_INFO_STREAM("Inside: startChecking");
  ros::Rate looprate(10);

  // while(pointer > 0)
  //  {
  //    pointer--;
  //    ros::spinOnce();
  //    looprate.sleep();
  //  }

  var = 1;
  cmd_type = checkCommandType(msg->command);
  string str = msg->command;
  float data = msg->data;
  std::cout << str << std::endl;  
  if(str.compare("Go right") == 0 || str.compare("Go left") == 0 || 
     str.compare("Go up") == 0 || str.compare("Take off") == 0 ||
     str.compare("Go down") == 0 || str.compare("Rotate") == 0)
    {
      std::cout << "This is not working" << std::endl;
      // res.interpretation = malti;
    }else
    {
      
      //Calling the tldl parser as service
      std::cout << "---" << std::endl;  
      ros::NodeHandle new_parser;
      ros::ServiceClient client_parser = new_parser.serviceClient<instruct_mission::multimodal_parser>("tldl_parser");
      instruct_mission::multimodal_parser srv_parser;
      srv_parser.request.goal = msg->command;
      if (client_parser.call(srv_parser))
	{
	  ROS_INFO_STREAM("Waiting for the TLDL parser");
	}
      else
	{
	  ROS_ERROR("Failed to call the service in TLDL parser");
	  return;
	}
      
      
      ROS_INFO_STREAM("Parsing done!");
      ros::Rate loop_rate(10);
      instruct_mission::multimodal_lisp srv;
      srv.request.selected = msg->selected;
      srv.request.command = srv_parser.response.result;
      srv.request.type = cmd_type;
      srv.request.gesture.push_back(msg->direction[0]);
      srv.request.gesture.push_back(msg->direction[1]);
      srv.request.gesture.push_back(msg->direction[2]);
      std::vector<float> vect;
      vect.push_back(msg->location[0]);
      vect.push_back(msg->location[1]);
      vect.push_back(msg->location[2]);
      srv.request.location = wgs84ToNed(vect[0], vect[1], vect[2], LAT, LON, ALT );
      ROS_INFO_STREAM("Lisp");
      // calling lisp and waiting for the result
      ros::NodeHandle new_pub;
      std_msgs::Bool tbool;
      tbool.data = false;
      ros::ServiceClient client = new_pub.serviceClient<instruct_mission::multimodal_lisp>("multimodal_lisp");  
      ROS_INFO_STREAM("Lisptodo");
      if (client.call(srv))
	{
	  ROS_INFO_STREAM("Waiting for lisp!");
	}
      else
	{
	  ROS_ERROR("Failed to call the service in lisp");
	  return;
	}
      ROS_INFO_STREAM("End of using lisp");
      mhri_msgs::multimodal multi;
      ros::Rate loop_ratE(5);
      ROS_INFO_STREAM("MOIIIN");
      std::cout << multi <<std::endl;
      multi = srv.response.interpretation;
      std_msgs::String drum;
      
      tbool.data = false;
      for(int i = 0; i < multi.action.size(); i++)
	{
	  drum = multi.action[i].error;
	  ROS_INFO_STREAM(multi.action[i].error);
	  if(drum.data.compare("") != 0)
	    multi.action[i].value = tbool;
	}
      mhri_msgs::interpretation interp;
      instruct_mission::multimodal_lisp intero;
      ROS_INFO_STREAM(srv.response.interpretation);
      //    pub = n_pub.advertise<std_msgs::String>("multimodal_publisher",1000);
      int index = 5;
   
      ROS_INFO_STREAM(multi);
      pub.publish(multi);
	  //	  index--;
	  //  ros::spinOnce();
	  //  loop_ratE.sleep();
	  //	}
       
	  ROS_INFO_STREAM("end the multimodalcallback");
    }
}

int main(int argc, char **argv)
{
  ros::init(argc, argv, "multimodal_cmd_subscriber");
  //  ros::init(argc, argv, "multimodal_cmd_publisher2");
 
  ros::NodeHandle n_sub;
  ros::NodeHandle n_pub;
  // ros::NodeHandle n_pub;
  ros::Subscriber sub = n_sub.subscribe("CREATE/multimodal_cmd",1000, startChecking);
  ROS_INFO_STREAM("Wait for Instruction!");
  pub = n_pub.advertise<mhri_msgs::multimodal>("UNIHB/interpretation",1000);
  ros::spin();
   
  return 0;
}
