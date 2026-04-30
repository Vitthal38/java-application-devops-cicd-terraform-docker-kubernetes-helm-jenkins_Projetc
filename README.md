🚀 End-to-End DevOps CI/CD Project 📌 Project Title

Java WAR Application Deployment using Terraform, Docker, Jenkins, Kubernetes, Helm & SonarQube

🎯 Project Objective

This project demonstrates a complete DevOps lifecycle implementation where:

Infrastructure is provisioned using Terraform

Code quality is analyzed using SonarQube

Application is containerized using Docker

CI/CD automation is handled using Jenkins

Application is deployed using Kubernetes

Package management is done using Helm

The goal is to build a fully automated and production-like CI/CD pipeline for deploying a Java WAR-based application.

🏗 Architecture Overview
<imageArchitecture_Of_Devops_Project (2)Developer → Push Code to GitHub ↓ Jenkins Pipeline ↓ SonarQube Code Quality Analysis ↓ Docker Image Build ↓ Push Image to DockerHub ↓ Kubernetes Deployment (Minikube / EKS) ↓ Helm Deployment ↓ Application Running on EC2 🛠 Tools Used & Why We Use Them 1️⃣ Terraform Purpose:

Infrastructure as Code (IaC)

Why?

Automates EC2 creation

Creates Security Groups

Configures networking

Infrastructure becomes version controlled

✅ Eliminates manual infrastructure setup

2️⃣ Docker Purpose:

Containerize the Java WAR application

Why?

Ensures consistent environment

Runs application inside isolated containers

Solves “It works on my machine” problem

Docker builds an image and runs it inside containers.

3️⃣ Jenkins Purpose:

Automates the CI/CD pipeline

Why?

Automatically triggers build

Runs SonarQube analysis

Builds Docker image

Pushes image to DockerHub

Deploys to Kubernetes

Jenkins acts as the automation engine of the project.

4️⃣ SonarQube ⭐ (Added for Code Quality) Purpose:

Static code analysis and quality control

Why?

Detects bugs

Detects code smells

Identifies security vulnerabilities

Measures code coverage

Ensures maintainable code

Integration in Pipeline:

SonarQube stage runs before Docker build:

GitHub → Jenkins → SonarQube Analysis → Docker Build

Pipeline fails automatically if:

Code quality gates fail

Critical vulnerabilities are detected

✅ This makes your project enterprise-level.

5️⃣ Kubernetes Purpose:

Container orchestration

Why?

Manages pods

Handles auto-healing

Supports scaling

Manages service networking

Used with:

Minikube (Local cluster)

Or EKS (Cloud production environment)

6️⃣ Helm Purpose:

Kubernetes package manager

Why?

Packages Kubernetes manifests

Simplifies deployment

Enables version control

Supports rollback

Helm makes Kubernetes deployments reusable and professional.

📦 Project Output ✅ Application Running on Kubernetes Pods

(Deployment Verified)

✅ Pipeline Execution Successful

SonarQube Analysis Passed

Docker Image Built

Image Pushed to DockerHub

Application Deployed

✅ Application Dockerized Successfully 🔧 Setup Instructions Step 1: Infrastructure Provisioning

Run Terraform:

terraform init terraform plan terraform apply

Terraform Creates:

EC2 Instance

Security Group

Required Networking

Step 2: Install Required Tools on EC2

Inside EC2 install:

Docker

Jenkins

Kubernetes (Minikube / Kubeadm / EKS)

kubectl

Helm

SonarQube (Docker Container or Separate Server)

Give Docker Permission: sudo usermod -aG docker jenkins Step 3: Configure Jenkins Install Plugins:

Git Plugin

Docker Pipeline

Kubernetes CLI

Pipeline

SonarQube Scanner Plugin

Add Credentials:

Add:

DockerHub Credentials

SonarQube Token

Go to:

Manage Jenkins → Credentials Step 4: Configure SonarQube

Install SonarQube (Docker recommended)

docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community

Access:

http://:9000

Create Project

Generate Token

Add Token to Jenkins Credentials

Step 5: Jenkins Pipeline Execution

Pipeline Stages:

Clone Repository

SonarQube Code Analysis

Build Docker Image

Push Image to DockerHub

Deploy to Kubernetes

Deploy via Helm

Step 6: Verify Deployment

Check pods:

kubectl get pods

Check services:

kubectl get svc

Access Application:

http://: 📂 Project Structure java-war-devops-project/ │ ├── app/ │ └── your-app.war │ ├── Dockerfile ├── Jenkinsfile ├── README.md │ ├── terraform/ │ ├── main.tf │ ├── variables.tf │ └── outputs.tf │ ├── k8s/ │ ├── deployment.yaml │ ├── service.yaml │ └── namespace.yaml │ └── helm/ └── java-app-chart/

Output Of Project Application Deployed On PodsimagePipeline runs successfullyimageimageApplication Dockerized Successfullyimage

imageimageimageimageimage
✅ Fully automated deployment ✅ Infrastructure as Code ✅ Containerized application ✅ Scalable deployment ✅ Industry-standard DevOps workflow

💡 Future Improvements For Better Optimization

Add GitHub Webhooks for automatic trigger

Add Prometheus & Grafana monitoring

Add SonarQube for code quality

👨‍💻 Author

Project Developed For DevOps Learning & Portfolio Demonstration
