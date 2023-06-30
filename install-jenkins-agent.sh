#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

usage() {
  cat << USAGE
Usage: sudo $0 -n AGENT_NAME -s SECRET
    -j <JENKINS_URL> (Required. Full URL, e.g. https://jenkins.example)
    -n <AGENT_NAME> (Required. No spaces. Just letters, numbers or '-' and '_')
    -s <SECRET> (Required.)
    -u <USER> (Optional. The user for the systemd service. Defaults to 'root')
    -w <WORK_DIR> (Required. Full path, e.g /home/jenkins/jenkins)
    -h help

Example:
    sudo $0 -n my-agent-01 -s 99ca2a6d125fab77fecee7013dc57f32ff1b9a0bed6a0bded952499a00cdcd49 -j https://jenkins.example -w /home/jenkins/jenkins
USAGE
  exit 1
}

JENKINS_URL=
AGENT_NAME=
SECRET=
SERVICE_NAME="jenkins-agent.service"
USER=
WORK_DIR=

if [[ $EUID -ne 0 ]]; then
  echo "$0 is not running as root."
  echo "Try using sudo: sudo $0"
  exit 2
fi

while getopts j:n:s:u:w:h? options; do
  case ${options} in
    j)
      JENKINS_URL=${OPTARG%%+(/)}
      ;;
    n)
      AGENT_NAME=${OPTARG}
      ;;
    s)
      SECRET=${OPTARG}
      ;;
    u)
      USER=${OPTARG}
      ;;
    w)
      WORK_DIR=${OPTARG%%+(/)}
      ;;
    h)
      usage
      ;;
    ?)
      usage
      ;;
  esac
done

if [[ -z ${JENKINS_URL} || -z ${AGENT_NAME} || -z ${SECRET} || -z ${WORK_DIR} ]]; then
  echo "FATAL: No value for -j <JENKINS_URL>, -n <AGENT_NAME>, -s <SECRET> or -w <WORK_DIR>"
  echo ""
  usage
fi

if [[ -z ${USER} ]]; then
  USER=root
fi

echo "Adding and enabling ${SERVICE_NAME}"

cat << JENKINS_SECRET > "${WORK_DIR}"/jenkins-agent-secret
${SECRET}
JENKINS_SECRET

cat << JENKINS_UNIT > /etc/systemd/system/${SERVICE_NAME}
[Unit]
Description=Jenkins agent
Wants=network.target
After=network.target

[Service]
ExecStartPre=/usr/bin/curl -o ${WORK_DIR}/agent.jar -Ssl ${JENKINS_URL}/jnlpJars/agent.jar
ExecStart=/usr/bin/java -jar ${WORK_DIR}/agent.jar -jnlpUrl ${JENKINS_URL}/computer/${AGENT_NAME}/jenkins-agent.jnlp -secret @${WORK_DIR}/jenkins-agent-secret -workDir ${WORK_DIR}
Restart=always
User=${USER}
RestartSec=10

[Install]
WantedBy=multi-user.target
JENKINS_UNIT

systemctl enable ${SERVICE_NAME}
systemctl start ${SERVICE_NAME}

echo "${SERVICE_NAME} has now been started. Status:"

systemctl status ${SERVICE_NAME} --no-pager
