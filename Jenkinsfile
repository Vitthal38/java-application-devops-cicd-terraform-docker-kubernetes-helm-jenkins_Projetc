pipeline {
    agent any

    environment {
        DOCKER_IMAGE  = "vitthal38/java-devops-app"
        DOCKER_TAG    = "${BUILD_NUMBER}"
        AWS_REGION    = "ap-south-1"
        CLUSTER_NAME  = "java-eks-cluster"
        NAMESPACE     = "java-app"
        HELM_RELEASE  = "java-app"
        HELM_CHART    = "./helm/java-app-chart"
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                echo "Branch: ${env.BRANCH_NAME ?: 'main'} | Commit: ${env.GIT_COMMIT?.take(7) ?: 'n/a'}"
            }
        }

        stage('Build') {
            steps {
                echo "Verifying WAR artifact..."
                sh 'ls -lh app/ROOT.war'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    script {
                        docker.image('sonarsource/sonar-scanner-cli:5').inside('--entrypoint=""') {
                            sh '''
                            sonar-scanner \
                              -Dsonar.projectKey=java-devops-app \
                              -Dsonar.projectName="Java DevOps App" \
                              -Dsonar.sources=src \
                              -Dsonar.java.binaries=. \
                              -Dsonar.userHome=$WORKSPACE/.sonar
                            '''
                        }
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    // Pipeline fails here if SonarQube reports below-threshold quality.
                    // This makes SonarQube a gate, not just a report.
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                docker build \
                  --tag $DOCKER_IMAGE:$DOCKER_TAG \
                  --tag $DOCKER_IMAGE:latest \
                  --label "git-commit=$GIT_COMMIT" \
                  --label "build-number=$BUILD_NUMBER" \
                  .
                echo "Built: $DOCKER_IMAGE:$DOCKER_TAG"
                '''
            }
        }

        stage('Trivy Scan') {
            steps {
                sh '''
                docker run --rm \
                  --volume /var/run/docker.sock:/var/run/docker.sock \
                  --volume $HOME/.cache/trivy:/root/.cache/trivy \
                  aquasec/trivy:latest image \
                  --exit-code 0 \
                  --severity HIGH,CRITICAL \
                  --format table \
                  $DOCKER_IMAGE:$DOCKER_TAG
                '''
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo "$DOCKER_PASS" | docker login --username "$DOCKER_USER" --password-stdin
                    docker push $DOCKER_IMAGE:$DOCKER_TAG
                    docker push $DOCKER_IMAGE:latest
                    echo "Pushed: $DOCKER_IMAGE:$DOCKER_TAG"
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([[
                    $class:            'AmazonWebServicesCredentialsBinding',
                    credentialsId:     'aws-creds',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh '''
                    aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

                    kubectl apply -f k8s/namespace.yaml
                    kubectl apply -f k8s/service.yaml --namespace $NAMESPACE

                    kubectl set image deployment/java-app-deployment \
                      app=$DOCKER_IMAGE:$DOCKER_TAG \
                      --namespace $NAMESPACE \
                      || kubectl apply -f k8s/deployment.yaml --namespace $NAMESPACE
                    '''
                }
            }
        }

        stage('Helm Upgrade') {
            steps {
                withCredentials([[
                    $class:            'AmazonWebServicesCredentialsBinding',
                    credentialsId:     'aws-creds',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh '''
                    aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

                    helm upgrade --install $HELM_RELEASE $HELM_CHART \
                      --namespace $NAMESPACE \
                      --create-namespace \
                      --set image.repository=$DOCKER_IMAGE \
                      --set image.tag=$DOCKER_TAG \
                      --set image.pullPolicy=Always \
                      --atomic \
                      --timeout 5m \
                      --wait
                    '''
                }
            }
        }

        stage('Validate Deployment') {
            steps {
                withCredentials([[
                    $class:            'AmazonWebServicesCredentialsBinding',
                    credentialsId:     'aws-creds',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh '''
                    aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

                    echo "=== Pods ==="
                    kubectl get pods -n $NAMESPACE -o wide

                    echo "=== Rollout Status ==="
                    kubectl rollout status deployment/java-app-deployment -n $NAMESPACE --timeout=120s

                    echo "=== Service ==="
                    kubectl get svc -n $NAMESPACE

                    echo "=== Helm Release ==="
                    helm status $HELM_RELEASE -n $NAMESPACE
                    '''
                }
            }
        }

    }

    post {
        success {
            echo "Pipeline succeeded. Image $DOCKER_IMAGE:$DOCKER_TAG is live on EKS."
        }
        failure {
            echo "Pipeline failed. Review the stage logs above."
        }
        always {
            sh '''
            docker rmi $DOCKER_IMAGE:$DOCKER_TAG || true
            docker rmi $DOCKER_IMAGE:latest || true
            '''
        }
    }
}
