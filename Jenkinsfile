pipeline {
    agent any

    environment {
        IMAGE_NAME = "praveen"
        AWS_ACCOUNT_ID = "571600876302"
        AWS_REGION = "us-east-2"
        DOCKER_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        CONTAINER_NAME = "praveen-container"
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

        stage('Deploy Container') {
            steps {
                echo "Deploying container..."
                sh '''
                    # Stop and remove existing container if running
                    if [ "$(sudo docker ps -q -f name=$CONTAINER_NAME)" ]; then
                        echo "Stopping existing container..."
                        docker stop $CONTAINER_NAME
                        docker rm $CONTAINER_NAME
                    fi

                    # Run new container
                    echo "Starting new container..."
                    docker run -d --name $CONTAINER_NAME -p 8080:8080 $DOCKER_REGISTRY/$IMAGE_NAME:latest

                    echo "Deployment completed."
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed."
        }
        always {
            echo "Cleaning up workspace..."
            cleanWs()
        }
    }
}
