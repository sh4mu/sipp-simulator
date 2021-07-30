#!/bin/bash

set -xv

# Opensips environemnt variables
opensipsImage=docker-opensips_opensips_1
b2bIp=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $opensipsImage)
networkName=docker-opensips_sip

# Sipp environment variables
sippScenariosPath=~/Investment/sip_simulator/scenarios
sippImage=ctaloi/sipp
scenarioFile=Basic/scenario.csv

uacPort=5070
uacXml=Basic/uac.xml

uasPort=5075
uasXml=Basic/uas.xml
uasInstanceName=sipp_uas

# UAS
SIPP_UAS_CMD="-sf $uasXml -p $uasPort -m 1"
docker run -d -v $sippScenariosPath:/sipp --network=$networkName --name $uasInstanceName -p $uasPort $sippImage $SIPP_UAS_CMD 
uasIp=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $uasInstanceName)

# UAC
cp $sippScenariosPath/$scenarioFile.template $sippScenariosPath/$scenarioFile
sed -i -e "s/UAS_PORT/${uasPort}/" $sippScenariosPath/$scenarioFile
sed -i -e "s/UAS_IP/${uasIp}/" $sippScenariosPath/$scenarioFile

SIPP_UAC_CMD="-sf $uacXml -p $uacPort -inf $scenarioFile $b2bIp -m 1 $1 $2 $3 $4 $5 $6"
docker run -v $sippScenariosPath:/sipp --network=$networkName -p $uacPort $sippImage $SIPP_UAC_CMD

# Clean env
docker rm -f  $uasInstanceName