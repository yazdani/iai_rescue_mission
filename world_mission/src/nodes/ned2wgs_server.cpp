#include <ros/ros.h>
#include <tf/transform_broadcaster.h>
//#include <swri_transform_util/local_xy_util.h>
#include <gps_common/GPSFix.h>
#include <geographic_msgs/GeoPose.h>
#include "world_mission/Mywgs2ned_server.h"

const double A = 6378137;    //major semiaxis
const double B = 6356752.3124;    //minor semiaxis

const double ANTON = 6378137;    
const double BERTA = 6356752.3124;
const double LAT_HOME = 45.8431680924;//44.153278;
const double LON_HOME = 7.730888708211306;//12.241426;
const double ALT_HOME = 1580.0;

std::vector<double> nedToWgs84(double x, double y, double z, double LAT_HOME, double LON_HOME, double ALT_HOME)
{
  y = -y;
  //z = -z;
  double euler = sqrt(1-pow(BERTA,2)/pow(ANTON,2));
  //double lat_rad = latitude*M_PI/180.0f;
  //double lon_rad = longitude*M_PI/180.0f;
  double lat_home_rad = LAT_HOME*M_PI/180.0f;
  double lon_home_rad = LON_HOME*M_PI/180.0f;
  double radius = ANTON/sqrt(1-pow(euler,2)*pow(sin(lat_home_rad),2));
  double lat,lon,alt;
  lat = x/radius*180.0f/M_PI+LAT_HOME;
  lon = y/radius*180.0f/M_PI/cos(lat_home_rad) + LON_HOME;
  alt = ALT_HOME+z ;
  //std::cout <<"HAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALLLLLLLLLLLLLLOOOOOOOOOOOOOOOOOOOOOO "<< std::endl;
  //std::cout << lat << std::endl;
  // std::cout << lon << std::endl;
  // std::cout << alt << std::endl;
  std::vector<double> vec;
  vec.push_back(lat);
  vec.push_back(lon);
  vec.push_back(alt);
  return vec;
}

bool ned2wgs(world_mission::Mywgs2ned_server::Request  &req,
	     world_mission::Mywgs2ned_server::Response &res)
{
  std::vector<double> vec = nedToWgs84(req.data.position.x, req.data.position.y, req.data.position.z, LAT_HOME, LON_HOME, ALT_HOME);
  std::cout << vec[0] << std::endl;
  std::cout << vec[1] << std::endl;
  std::cout << vec[2] << std::endl;
 
  geometry_msgs::Pose po;
  po.position.x = vec[0];
  po.position.y = vec[1];
  po.position.z = vec[2];
  po.orientation.x = req.data.orientation.x;
  po.orientation.y = req.data.orientation.y;
  po.orientation.z = req.data.orientation.z;
  po.orientation.w = req.data.orientation.w;
  res.sum = po;

  return true;
}

int main(int argc, char** argv){
  ros::init(argc, argv, "myned2wgs_server");
  
  ros::NodeHandle n;
  ros::ServiceServer service = n.advertiseService("myned2wgs_server", ned2wgs);
  ROS_INFO("For ned.");
  ros::spin();
 
  return 0;
};
