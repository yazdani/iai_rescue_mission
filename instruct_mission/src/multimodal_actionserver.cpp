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
#include <sstream>

using namespace std;

int sockfd, newsockfd, portno, clilen;
char buffer[512];
struct sockaddr_in serv_addr, cli_addr;
int  no;
string cmd_interpreted;
string cmd_type;
ros::Publisher pub;
mhri_msgs::multimodal multi;
int var = 0;

void multimodalCallback(const mhri_msgs::multimodal::ConstPtr& msg)
{
  var = 0;
  std::cout << msg << std::endl;
  //  multi.action = msg->action;
  

  ROS_INFO_STREAM("HAHA IN DA FACE");
}

/*
 * Publishing the interpreted instruction through a topic an interpreted instruction.
 * @param string agent: agent which is performing the task
 * @param string command: interpreted instruction
 * @param string type: command type, e.g. order, question etc.
 * @param vector<float> gesture: pointing gesture of the busy genius
 * @param vector<float> gps: gps position of the busy genius 
 */
void sendAsTopic(string agent, string command, string Icommand, string type, std::vector<float> gesture , std::vector<float> gps)
{
  ROS_INFO_STREAM("inside sendAsTopic");
  ROS_INFO_STREAM(Icommand);
  instruct_mission::multimodal_values mvalue;
  mvalue.agent = agent;
  mvalue.command = command;
  mvalue.Icommand = Icommand;
  mvalue.type = type;
  mvalue.gesture.push_back(gesture[0]);
  mvalue.gesture.push_back(gesture[1]);
  mvalue.gesture.push_back(gesture[3]);
  std::vector<float> gps_data;
  mvalue.gps.push_back(gps[0]);
  mvalue.gps.push_back(gps[1]);
  mvalue.gps.push_back(gps[2]);  
  ROS_INFO_STREAM(Icommand);  
  pub.publish(mvalue);
}

/*
 * Checking and defining the instruction type, e.g. order or question
 * @param string cmd: instruction to be checked
 * @return string: returning the instruction type 
 */
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

/*
 * Interpreting the instruction via a parser
 * @param string cmd: instruction which has to be interpreted
 * @return string: returning the interpreted instruction
 */
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

/*
 * After the registration of the Client the Server is gonna start some processes in order to 
 * interpret the instruction into the context of the task.
 * @param Request: service which is comming from the client
 * @param Response: Service which is sent at the end
 * @return bool: Depending of the successful processing true/false
 */
bool startChecking(instruct_mission::multimodal_srv::Request &req,
		   instruct_mission::multimodal_srv::Response &res)
{
  ROS_INFO_STREAM("startChecking");
  var = 1;
  cmd_type = checkCommandType(req.command);
  cmd_interpreted =  interpretCommand(req.command);
  //res.agent = req.selected;
  //res.init_cmd = req.command;
  //res.cmd_type = cmd_type;
  //res.trans_cmd = cmd_interpreted; 
  ROS_INFO_STREAM("Send command to sendAsTopic");
  ROS_INFO_STREAM(cmd_interpreted);
  sendAsTopic(req.selected, req.command, cmd_interpreted, cmd_type, req.direction, req.location);
  ROS_INFO_STREAM("end startChecking");
  ros::NodeHandle new_pub;
  ROS_INFO_STREAM("start the multimodalcallback");
  ROS_INFO_STREAM(multi);
  while(var == 1){
    ros::Subscriber sub = new_pub.subscribe("sendMsgToServer", 1000, multimodalCallback);
  }
  res.multi = multi;
  ROS_INFO_STREAM("end the multimodalcallback");
  return true;
}


/*
 * main function
 */
int main(int argc, char **argv)
{
   ROS_INFO_STREAM("Wait for Parser!");
 
   sockfd = socket(AF_INET, SOCK_STREAM, 0);
   
   if (sockfd < 0) {
      perror("ERROR opening socket");
      exit(1);
   }

   bzero((char *) &serv_addr, sizeof(serv_addr));
   portno = 1234;
   serv_addr.sin_family = AF_INET;
   serv_addr.sin_addr.s_addr = INADDR_ANY;
   serv_addr.sin_port = htons(portno);

   if (bind(sockfd, (struct sockaddr *) &serv_addr, sizeof(serv_addr)) < 0) {
      perror("ERROR on binding");
      exit(1);
   }

   listen(sockfd,5);
   clilen = sizeof(cli_addr);
   
   newsockfd = accept(sockfd, (struct sockaddr *)&cli_addr, (socklen_t*)&clilen);
	
   if (newsockfd < 0) {
      perror("ERROR on accept");
      exit(1);
   }
 
  ROS_INFO_STREAM("Parser registered!");

  ros::init(argc, argv, "multimodal_cmd_server");
  ros::init(argc, argv, "ListenToTheTopic");
  ros::NodeHandle n;
  ros::NodeHandle n_pub;

  pub = n_pub.advertise<instruct_mission::multimodal_values>("many_msgs",1000);
  ros::ServiceServer service = n.advertiseService("multimodal_cmd", startChecking);
  ROS_INFO_STREAM("Wait for Instruction!");
  ros::spin();
   
  return 0;
}
