<h1 align="center">Guide: Deploying NGINX on KIND Cluster with Jenkins and Ansible</h1>

<p align="center">
  <img src="https://img.shields.io/badge/NGINX-v1.22.1-green">
  <img src="https://img.shields.io/badge/Jenkins-v2.387.1-red">
  <img src="https://img.shields.io/badge/Ansible-v2.9.27-blue">
  <img src="https://img.shields.io/badge/CentOS-7-lightgrey">
</p>

<p align="center">First of all, it was really fun to perform this task and I learned a couple of new things. Here are a couple of notes I want you to know before you examine my task:</p>

<ul>
  <li>It takes approximately 1 minute for the headline at the webpage to be updated with the latest changes.</li>
  <li>The service type is NodePort because I developed this process on 2 VMs created locally by VirtualBox, with no ability to create LoadBalancer automatically. For the same reason, I didn’t perform the bonus part of the task :(</li>
  <li>Because KIND is running locally on the VM, we’ll test the output of the NGINX webpage with the curl command. First, check what is the internal IP of the remote node in your KIND cluster (`kubectl get node -o wide`), and then run `curl http://node ip:30001`.</li>
</ul>

## Prerequisites

- Two VMs with Linux CentOS 7 (or any other Linux distribution) installed
- Both VMs have internet access, access to each other at the network level, and a user with privileged permissions
- OS firewall turned off on both VMs

## Set up the environment
### Step 1 - Install Jenkins on the Master Node:
1. Install Jenkins as an application with the recommended plugins on the master node. Do not install it as a container.
	- Follow this guide to install Jenkins on CentOS 7: https://sysadminxpert.com/how-to-install-jenkins-on-centos-7-or-rhel-7/
	- If using a different Linux distribution, follow other guides to install Jenkins as an application.
2. Ensure that you have admin access to Jenkins.
3. Verify that Jenkins is installed correctly by running the command "jenkins --version" on the master node after the installation process and get the version number.
### Step 2 - Install Ansible on the Master Node:
1. Install Ansible on the master node. This should be the same node on which Jenkins is installed.
	- Follow this guide to install Ansible on CentOS 7: https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-ansible-on-centos-7
	- If using a different Linux distribution, follow other guides to install Ansible.
3. Verify that Ansible is installed correctly by running the command "ansible --version" on the master node after the installation process.
### Step 3 - Run Jenkins and Create Jenkins Credentials for the Ansible Playbook:
1. Start the Jenkins server by running the command "jenkins" on the master node.
2. On the Jenkins server, go to "Manage Jenkins" -> "Manage credentials".
3. Click on the "Global" link under the "Domains" section.
4. Click on "Add Credentials" at the top right corner of the windows.
5. Under the "Kind" section, select "Username with password".
6. Leave the "Scope" field with "Global".
7. In the "Username" field, enter the desired user for accessing the remote node.
8. Leave the "Treat username as Secret" unchecked.
9. In the "Password" field, enter the user’s password for accessing the remote node.
10. In the "ID" section, enter the value "ansible-remote-cred".
11. Click on the "Create" button.
12. Validate that you have a node with assignedLabels name: "built-in" by visiting the following URL: http://<master node ip>:8080/computer/api/json.
### Step 4 - Create the Pipeline Job:
1. Go back to the Jenkins dashboard and click on "New item" on the left menu bar.
2. In the "Item name" field, enter the value "Deploy_nginx_on_kind".
3. Select "Pipeline" and then click "OK".
4. In the configuration screen, under the pipeline section, under definition, choose "Pipeline script from SCM".
5. Under the "SCM" section, select "Git".
6. Under "Repositories", enter the following repo URL: https://github.com/GuySiton123/deploy_kind_nginx.git
7. Make sure that under "Branch", the value is "*/master".
8. In the "Script Path" field, enter the value "Jenkinsfile".
9. Check the "Lightweight checkout" box and click "Save".
### Step 5 - Run the Pipeline:
1. Run the pipeline for the first time to apply the Jenkinsfile to the job configuration.
2. After the first run, you will be able to run the pipeline with parameters.
3. Enter the values based on the description of the parameters and run.

## Workflow Overview
<p align="center">This is an overview of how all the process of deploying NGINX on a KIND cluster using Jenkins and Ansible is happening.</p>

### Jenkins
- The jenkins pipeline is used to automate the deployment process and has two stages:
	1. Stage 1: Jenkins clones the repository from GitHub that contains the Playbook inventory file and all the roles used in the Playbook.
	2. Stage 2: Jenkins runs the Playbook while passing credentials to Ansible as variables, including the host IP, KIND cluster name, and NGINX web page headline parameters.
### Ansible
- The Ansible Playbook has four roles:
	1. Role 1: Runs on the localhost (master node) and adds the host IP to the Linuxhosts group in the hosts file. It also adds the SSH public key to the authorized_keys file.
	2. Role 2: Runs on the remote host and installs KIND, Docker, kubectl, and helm only if they are not already installed.
	3. Role 3: Runs on the remote host and creates the KIND cluster on the node if it is not exists using the KIND cluster name variable obtained from Jenkins.
	4. Role 4: Runs on the remote host and copies all the files that make up the helm chart while replacing the ansible placeholder in the values file with the NGINX web page headline variable obtained from Jenkins. After copying all the files, it installs the chart if it does not exist and upgrades it if it does exist.
