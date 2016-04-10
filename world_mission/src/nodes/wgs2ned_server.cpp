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

std::vector<double> wgs84ToNed(double latitude, double longitude, double altitude, double latitude_home, double longitude_home, double altitude_home)
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
  z = altitude_home - altitude;
   y = -y;
  z = -z;
  std::vector<double> vec;
  vec.push_back(x);
  vec.push_back(y);
  vec.push_back(z);
  return vec;
}

bool wgs2ned(world_mission::Mywgs2ned_server::Request  &req,
	     world_mission::Mywgs2ned_server::Response &res)
{
  std::vector<double> vec = wgs84ToNed(req.data.position.x, req.data.position.y, req.data.position.z, LAT_HOME, LON_HOME, ALT_HOME);
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
  ros::init(argc, argv, "mywgs2ned_server");
  
  ros::NodeHandle n;
  ros::ServiceServer service = n.advertiseService("mywgs2ned_server", wgs2ned);
  ROS_INFO("For wgs.");
  ros::spin();
 
  return 0;
};
