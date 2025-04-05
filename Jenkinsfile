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
                git branch: 'main', url: 'https://github.com/selvinjethu/praveen.git'
            }
        }

        stage('Build JAR') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_REGISTRY/$IMAGE_NAME:latest .'
            }
        }

        stage('Login to AWS ECR') {
            steps {
                sh 'aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $DOCKER_REGISTRY'
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                sh 'docker push $DOCKER_REGISTRY/$IMAGE_NAME:latest'
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    sh '''
                        # Stop and remove existing container if running
                        if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
                            echo "Stopping existing container..."
                            docker stop $CONTAINER_NAME
                            docker rm $CONTAINER_NAME
                        fi

                        # Run new container
                        echo "Running new container..."
                        docker run -d --name $CONTAINER_NAME -p 8080:8080 $DOCKER_REGISTRY/$IMAGE_NAME:latest
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
