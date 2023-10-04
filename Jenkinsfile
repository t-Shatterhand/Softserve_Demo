pipeline {
    agent any

    stages {
        stage('Clone repository') {
            steps {
                sh '''
                    cd ~/demo/
                    git clone https://github.com/t-Shatterhand/Softserve_Demo-1.git
                '''
            }
        }
        stage('Create EC Registry') {
            steps {
                sh '''
                    cd ~/demo/Softserve_Demo-1/terraform/
                    terraform init
                    terraform apply -auto-approve -target=module.ecr
                    terraform output | grep "ecr_url" | cut -d " " -f 3 | cut -d '"' -f 2 > ecr_url
                    cat ecr_url | rev | cut -d'/' -f2- | rev > ecr_registry
                    echo ecr_url
                    echo ecr_registry
                '''
            }
        }
        stage('Push to Registry') {
            steps {
                sh '''
                    cd ..
                    sudo docker build . -t kostroba/syt -t `echo build-%BUILD_NUMBER%`
                    sudo docker login -u AWS -p `aws ecr-public get-login-password --region us-east-1` `cat ecr_registry`
                    sudo docker tag kostroba/syt `ecr_url`
                    sudo docker push `cat ecr_url`
                    rm ecr_url ecr_registry
                '''
            }
        }
        stage('Destroy') {
            steps {
                sh '''
                    cd ~
                    rm -rf ~/demo/Softserve_Demo-1
                '''
            }
        }
    }
}