cmake_minimum_required(VERSION 2.8.3)
project(instruct_mission)

## Find catkin macros and libraries
## if COMPONENTS list like find_package(catkin REQUIRED COMPONENTS xyz)
## is used, also find other catkin packages
find_package(catkin REQUIRED COMPONENTS
  geometry_msgs
  message_generation
  message_runtime
  roscpp
  rospy
  std_msgs
  tf
  geographic_msgs
  cram_designators
  mhri_msgs
)

## System dependencies are found with CMake's conventions
# find_package(Boost REQUIRED COMPONENTS system)


## Uncomment this if the package has a setup.py. This macro ensures
## modules and global scripts declared therein get installed
## See http://ros.org/doc/api/catkin/html/user_guide/setup_dot_py.html
# catkin_python_setup()

################################################
## Declare ROS messages, services and actions ##
################################################

## To declare and build messages, services or actions from within this
## package, follow these steps:
## * Let MSG_DEP_SET be the set of packages whose message types you use in
##   your messages/services/actions (e.g. std_msgs, actionlib_msgs, ...).
## * In the file package.xml:
##   * add a build_depend tag for "message_generation"
##   * add a build_depend and a run_depend tag for each package in MSG_DEP_SET
##   * If MSG_DEP_SET isn't empty the following dependency has been pulled in
##     but can be declared for certainty nonetheless:
##     * add a run_depend tag for "message_runtime"
## * In this file (CMakeLists.txt):
##   * add "message_generation" and every package in MSG_DEP_SET to
##     find_package(catkin REQUIRED COMPONENTS ...)
##   * add "message_runtime" and every package in MSG_DEP_SET to
##     catkin_package(CATKIN_DEPENDS ...)
##   * uncomment the add_*_files sections below as needed
##     and list every .msg/.srv/.action file to be processed
##   * uncomment the generate_messages entry below
##   * add every package in MSG_DEP_SET to generate_messages(DEPENDENCIES ...)

## Generate messages in the 'msg' folder
add_message_files(
   FILES
   multimodal_msgs.msg
   multimodal_values.msg
   multikulti.msg
   MultiArrays.msg
)

## Generate services in the 'srv' folder
add_service_files(
  FILES
   multimodal_srv.srv
   multimodal_lisp.srv
   beginner.srv
   ned_wgs.srv
   multimodal_parser.srv
)

## Generate actions in the 'action' folder
# add_action_files(
#   FILES
#   Action1.action
#   Action2.action
# )

## Generate added messages and services with any dependencies listed here
# generate_messages(
#   DEPENDENCIES
#   std_msgs  # Or other packages containing msgs
# )
generate_messages(
  DEPENDENCIES
  geometry_msgs  
  std_msgs
  mhri_msgs
)
################################################
## Declare ROS dynamic reconfigure parameters ##
################################################

## To declare and build dynamic reconfigure parameters within this
## package, follow these steps:
## * In the file package.xml:
##   * add a build_depend and a run_depend tag for "dynamic_reconfigure"
## * In this file (CMakeLists.txt):
##   * add "dynamic_reconfigure" to
##     find_package(catkin REQUIRED COMPONENTS ...)
##   * uncomment the "generate_dynamic_reconfigure_options" section below
##     and list every .cfg file to be processed

## Generate dynamic reconfigure parameters in the 'cfg' folder
# generate_dynamic_reconfigure_options(
#   cfg/DynReconf1.cfg
#   cfg/DynReconf2.cfg
# )

###################################
## catkin specific configuration ##
###################################
## The catkin_package macro generates cmake config files for your package
## Declare things to be passed to dependent projects
## INCLUDE_DIRS: uncomment this if you package contains header files
## LIBRARIES: libraries you create in this project that dependent projects also need
## CATKIN_DEPENDS: catkin_packages dependent projects also need
## DEPENDS: system dependencies of this project that dependent projects also need
catkin_package(
 CATKIN_DEPENDS geometry_msgs message_generation message_runtime roscpp rospy std_msgs)
###########
## Build ##
###########

## Specify additional locations of header files
## Your package locations should be listed before other locations
# include_directories(include)
include_directories(
  ${catkin_INCLUDE_DIRS}
)

## Declare a C++ library
# add_library(instruct_mission
#   src/${PROJECT_NAME}/instruct_mission.cpp
# )

## Add cmake target dependencies of the library
## as an example, code may need to be generated before libraries
## either from message generation or dynamic reconfigure
# add_dependencies(instruct_mission ${${PROJECT_NAME}_EXPORTED_TARGETS} ${catkin_EXPORTED_TARGETS})

