#!/bin/bash
sudo apt update -y 
wait 5
sudo apt upgrade -y 
wait 6
sudo apt install ansible -y 
sudo apt-get install ca-certificates curl gnupg apt-transport-https software-properties-common  -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y  
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo apt-cache policy docker-ce  
sudo systemctl status docker   
sudo usermod -aG docker root 
su - root && sudo usermod -aG docker root
sudo apt install python3-pip -y