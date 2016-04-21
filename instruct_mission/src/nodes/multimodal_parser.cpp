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
#include <sys/types.h>
#include <unistd.h>
#include <boost/algorithm/string.hpp>

int sockfd, newsockfd, portno, clilen;

struct sockaddr_in serv_addr, cli_addr;


using namespace std;

vector<string> splitString(string input, string delimiter)
{
  vector<string> output;
  
  split(output, input, is_any_of(delimiter), token_compress_on);
  
  return output;
}

string without_brakets(string value)
{
  
  std::vector<string> no_brackets = splitString(value, ";");
  std::vector<string> new_string;
  string s2 = "<=inside";
  std::string token;
  std::string token1;
  std::vector<string> cmds;
  std::vector<string> vec;
  
  
  //move(right,tree)<=inside(left,house) --> move(right,tree);move(left,house)
  for(int i = 0; i < no_brackets.size(); i++)
    {
      if(strstr(no_brackets[i].c_str(),s2.c_str())) //inside
	{
	  token = no_brackets[i].substr(0, no_brackets[i].find("(")); //gives first action
	  token = ";"+token;
	  boost::replace_all(no_brackets[i],"<=inside",token);
	}    
      
      new_string.push_back(no_brackets[i]);
    }
  
  //move(right,house);move(left,tree) --> split into two vectors
  int pointers = 0;
  for(int j = 0; j < new_string.size(); j++)
    {
      std::vector<string> test = splitString(new_string[j], ";");
      
      if(test.size() > 1)
	{
	  while(pointers < test.size())
	    {
	      cmds.push_back(test[pointers]);
	      pointers++;
	    }
	  pointers = 0;
	}else
	{
	  cmds.push_back(new_string[j]);
	}
      
    }
  
  std::vector<string> new_vec;
  for(int index = 0; index < cmds.size(); index++)
    {
      boost::replace_all(cmds[index],"pointed_at(","pointed_at,");
      boost::replace_all(cmds[index],"broken(","broken,");
      boost::replace_all(cmds[index],"big(","big,");
      boost::replace_all(cmds[index],"small(","small,");
      boost::replace_all(cmds[index],"first(","first,");
      boost::replace_all(cmds[index],"second(","second,");
      boost::replace_all(cmds[index],"third(","third,");
      boost::replace_all(cmds[index],"fourth(","fourth,");
      boost::replace_all(cmds[index],"last(","last,");
      boost::replace_all(cmds[index],"))",")");
    }
  
  for(int sup = 0; sup < cmds.size(); sup++)
    {
      std::vector<string> testing = splitString(cmds[sup], ",");
      if(testing.size() == 1)
	{
	  boost::replace_all(cmds[sup],"picture)","nil,nil,picture)");
	  boost::replace_all(cmds[sup],"right)","right,nil,nil)");
	  boost::replace_all(cmds[sup],"left)","left,nil,nil)");
	  boost::replace_all(cmds[sup],"ahead)","ahead,nil,nil)");
	}else 
	if(testing.size() == 2)
	  {
	    boost::replace_all(cmds[sup],",",",nil,");
	  }
    }
  string toktok = "";
  
  for(int pointer = 0; pointer < cmds.size(); pointer++)
    {
      if(pointer != cmds.size()-1)
	{
	  toktok = toktok + cmds[pointer]+ ";";
	}else
	{
	  toktok = toktok + cmds[pointer];
	}
    }
  return toktok;
}


