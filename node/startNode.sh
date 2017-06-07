#!/bin/bash
#####################################################################################
#                                                                                   #
#  Script to update HostName  and Federate AppServer profile                        #
#                                                                                   #
#  Usage : updateHostAndFederateServer.sh                                           # 
#                                                                                   #
#####################################################################################

startServer()
{
     #Check whether profile name is provided or use default
     if [ "$PROFILE_NAME" = "" ] 
     then
          PROFILE_NAME="AppSrv01"
     fi

     echo "Starting server......................."
     /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME/bin/startServer.sh server1
}

startNodeAndServer()
{
     #Check whether profile name is provided or use default
     if [ "$PROFILE_NAME" = "" ] 
     then
          PROFILE_NAME="AppSrv01"
     fi

     echo "Starting node......................."
     /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME/bin/startNode.sh
     echo "Starting server......................."
     /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME/bin/startServer.sh server1
}

stopServerAndNode()
{
     #Check whether profile name is provided or use default
     if [ "$PROFILE_NAME" = "" ] 
     then
          PROFILE_NAME="AppSrv01"
     fi

     echo "Stopping server......................."
     /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME/bin/stopServer.sh server1

     if [ $? = 0 ]
     then
           echo " Server stopped successfully. "
     fi

     echo "Stopping nodeagent..............."
     /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME/bin/stopNode.sh

     if [ $? = 0 ]
     then
           echo " Nodeagent stopped successfully. "
     fi
}

unfederateNode()
{
    # Add the node
    /opt/IBM/WebSphere/AppServer/bin/removeNode.sh

    rm /opt/nodefederated
}


federateNode()
{
    #Check whether dmgr host is provided or use default
    if [ "$DMGR_HOST" = "" ]
    then
         DMGR_HOST="dmgr"
    fi

    #Check whether dmgr port is provided or use default
    if [ "$DMGR_PORT" = "" ]
    then
         DMGR_PORT="8879"
    fi

    # Add the node
    /opt/IBM/WebSphere/AppServer/bin/addNode.sh $DMGR_HOST $DMGR_PORT

    touch /opt/nodefederated
}

updateNodename()
{
     #Check whether profile name is provided or use default
     if [ "$PROFILE_NAME" = "" ] 
     then
          PROFILE_NAME="AppSrv01"
     fi

      # Update the nodename
     /opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython -conntype NONE -f /opt/updateNodeName.py \
     tmpNode `hostname`Node

     echo "WAS_NODE=`hostname`Node" >> /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME/bin/setupCmdLine.sh
}

updateHostname()
{
     # Update the hostname
     /opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython -conntype NONE -f /opt/updateHostName.py \
     tmpNode `hostname`
}

if [ ! -f "/opt/nodefederated" ]
then
    updateHostname
    updateNodename
    federateNode
    startServer
fi

startNodeAndServer

trap "unfederateNode" SIGTERM

sleep 10

while [ -f "/opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME/logs/server1/server1.pid" ]
do
    sleep 5
done