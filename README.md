# Automating A Full Pipeline With Containerisation


- We created a jenkins server using EC2

- Ran a provision scrpit to install jenkins and all it's dependencies

- Then opened jenkins on our browser using our public ip colon 8080

- Then installed the plugins

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



