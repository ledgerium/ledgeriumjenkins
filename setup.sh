#!/bin/bash

docker-compose down
#docker rm -f ledgeriumjenkins
#docker rmi ledgeriumengineering/ledgeriumjenkins:v1.0
docker network create -d bridge --subnet 172.19.241.0/24 --gateway 172.19.241.1 dev_net || true

#sleep 10
#rm -rf ledgeriumjenkins

#git clone https://github.com/ledgerium/ledgeriumjenkins
#sleep 10
rootpath=$(pwd)
jobspath="$rootpath/jobs"
HOSTPATH=$jobspath

# Configured for SMTP GMAIL. If other meail server is required please configure in init_template.groovy
ledgeriumEmail='notification@ledgerium.net';
ledgeriumPassword='ionic-ken-finite-ajax-degum-byword';
rm -rf init.groovy
sed "s/LEDGERIUMEMAIL/$ledgeriumEmail/g" init_template.groovy > ./initgroovy/tcp-slave-agent-port.groovy
sed -i.bak "s/LEDGERIUMPASSWORD/$ledgeriumPassword/g" ./initgroovy/tcp-slave-agent-port.groovy
rm -rf ./initgroovy/*.bak
#echo "Removing $jobspath"
#sudo rm -rf $jobspath

#docker build -t ledgeriumjenkins:v1 . --no-cache

cd ledgeriumjenkins

for file in $(find . -name "*.sh"); do 
    if [ -f "$file" ]; then 
	echo "Setting up $file job"
	sed -i.bak "s@HOSTPATH@$jobspath@" $file
        filedata=$(cat $file|sed "s@\&@\&amp;@g"|sed "s@\"@\&quot;@g"| sed "s@<@\&lt;@g"|sed "s@>@\&gt;@g"|sed "s@'@\&apos;@g");
	filename="${file%.*}"
	filename=$(echo "$filename"| sed "s/.*\///")
	mkdir -p $jobspath/$filename/latest/
	mkdir -p $jobspath/$filename/builds/

    cp "$rootpath/configs/config1.xml" "$jobspath/$filename/config.xml"
	echo "$filedata" >> "$jobspath/$filename/config.xml"
	cat "$rootpath/configs/config2.xml" >> "$jobspath/$filename/config.xml"
	echo "$file setup done"
	rm -rf *.bak
    fi 
done

cd ..
echo "Jobs path $jobspath"
rm -rf docker-compose.yml

relativepath="$HOME"

jobspath1=$(echo "$jobspath"|sed "s@$relativepath@~@")
echo "Relative jobs path $jobspath1"
touch docker-compose.yml
sed "s@JOBSPATH@$jobspath1@" docker-compose_template.yml > docker-compose.yml

docker-compose up -d
