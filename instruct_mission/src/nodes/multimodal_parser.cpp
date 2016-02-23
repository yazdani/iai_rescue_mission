#include "ros/ros.h"
#include "instruct_mission/multimodal_parser.h"
#include <stdlib.h>
#include <iostream>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include "err.h"
#include "ros/ros.h"
#include "instruct_mission/multimodal_srv.h"
#include "instruct_mission/multimodal_values.h"
#include "instruct_mission/multimodal_lisp.h"
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


int sockfd, newsockfd, portno, clilen;
char buffer[512];
struct sockaddr_in serv_addr, cli_addr;
int  no;

using namespace std;

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

bool parser(instruct_mission::multimodal_parser::Request  &req,
         instruct_mission::multimodal_parser::Response &res)
{

  string cmd_interpreted;
  ROS_INFO_STREAM(req.goal);
  cmd_interpreted =  interpretCommand(req.goal);

  res.result = cmd_interpreted;
  return true;
}

int main(int argc, char **argv)
{

  ros::init(argc, argv, "parse_instruction");
  ros::NodeHandle n;

 ROS_INFO_STREAM("Wait for Parser!");
 
std :: string cmd = "gnome-terminal -x sh -c 'cd /home/yazdani/work/diarc_ws/smallade_w_lang; ./ant run-registry -Df=config/sherpa_config/sherpa.config'&"; 

 system (cmd.c_str ());
 sockfd = socket(AF_INET, SOCK_STREAM, 0);
   if (sockfd < 0) {
      perror("ERROR opening socket");
      exit(1);
   }
   ROS_INFO_STREAM("HELLO");

    int reuse = 1;
    if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, (const char*)&reuse, sizeof(reuse)) < 0)
      perror("setsockopt(SO_REUSEADDR) failed");

  
   bzero((char *) &serv_addr, sizeof(serv_addr));
   portno = 1234;
   serv_addr.sin_family = AF_INET;
   ROS_INFO_STREAM("HELLO2");
   serv_addr.sin_addr.s_addr = INADDR_ANY;
   serv_addr.sin_port = htons(portno);
   ROS_INFO_STREAM("HELLO3");
   if (bind(sockfd, (struct sockaddr *) &serv_addr, sizeof(serv_addr)) < 0) {
      perror("ERROR on binding");
      exit(1);
   }
   ROS_INFO_STREAM("HELLO4");
   listen(sockfd,5);
   clilen = sizeof(cli_addr);
   
   newsockfd = accept(sockfd, (struct sockaddr *)&cli_addr, (socklen_t*)&clilen);
	   ROS_INFO_STREAM("HELLO5");
   if (newsockfd < 0) {
      perror("ERROR on accept");
      exit(1);
   }
    ROS_INFO_STREAM("HELLO6");
    ros::Duration(0.5).sleep(); 
   ROS_INFO_STREAM("Parser registered!");


       ros::ServiceServer service = n.advertiseService("tldl_parser", parser);
       ROS_INFO_STREAM("Ready to parse the sentence?");

       ROS_INFO_STREAM("Ende1");

     ros::spin();

  close(sockfd);

  return 0;
}
