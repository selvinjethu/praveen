pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-2'
        DOCKER_REGISTRY = '571600876302.dkr.ecr.us-east-2.amazonaws.com'
        IMAGE_NAME = 'praveen'
        REMOTE_USER = 'ubuntu' // Change this to your EC2 username
        REMOTE_HOST = '3.142.133.147' // Change this to your target EC2 instance IP
        SSH_KEY = '/home/ubuntu/praveen.pem' // Path to private key Jenkins will use
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Cloning repository..."
                git branch: 'main', url: 'https://github.com/selvinjethu/praveen.git'
            }
        }

        stage('Build JAR') {
            steps {
                echo "Building Maven project..."
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                sh '''
                    docker build -t $DOCKER_REGISTRY/$IMAGE_NAME:latest .
                '''
            }
        }

        stage('Login to AWS ECR') {
            steps {
                echo "Logging in to AWS ECR..."
                sh '''
                    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $DOCKER_REGISTRY
                '''
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                echo "Pushing Docker image to ECR..."
                sh 'docker push $DOCKER_REGISTRY/$IMAGE_NAME:latest'
            }
        }
        stage('Deploy to Remote Instance') {
            steps {
                script {
                    sh """
                    ssh -o StrictHostKeyChecking=no -i "/var/lib/jenkins/.ssh/praveen.pem" ubuntu@ec2-3-142-133-147.us-east-2.compute.amazonaws.com << EOF
                        export AWS_REGION=$AWS_REGION
                        export DOCKER_REGISTRY=$DOCKER_REGISTRY
                        aws ecr get-login-password --region \$AWS_REGION | docker login --username AWS --password-stdin \$DOCKER_REGISTRY
                        sudo docker pull \$DOCKER_REGISTRY/$IMAGE_NAME:latest
                        sudo docker rm -f praveen-container || true
                        sudo docker run -d --name praveen-container -p 8080:8080 \$DOCKER_REGISTRY/$IMAGE_NAME:latest
                    EOF
                    """
                }
            }
        }
    }

    post {
        failure {
            echo "❌ Pipeline failed."
        }
        success {
            echo "✅ Deployment successful!"
        }
        always {
            cleanWs()
        }
    }
}
