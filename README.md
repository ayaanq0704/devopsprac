This project demonstrates a DevSecOps pipeline that integrates security scanning into the CI/CD workflow before infrastructure deployment.

The pipeline automatically:

Pulls source code from GitHub

Runs Trivy security scans on Terraform infrastructure code

Blocks deployment if vulnerabilities are detected

Runs Terraform plan to preview infrastructure changes

Jenkins Pipeline Stages:

Stage 1 — Checkout
The pipeline pulls the latest code from the GitHub repository.

Stage 2 — Infrastructure Security Scan
Trivy scans Terraform files for security misconfigurations such as:
-Unrestricted SSH access
-Unencrypted storage volumes
-Public network exposure
If HIGH or CRITICAL vulnerabilities are detected, the pipeline fails.

Stage 3 — Terraform Plan
If the security scan passes, Terraform generates a plan showing what infrastructure would be created.