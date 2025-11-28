pipeline {
    agent any

    environment {
        DOCKERHUB = credentials('dockerhub')
        KUBECONFIG = credentials('kubeconfig')
    }

    stages {
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                echo "$KUBECONFIG" > kubeconfig.yaml
                export KUBECONFIG=kubeconfig.yaml

                kubectl set image deployment/hello-deploy hello=$DOCKERHUB_USR/devops-test:latest
                kubectl rollout status deployment/hello-deploy
                '''
            }
        }
    }
}
