pipeline {
    agent any

    stages {
        stage('Clone repository') {
            steps {
                sh '''
                    cd ~
                    git clone https://github.com/t-Shatterhand/Softserve_Demo-1.git
                '''
            }
        }
        stage('Create EC Registry') {
            steps {
                sh '''
                    cd ~/Softserve_Demo-1/terraform/
                    terraform init
                    terraform apply -auto-approve -target=module.ecr
                    terraform output -raw ecr_url > ecr_url
                    cat ecr_url | rev | cut -d'/' -f2- | rev > ecr_registry
                    cat ecr_url
                    cat ecr_registry
                '''
            }
        }
        stage('Push to Registry') {
            steps {
                sh '''
                    cd ~/Softserve_Demo-1/
                    sudo docker build . -t kostroba/syt:latest -t kostroba/syt:build$BUILD_NUMBER
                    sudo docker login -u AWS -p `aws ecr-public get-login-password --region us-east-1` `cat ~/Softserve_Demo-1/terraform/ecr_registry`
                    sudo docker tag kostroba/syt:build$BUILD_NUMBER `cat ~/Softserve_Demo-1/terraform/ecr_url`
                    sudo docker tag kostroba/syt:latest `cat ~/Softserve_Demo-1/terraform/ecr_url`
                    sudo docker push `cat ~/Softserve_Demo-1/terraform/ecr_url`
                    sudo docker push `cat ~/Softserve_Demo-1/terraform/ecr_url`:build$BUILD_NUMBER
                    rm ~/Softserve_Demo-1/terraform/ecr_url ~/Softserve_Demo-1/terraform/ecr_registry
                '''
            }
        }
        stage('Destroy') {
            steps {
                sh '''
                    cd ~
                    rm -rf ~/Softserve_Demo-1
                '''
            }
        }
    }
}