string interpretCommand(string cmd)
{
  int  no = 0;
  char buffer[512] = {0};
  ROS_INFO_STREAM("interpretCommand");  
  ROS_INFO_STREAM(cmd);
  ROS_INFO_STREAM(sizeof(buffer));
  ROS_INFO_STREAM("newsockfd");
  ROS_INFO_STREAM(newsockfd);
  ROS_INFO_STREAM("What is buffer");
  ROS_INFO_STREAM(buffer);
  /* If connection is established then start communicating */
  bzero(buffer,512);
  string cmd2 = cmd+'\n';
  ROS_INFO_STREAM("command2");
  ROS_INFO_STREAM(sizeof(cmd2));
  ROS_INFO_STREAM(cmd2);
  cmd2.copy(buffer, 512);
  ROS_INFO_STREAM("WAS");
  ROS_INFO_STREAM(buffer);

  no = write(newsockfd,buffer,sizeof(buffer));
  ROS_INFO_STREAM(no);

   if (no < 0) {
     perror("ERROR writing to socket");
     exit(1);
   }
   no = 0;
   ROS_INFO_STREAM(no);
   no = read( newsockfd,buffer,512 );
   ROS_INFO_STREAM(no);
   ROS_INFO_STREAM("INBETWEEN");
   ROS_INFO_STREAM(newsockfd);
   if (no < 0) {
     perror("ERROR reading from socket");
     exit(1);
   }
   ROS_INFO_STREAM("End interpretCommand");  
   ROS_INFO_STREAM(buffer); 
   
   string ret = "Parsing not possible";
   if(ret.compare(buffer) != 0)
     return buffer;
	 
   return "";
}

bool parser(instruct_mission::multimodal_parser::Request  &req,
         instruct_mission::multimodal_parser::Response &res)
{
  ROS_INFO_STREAM("parser");
  string cmd_interpreted = "";
  ROS_INFO_STREAM(req.goal);
  cmd_interpreted =  interpretCommand(req.goal);
  ROS_INFO_STREAM("cmd_interpreted");
  ROS_INFO_STREAM(cmd_interpreted);
  res.result = without_brakets(cmd_interpreted);
  return true;
}

int main(int argc, char **argv)
{

  ros::init(argc, argv, "parse_instruction");
  ros::NodeHandle n;

 ROS_INFO_STREAM("Wait for Parser!");
  close(sockfd);
 // system("killall gnome-terminal");

 //std::string cmd ="gnome-terminal --command ls";

//--working-directory=/home/yazdani/work/diarc_ws/smallade_w_lang -e './ant run-registry -Df=config/sherpa_config/sherpa.config&'";
//  gnome-terminal -x sh -c ";
// 'cd /home/yazdani/work/diarc_ws/diarc_parser/smallade_w_lang; ./ant run-registry -Df=config/sherpa_config/sherpa.config'&"; 

 system("gnome-terminal --working-directory=/home/sherpa/work/ros/indigo/unihb_ws/src/diarc_parser/smallade_w_lang  --command \"./ant run-registry -Df=config/sherpa_config/sherpa.config\" &");//cmd.c_str());

 sockfd = socket(AF_INET, SOCK_STREAM, 0);
   if (sockfd < 0) {
      perror("ERROR opening socket");
      exit(1);
   }
   ROS_INFO_STREAM("HELLO");

    int reuse = 1;
    if (setsockopt(sockfd, SOL_SOCKET, (SO_REUSEPORT | SO_REUSEADDR), (const char*)&reuse, sizeof(reuse)) < 0)
      perror("setsockopt(SO_REUSEADDR) failed");

   std::cout << "new _ getppid(): " << getppid() << std::endl;
   std::cout << "new _ getpid(): " << getpid() << std::endl;
      
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
   ROS_INFO_STREAM("HELLO41");
   clilen = sizeof(cli_addr);
   ROS_INFO_STREAM("HELLO42");
   std::cout << sockfd << std::endl;
    std::cout << newsockfd << std::endl;
    //   if(sockfd > 0)
    //  sockfd = 0;
   newsockfd = accept(sockfd, (struct sockaddr *)&cli_addr, (socklen_t*)&clilen);
   std::cout << "end " <<sockfd << std::endl;
   ROS_INFO_STREAM("HELLO5");
   if (newsockfd < 0) {
      perror("ERROR on accept");
      exit(1);
   }
    ROS_INFO_STREAM("HELLO6");
    //  system("killall gnome-terminal");//cmd.c_str());
    ros::Duration(0.5).sleep(); 
    ROS_INFO_STREAM("Parser registered!");

   
    ros::ServiceServer service = n.advertiseService("tldl_parser", parser);
    ROS_INFO_STREAM("Ready to parse the sentence?");
     std::cout << newsockfd << std::endl;
    ROS_INFO_STREAM("Ende1");
    ros::spin();
    

  return 0;
}
