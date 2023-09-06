pipeline {
    agent any

    stages {
        stage('Clone') {
            steps {
                sh '''
                    cd ~/demo/
                    eval `ssh-agent -s`
                    ssh-add ~/.ssh/github
                    git clone git@github.com:t-Shatterhand/Softserve-Demo-1.git
                '''
            }
        }
        stage('Push') {
            steps {
                sh '''
                    cd ~/demo/Softserve-Demo-1/
                    sudo docker build . -t kostroba/syt
                    sudo docker login -u AWS -p `aws ecr-public get-login-password --region us-east-1` public.ecr.aws/j4u1q4l9
                    sudo docker tag kostroba/syt public.ecr.aws/j4u1q4l9/syt
                    sudo docker push public.ecr.aws/j4u1q4l9/syt
                '''
            }
        }
        stage('Destroy') {
            steps {
                sh '''
                    rm -rf ~/demo/Softserve-Demo-1
                '''
            }
        }
        stage('Deploy') {
            steps {
                sshagent(credentials : ['Deployment_server_SSH_creds']) {
                    sh '''
                        ssh -tt -o StrictHostKeyChecking=no ec2-user@deployment.kostroba.pp.ua << EOF
                        sudo docker ps -a -q | xargs sudo docker stop
                        sudo docker ps -a -q | xargs sudo docker rm
                        sudo docker pull public.ecr.aws/j4u1q4l9/syt
                        sudo docker run -d -p 8080:8080 public.ecr.aws/j4u1q4l9/syt:latest
                        exit
                        EOF
                    '''
                }
            }
        }
    }
}