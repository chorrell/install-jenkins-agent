# install-jenkins-agent

Installing Jenkins as a permanent agent on a Linux node (Ubuntu, Debian, CentOS etc.) is not as straightforward as it should be.

The `install-jenkins-agent.sh` script simplifies things by:

- Installs the Jenkins agent (agent.jar) from your Jenkins installation
- Creates a systemd service for the agent to keep it running

## Prerequisites

- A **Permanent Agent** in Jenkins (created via <https://example.com/computer/new>) with the desired working directory.
- Git and Java installed on the agent node (For example, on Ubuntu 20.04: `apt-get install git openjdk-11-jdk-headless`)

## Usage

Once your agent node has been created and saved in Jenkins, copy the **secret** string from the instructions under _Run from agent command line_.

Once the node has been created and (and git and java are installed, run `install-jenkins-agent.sh` on the agent node using sudo to setup the servoce.

For example, assuming the name of the node is _my-agent-01_:

```bash
sudo ./install-jenkins-agent.sh -n my-agent-01 -u jenkins -s 99ca2a6d125fab77fecee7013dc57f32ff1b9a0bed6a0bded952499a00cdcd49 -j https://jenkins.example -w /home/jenkins/jenkins
```

The script will fetch `agent.jar` from your jenkins install and then create a systemd service using your desired options (user, working directory, etc.)
