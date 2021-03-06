# Automating A Full Pipeline With Containerisation


## Introduction To The Project

- This project will show end to end automation of source code
- When changes are made to a dev branch, it will be tested and integrated onto the master branch on Jenkins
- The next pipeline will then create a Docker image from the merged master branch code and push it to Docker Hub
- The final job will then pull our image from Docker hub and run the container on our Docker App EC2 instance
- We should then be able to access the webapp on port 3000 of our Docker App public IP


![](/images/End2End_Diagram_with_Container.png)


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

## Giving docker access to sudo

- In order for us to run Docker commands within jenkins we need to allow sudo access for Docker, this can
be done running the lines of code below

```
sudo usermod -aG docker ${USER}
newgrp docker
sudo service docker restart
sudo systemctl restart docker
sudo chmod 666 /var/run/docker.sock

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

- When creating the job, we want it to be triggered if our CI job is successful

![](/images/Adding-Docker-Credentials.png)



- For this pipeline to be succesfull we must add a credential which allows us to interact with our docker repository
  
1)To do this from the dashboard we click manage jenkins
2 Then manage credentials
1) Click on the jenkins link found under 'stores scoped to jenkins'
2) Click global credentials
3) Then click add credentials on the left hand side
4) We will then add the username, password and id (the string we will uses to reference that credential within the pipeline)

![](/images/Adding-Docker-Credentials.png)


## Creating the Docker Repository

- Before we create the pipeline we want to create a repo that we will send the image
- This can be done on docker hub
- On this instance we will call the repo ''automation-with-docker''

![](/images/Creating-Docker-Repo.png)


#### Adding the pipeline script

```
pipeline {
  environment {
    registry = "aosborne17/automation-with-docker"
    registryCredential = 'dockerhub'
    dockerImage = ''
  }
  agent any
  stages {
    stage('Cloning Git') {
      steps {
        git 'https://github.com/aosborne17/Automating-A-Full-Pipeline-With-Containerisation'
      }
    }
    // stage('Build') {
    //   steps {
    //      sh 'npm install'
    //   }
    // }
    // stage('Test') {
    //   steps {
    //     sh 'npm test'
    //   }
    // }
    stage('Building image') {
      steps{
        script {
          dockerImage = docker.build registry + ":$BUILD_NUMBER"
        }
      }
    }
    stage('Deploy Image') {
      steps{
         script {
            docker.withRegistry( '', registryCredential ) {
            dockerImage.push()
          }
        }
      }
    }
    stage('Remove Unused docker image') {
      steps{
        sh "docker rmi $registry:$BUILD_NUMBER"
      }
    }
  }
}

```


### Successful Pipeline build


- Each of the build should pass successfully
  
![](/images/Pipeline-Stage-View.png)



- We will also be able to see that a push has been made to our Docker Hub

![](/images/Docker-Hub-Pushes.png)



### Overcoming Obstacles




#### DEDICATION

![](/images/Dedication.png)


## Continuous Deployment Job

- We must install the 'SSH agent' plugin to be able to ssh into our Virtual Machines
  
  - Now in our builds we click on the SSH agent and add credentials,
  - we then change kind to ''SSH Username with private key'' and click private key
  - We will then enter our gitbash and enter the contents of our DevOpsStudents.pem file, copying everything into the jenkins credentials


### Security Groups Access

- In our security groups we must allow our master jenkins agent to SSH into our Docker App and run the commands

![](/images/Allowing-Jenkins-To-Enter-Docker-App.png)


- We will also trigger this build only if our CD pipeline builds succesfully, this job can then pull the most recently created image from our docker hub and run it from within our EC2 instance

- Our execute shell would look like so:

```
# The "$BUILD_NUMBER is specifying the number of the current jenkins build, which will then pull the docker image assigned with that same number
# We are also echoing in a command that will will run our docker container
echo "sudo docker run -d -p 3000:3000 aosborne17/automation-with-docker:$BUILD_NUMBER" >> run_container.sh
# We can then copy over both of the bash scripts that we will run once within the Docker App
scp -o "StrictHostKeyChecking=no" run_container.sh ubuntu@176.34.149.206:~/
scp -o "StrictHostKeyChecking=no" delete_containers.sh ubuntu@176.34.149.206:~/
# We can now SSH into our DockerApp
ssh -o "StrictHostKeyChecking=no" ubuntu@176.34.149.206 <<EOF
    # Then first delete any running containers
    sudo bash ./delete_containers.sh
    # Then run our container
    sudo bash ./run_container.sh
```

## Checking Docker Logs
- With these configurations, the build is successful however whenever I check the container status they are ran and then destroyed almost instantly

- We will therefore check the logs of my container by running the following command

```
docker logs
```

- Which shows the current issues, express has not been installing correctly


![](/images/Docker-Container-Issue.png)

## Creating A Docker Hub webhook to send emails

- Creating A Google Script that once activated will send an email to the team! Click this [LINK!](https://script.google.com/home/start)

```
function doGet(e){
  return HtmlService.createHtmlOutput("request received");
}

function doPost(e) {
    var emailAddress = 'IBocus@spartaglobal.com'
    var message = 'Morning Ibrahim, this is an email to show that Andrew has pushed a new image to his DockerHub.\n Andrew made a push to his dev branch, which then triggered A CI build on Jenkins. Once this build passed the code was then merged to the master branch and a CD pipeine job was then triggered. \n This job would then clone the master branch and create a Docker image and push this image to Docker Hub ..... The reason you are getting this message now. \n After this, a final CD job will be run which will SSH into Andrews Docke App EC2 instance and run the image as a container!! '
    var subject = 'Sending Emails From Google Scripts';
    MailApp.sendEmail(emailAddress, subject, message);
    return HtmlService.createHtmlOutput()("post request received");
  
}

```


## Running the Full End-To-End Pipeline

- Note that before we make any pushes, we should always ```git pull``` to make sure we don't have any upstream code changes that we have not added to our local code base

- Add step by step with images how each section of the pipeline works!

- Make a video to explain the process


## Further Iterations 
- Ansible
- Terraform
- Add more images to GitHub to explain the steps


## Info

- Pipeline is written in groovy, we can put this on a jar file and place on github
- Understand each line of code for the pipeline

