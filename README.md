# Automating A Full Pipeline With Containerisation


## Note that we will be using 16.04 ubuntu AMI's to create our EC2 instances

## Installing Jenkins

```
wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
echo "deb https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list
sudo apt-get update -y
sudo apt-get install jenkins -y
sudo systemctl start jenkins
sudo systemctl status jenkins
```

## Then opened jenkins on our browser using our public ip colon 8080

### Logging in using the password

- Below command will give us the admin password that we must insert into jenkins
```
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
- the username will be admin

- Then installed the recommended plugins


## Creating a jenkins slave node
- We then created a slave node through jenkins and made another EC2 instance which we called slave

- The slave is an environment to runo ur tests on

- We first enter our opt folder and create a folder named jenkins

```
sudo mkdir jenkins
sudo wget http://34.247.181.80:8080/jnlpJars/agent.jar
```

- This downloads the agent.jar file
- We can now run the agent.jar file which will connect us to our master node

- Before we do this we need to create a user called jenkins and switch to it

```
sudo adduser jenkins
sudu su jenkins
```

- Now we run the agent.jar file
- 
```
java -jar agent.jar -jnlpUrl http://34.247.181.80:8080/computer/Jenkins-Slave/slave-agent.jnlp -secret 813e64a1fdd2e97f1128ffc6fa4378cb4359464c4a439e4eeb6b4ecda1d99ef3

```

- Now our node is connected to the master effectively



- Now if we run a build we will get the error 'npm not found', therefore we will download npm on our jenkins slave


- Do we run this build in sudo su? I dunno
- 
```
sudo apt-get install python-software-properties
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install nodejs -y
```

- When we install node, it comes with npm
- in order for our server to run the tests we must first have npm
- If we rerun our build it should work succesfully

## Creating a Docker Instance

- On EC2 we now create a Docker instance

- Now we can download docker with the following commands

```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
apt-cache policy docker-ce
sudo apt-get install -y docker-ce
sudo systemctl status docker
```

## Running a Container within our instance

- We will now pull an image from a docker repository to check if we can see the application running on a browser

```
sudo docker run -d -p 3000:3000 aosborne17/microservices-with-docker-and-nodejs:First_Commit
```

- We can then enter our app IP into the browser with the port being 3000

`http://176.34.149.206:3000/`

- And should see the app successfully running

![](/images/App-Running-Through-Container.png)


## Creating our Continuous Deployment job

- Now that we have created an instance to hold our containers we can now automate the deployment phase with our CD pipeline job

- We must install docker pipeline plugin



- For this pipeline to be succesfull we must add a credential which allows us to interact with our docker repository
  
1)To do this from the dashboard we click manage jenkins
2 Then manage credentials
3) Click on the jenkins link found under 'stores scoped to jenkins'
4) Click global credentials
5) Then click add credentials on the left hand side
6) We will then add the username, password and id (the string we will uses to reference that credential within the pipeline)

![](/images/Adding-Docker-Credentials.png)


## Creating the Docker Repository

- Before we create the pipeline we want to create a repo that we will send the image to
- This can be done on docker hub
- On this instance we will call the repo ''automation-with-docker''

![](/images/Creating-Docker-Repo.png)


## Adding the pipeline script

- 