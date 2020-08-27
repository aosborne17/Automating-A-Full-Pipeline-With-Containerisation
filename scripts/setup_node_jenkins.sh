#!bin/bash

cd /etc/opt/
cd jenkins

sudo mkdir jenkins
sudo wget http://34.247.181.80:8080/jnlpJars/agent.jar

sudo adduser jenkins
sudu su jenkins

java -jar agent.jar -jnlpUrl http://34.247.181.80:8080/computer/Jenkins-Slave/slave-agent.jnlp -secret 813e64a1fdd2e97f1128ffc6fa4378cb4359464c4a439e4eeb6b4ecda1d99ef3

sudo apt-get install python-software-properties -y
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install nodejs -y