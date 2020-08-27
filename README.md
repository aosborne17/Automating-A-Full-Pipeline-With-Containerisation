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

```

- Note if we CTRL c we will it will stop the connection between the two so don't do that!


- We then need to connect our jeknins slave to our master by running the following commands

