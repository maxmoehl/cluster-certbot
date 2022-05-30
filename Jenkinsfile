pipeline {
    agent {
        kubernetes {
            yamlFile 'jenkins.yml'
            defaultContainer 'buildah'
        }
    }
    stages {
        stage('Build') {
            steps {
                sh 'buildah bud -t registry:5000/route53-k8s-certbot:latest .'
            }
        }
        stage('Push') {
            steps {
                sh 'buildah push --tls-verify=false registry:5000/route53-k8s-certbot:latest'
            }
        }
    }
}
