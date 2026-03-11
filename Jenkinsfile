pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                echo '========== STAGE 1: CHECKOUT =========='
                checkout scm
                sh 'ls -la'
            }
        }

        stage('Infrastructure Security Scan') {
            steps {
                echo '========== STAGE 2: TRIVY SECURITY SCAN =========='
                sh 'trivy --version'

                sh '''
                echo "--------------------------------------------"
                echo "TRIVY INFRASTRUCTURE SCAN REPORT"
                echo "Scanning terraform/"
                echo "--------------------------------------------"

                trivy config --format table --severity HIGH,CRITICAL terraform/ || true
                '''

                sh 'trivy config --format json --output trivy-report.json terraform/ || true'

                script {
                    def exitCode = sh(
                        script: 'trivy config --severity HIGH,CRITICAL --exit-code 1 terraform/',
                        returnStatus: true
                    )

                    if (exitCode != 0) {
                        error('''
SECURITY SCAN FAILED
Critical vulnerabilities found in Terraform code.
Review the Trivy report above and fix the issues.
''')
                    } else {
                        echo "Security scan passed"
                    }
                }
            }
        }

        stage('Terraform Plan') {

            environment {
                AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
                AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
                AWS_DEFAULT_REGION    = 'us-east-1'
            }

            steps {

                echo '========== STAGE 3: TERRAFORM PLAN =========='

                dir('terraform') {

                    sh 'terraform init -input=false'

                    sh 'terraform plan -input=false'

                }
            }
        }
    }

    post {

        failure {
            echo "Pipeline failed. Check security vulnerabilities."
        }

        success {
            echo "Pipeline completed successfully."
        }
    }
}