## Declare a C++ executable
add_executable(multimodal_actionserver src/nodes/multimodal_actionserver.cpp)
target_link_libraries(multimodal_actionserver ${catkin_LIBRARIES})
add_dependencies(multimodal_actionserver instruct_mission_gencpp)

## Declare a C++ executable
add_executable(multimodal_parser src/nodes/multimodal_parser.cpp)
target_link_libraries(multimodal_parser ${catkin_LIBRARIES})
add_dependencies(multimodal_parser instruct_mission_gencpp)

add_executable(multimodal_client src/nodes/multimodal_client.cpp)
target_link_libraries(multimodal_client ${catkin_LIBRARIES})
add_dependencies(multimodal_client instruct_mission_gencpp)
## Declare a C++ executable
add_executable(multimodal_actionclient src/nodes/multimodal_actionclient.cpp)
target_link_libraries(multimodal_actionclient ${catkin_LIBRARIES})
add_dependencies(multimodal_actionclient instruct_mission_gencpp)

add_executable(multimodal_actionpublisher src/nodes/multimodal_actionpublisher.cpp)
target_link_libraries(multimodal_actionpublisher ${catkin_LIBRARIES})
add_dependencies(multimodal_actionpublisher instruct_mission_gencpp)

add_executable(multimodal_actionsubscriber src/nodes/multimodal_actionsubscriber.cpp)
target_link_libraries(multimodal_actionsubscriber ${catkin_LIBRARIES})
add_dependencies(multimodal_actionsubscriber instruct_mission_gencpp)

add_executable(checker src/nodes/checker.cpp)
target_link_libraries(checker ${catkin_LIBRARIES})
add_dependencies(checker instruct_mission_gencpp)

## Declare a C++ executable
#add_executable(contacts src/contacts.cpp)
#target_link_libraries(contacts ${catkin_LIBRARIES})
#add_dependencies(contacts instruct_mission_gencpp)

## Declare a C++ executable
#add_executable(contacts_sub src/contacts_sub.cpp)
#target_link_libraries(contacts_sub ${catkin_LIBRARIES})
#add_dependencies(contacts_sub instruct_mission_gencpp)

#add_executable(tester src/tester.cpp)
#target_link_libraries(tester ${catkin_LIBRARIES})
#add_dependencies(tester instruct_mission_gencpp)

#add_executable(tester_client src/tester_client.cpp)
#target_link_libraries(tester_client ${catkin_LIBRARIES})
#add_dependencies(tester_client instruct_mission_gencpp)
#add_executable(multimodal_client src/multimodal_client.cpp)
#target_link_libraries(multimodal_client ${catkin_LIBRARIES})
#add_dependencies(multimodal_client instruct_mission_gencpp)

## Add cmake target dependencies of the executable
## same as for the library above
# add_dependencies(instruct_mission_node ${${PROJECT_NAME}_EXPORTED_TARGETS} ${catkin_EXPORTED_TARGETS})

## Specify libraries to link a library or executable target against
# target_link_libraries(instruct_mission_node
#   ${catkin_LIBRARIES}
# )

#############
## Install ##
#############

# all install targets should use catkin DESTINATION variables
# See http://ros.org/doc/api/catkin/html/adv_user_guide/variables.html

## Mark executable scripts (Python etc.) for installation
## in contrast to setup.py, you can choose the destination
# install(PROGRAMS
#   scripts/my_python_script
#   DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
# )

## Mark executables and/or libraries for installation
# install(TARGETS instruct_mission instruct_mission_node
#   ARCHIVE DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
#   LIBRARY DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
#   RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
# )

## Mark cpp header files for installation
# install(DIRECTORY include/${PROJECT_NAME}/
#   DESTINATION ${CATKIN_PACKAGE_INCLUDE_DESTINATION}
#   FILES_MATCHING PATTERN "*.h"
#   PATTERN ".svn" EXCLUDE
# )

## Mark other files for installation (e.g. launch and bag files, etc.)
# install(FILES
#   # myfile1
#   # myfile2
#   DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
# )

#############
## Testing ##
#############

## Add gtest based cpp test target and link libraries
# catkin_add_gtest(${PROJECT_NAME}-test test/test_instruct_mission.cpp)
# if(TARGET ${PROJECT_NAME}-test)
#   target_link_libraries(${PROJECT_NAME}-test ${PROJECT_NAME})
# endif()

## Add folders to be run by python nosetests
# catkin_add_nosetests(test)
