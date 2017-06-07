#!/bin/bash
#####################################################################################
#                                                                                   #
#  Script to start the Deployment Manager                                           #
#                                                                                   #
#  Usage : startDmgr.sh                                                             #
#                                                                                   #
#####################################################################################

updateHostname()
{
    #Get the container hostname
    host=`hostname`

    if [ "$NODE_NAME" = "" ]
    then
        NODE_NAME="dmgrNode"
    fi

    # Update the hostname
    /opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython -conntype NONE -f /opt/updateHostName.py \
    $NODE_NAME $host

    touch /opt/hostnameupdated
}

startDmgr()
{
    if [ "$PROFILE_NAME" = "" ]
    then
        PROFILE_NAME="Dmgr"
    fi

    echo "Starting deployment manager ............"
    /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME/bin/startManager.sh

    if [ $? != 0 ]
    then
        echo " Dmgr startup failed , exiting....."
    fi
}

stopDmgr()
{
    if [ "$PROFILE_NAME" = "" ]
    then
        PROFILE_NAME="Dmgr"
    fi

    echo "Stopping deployment manager ............"
    /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME/bin/stopManager.sh

    if [ $? = 0 ]
    then
        echo " Dmgr stopped successfully. "
    fi
}

if [ ! -f "/opt/hostnameupdated" ]
then
    updateHostname
fi

startDmgr

trap "stopDmgr" SIGTERM

sleep 10

if [ "$PROFILE_NAME" = "" ]
then
    PROFILE_NAME="Dmgr"
fi

while [ -f "/opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME/logs/dmgr/dmgr.pid" ]
do
    sleep 5
done