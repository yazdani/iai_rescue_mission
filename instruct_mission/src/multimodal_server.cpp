#include "ros/ros.h"
#include "instruct_mission/multimodal_msgs.h"
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

#define PORT 1234
#define BUF_SIZE 1024

using namespace std;
string checkCommandType(string);

int sockfd, newsockfd, portno, clilen;
char buffer[BUF_SIZE];
struct sockaddr_in serv_addr, cli_addr;
int  no;

string checkCommandType(string s)
{ 
  std::stringstream ss(s);
  std::istream_iterator<std::string> begin(ss);
  std::istream_iterator<std::string> end;
  std::vector<std::string> vstrings(begin, end);
  string elem = vstrings.front();				    
  
  if(elem.compare("Is") == 0 ||
     elem.compare("is") == 0 ||
     elem.compare("IS") == 0 ||
     elem.compare("Are") == 0 ||
     elem.compare("are") == 0 ||
     elem.compare("ARE") == 0 ||
     elem.compare("Do") == 0 ||
     elem.compare("do") == 0 ||
     elem.compare("DO") == 0 ||
     elem.compare("Does") == 0 ||
     elem.compare("does") == 0 ||
     elem.compare("DOES") == 0 ||
     elem.compare("Have") == 0 ||
     elem.compare("have") == 0 ||
     elem.compare("HAVE") == 0 ||
     elem.compare("Has") == 0 ||
     elem.compare("has") == 0 ||
     elem.compare("HAS") == 0 ||
     elem.compare("How") == 0 ||
     elem.compare("how") == 0 ||
     elem.compare("HOW") == 0 ||
     elem.compare("What") == 0 ||
     elem.compare("what") == 0 ||
     elem.compare("WHAT") == 0 ||
     elem.compare("Which") == 0 ||
     elem.compare("which") == 0 ||
     elem.compare("WHICH") == 0 ||
     elem.compare("Where") == 0 ||
     elem.compare("where") == 0 ||
     elem.compare("WHERE") == 0 ||
     elem.compare("Who") == 0 ||
     elem.compare("who") == 0 ||
     elem.compare("WHO") == 0 ||
     elem.compare("Whose") == 0 ||
     elem.compare("whose") == 0 ||
     elem.compare("WHOSE") == 0 ||
     elem.compare("Why") == 0 ||
     elem.compare("why") == 0 ||
     elem.compare("WHY") == 0 )
    return "ask";
  else
    if(elem.compare(" ") == 0)
      return "NONE";
    else
      return "order";
}

string interpretCommand(string cmd)
{
   ROS_INFO_STREAM("in interpretCommand!");
   bzero(buffer,256);
   no = read( newsockfd,buffer,255 );
   
   if (no < 0) {
      perror("ERROR reading from socket");
      exit(1);
   }
   
   printf("Here is the message: %s\n",buffer);
   
 
   no = write(newsockfd,"I got your message",18);
   
   if (no < 0) {
      perror("ERROR writing to socket");
      exit(1);
   }
   ROS_INFO_STREAM(buffer);
   return buffer;  
}


bool startChecking(instruct_mission::multimodal_msgs::Request  &req,
		   instruct_mission::multimodal_msgs::Response &res)
{
  ROS_INFO_STREAM("lets start the game!");
  res.agent = req.selected;
  res.command = req.command;
  float test = req.direction[0];
  string cmd_type = checkCommandType(req.command);
  res.type = cmd_type;
  string cmd_interpreted = interpretCommand(req.command);
  res.command = cmd_interpreted;
  ROS_INFO_STREAM(cmd_type);
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
  /*
  int sockfd, newsockfd, portno, clilen;
  char buffer[BUF_SIZE];
  struct sockaddr_in serv_addr, cli_addr;
   int  no;
  */

  /* First call to socket() function */
   sockfd = socket(AF_INET, SOCK_STREAM, 0);

   if (sockfd < 0) {
      perror("ERROR opening socket");
      exit(1);
   }

   bzero((char *) &serv_addr, sizeof(serv_addr));
   portno = PORT;
 
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
   

   ros::init(argc, argv, "show_the_string_server");
   ros::NodeHandle n;

   ros::ServiceServer service = n.advertiseService("show_the_string", startChecking);
   ROS_INFO_STREAM("Wait for Client!");
   ros::spin();
   
   return 0;
}
