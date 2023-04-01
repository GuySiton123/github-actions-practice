pipeline {
    agent { label 'built-in' }
    parameters {
        string(name: 'host_ip', defaultValue: '', description: 'The remoted server ip')
        string(name: 'nginx_headline', defaultValue: '', description: 'The headline of the nginx webpage')
        string(name: 'kind_cluster_name', defaultValue: '', description: 'The cluster name you want to deploy to (it will be created if it not exsit)')
    }
    stages {
        stage('Git clone') {
            steps {
                git branch: 'master', url: 'https://github.com/GuySiton123/deploy_kind_nginx.git'
            }
        }
        stage('Run Ansible playbook') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'ansible-remote-cred', passwordVariable: 'ansible_password', usernameVariable: 'ansible_user')]) {
                    sh '''
                        ls
                        ansible-playbook deploy_kind_nginx.yaml \
                        --user=$ansible_user \
                        -i hosts \
                        --extra-vars "host_ip=$host_ip" \
                        --extra-vars "nginx_headline='$nginx_headline'" \
                        --extra-vars "kind_cluster_name=$kind_cluster_name" \
                        --extra-vars "ansible_password=$ansible_password"
                    '''
                }
            }
        }
    }
}
