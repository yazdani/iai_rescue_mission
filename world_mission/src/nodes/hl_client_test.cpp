#include "ros/ros.h"
#include <iostream>
#include "boost/thread.hpp"

//---multimodal header
#include <actionlib/client/simple_action_client.h>
#include "mhri_srvs/multimodal_srv.h"
#include "mhri_msgs/multimodal.h"
//---

//---ros msgs
#include "geometry_msgs/Point.h"
//---

using namespace std;

class hl_client {

	public:
		hl_client();
		void run();
		void interaction();
		void sherpa_looking_cb( geometry_msgs::Point p);

	private:
		ros::NodeHandle _nh;
		ros::Subscriber _sherpa_looking_sub;		
		geometry_msgs::Point looking_vector;
};


hl_client::hl_client() {
	_sherpa_looking_sub = _nh.subscribe("/CREATE/sherpa_looking", 0, &hl_client::sherpa_looking_cb, this);
}

void hl_client::sherpa_looking_cb( geometry_msgs::Point p ) {
	looking_vector = p;
}

void hl_client::interaction() {
	
	mhri_srvs::multimodal_srv srv;	
 	ros::ServiceClient client = _nh.serviceClient<mhri_srvs::multimodal_srv>("multimodal_cmd");

	do {
   cout << "Press a key call the service..." << endl;
 	} while (cin.get() != '\n');

  //---Fill multimodal_action field
  srv.request.action.selected = "red_hawk";

  srv.request.action.command = "go close to this house";
  srv.request.action.direction[0] = looking_vector.x;
  srv.request.action.direction[1] = looking_vector.y;
  srv.request.action.direction[2] = looking_vector.z;
  //---

  cout << srv.request.action.direction[0] << " " << srv.request.action.direction[1] << " " << srv.request.action.direction[2] << endl;

  if (client.call(srv)) {
    ROS_INFO("Called!");    
    cout << "received: " << srv.response.interpretation.action.size() << " interpretation" << endl;
    for( int i=0; i<srv.response.interpretation.action.size() ; i++ ) {
    	cout << i << " " << srv.response.interpretation.action[i].type << " " << srv.response.interpretation.action[i].type << endl;
    }
  }
  else {
    ROS_ERROR("Failed to call service");
    exit(0);
  }

  exit(0);
}

void hl_client::run() {

  boost::thread interaction_t( &hl_client::interaction, this);
  ros::spin();

}


int main( int argc, char** argv ) {


	ros::init( argc, argv, "hl_cient_test");
	hl_client client;
	client.run();
	
	return 0;
}