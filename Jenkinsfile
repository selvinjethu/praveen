pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-2'
        DOCKER_REGISTRY = '571600876302.dkr.ecr.us-east-2.amazonaws.com'
        IMAGE_NAME = 'praveen'
        REMOTE_USER = 'ubuntu' // Change this to your EC2 username
        REMOTE_HOST = '18.117.146.159' // Change this to your target EC2 instance IP
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
                    sh '''
                    if [ "$(docker ps -q -f name=praveen-container)" ]; then
                        echo "Container is running. Stopping and removing..."
                        docker stop praveen-container
                        docker rm praveen-container
                    elif [ "$(docker ps -aq -f name=praveen-container)" ]; then
                        echo "Container exists but not running. Removing..."
                        docker rm praveen-container
                    else
                        echo "No container with name praveen-container found."
                    fi
                    
                    # Start new container
                    docker pull $DOCKER_REGISTRY/$IMAGE_NAME:latest
                    docker run -d --name $DOCKER_REGISTRY/$IMAGE_NAME:latest
                    '''

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
