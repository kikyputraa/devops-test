📘 DevOps Test – Full Documentation

# 🚀 AssistX DevOps Test – Deployment + CI/CD Documentation

Proyek ini adalah implementasi aplikasi sederhana “Hello World”, 
containerization menggunakan Docker, deployment ke Kubernetes (Minikube), serta otomatisasi CI/CD menggunakan GitLab Runner (Shell Executor).

Alat apa yang saja yang dipakai : 

Docker

Dockerfile Multi-stage build

Minikube

Kubernetes Deployment

Nginx Ingress

GitHub Actions / Jenkins / Gitlab Runner

Docker Hub


## 0. 📌 PREPARATION (LINUX SETUP)
1️⃣ Update Linux

```
sudo apt update && sudo apt upgrade -y
```
![WhatsApp Image 2025-11-28 at 19 16 02_99e9ec90](https://github.com/user-attachments/assets/f542dbf9-5c40-47d2-9211-86e0e04671ce)>

2️⃣ Install Git

```
sudo apt install git -y
```
![WhatsApp Image 2025-11-28 at 19 19 48_8e136c0c](https://github.com/user-attachments/assets/5ad38c98-b8c6-458c-80c7-281baaab4b83)

3️⃣ Install Python

Untuk membuat aplikasi sederhana.

```
sudo apt install python3 python3-pip -y
```
![WhatsApp Image 2025-11-28 at 19 20 43_6d7701b0](https://github.com/user-attachments/assets/c3b18f84-dc34-474c-a6e1-c30dea8cb9ef)

4️⃣ Install Docker Engine

```
sudo apt install ca-certificates curl gnupg lsb-release -y

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io -y
```
![WhatsApp Image 2025-11-28 at 19 21 10_15f520f6](https://github.com/user-attachments/assets/07afc901-42fa-4713-93e2-c5ad64e4a347)

Tambahkan user ke group docker:

```
sudo usermod -aG docker $USER
```

Test:

```
docker run hello-world
```
![WhatsApp Image 2025-11-28 at 19 21 40_3cb5fa65](https://github.com/user-attachments/assets/0a70aaf4-1925-45e7-ac17-1d5d94927549)

5️⃣ Install Docker Compose

```
sudo apt install docker-compose-plugin -y
```
![WhatsApp Image 2025-11-28 at 19 22 04_b4fb074c](https://github.com/user-attachments/assets/81293f9a-b338-49a8-9387-21d7cf794064)

6️⃣ Install kubectl

```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```
![WhatsApp Image 2025-11-28 at 19 24 43_7fc86a28](https://github.com/user-attachments/assets/7f49505a-365f-4d62-b693-10b1e413a3b0)

7️⃣ Install Minikube

```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

Start Minikube:

```
minikube start --driver=docker
```
![WhatsApp Image 2025-11-28 at 19 27 52_684f6f6b](https://github.com/user-attachments/assets/305c3d44-9230-49a8-b208-a221ae3ccb52)

8️⃣ Instalasi NGINX Ingress + LoadBalancer (Minikube Tunnel)

```
minikube addons enable ingress
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
sudo -E minikube tunnel
```

9️⃣ Install Jenkins (via Docker)

```
docker run -d --name jenkins \
  -p 8081:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
```

Akses:

```
http://localhost:8081
```

![WhatsApp Image 2025-11-28 at 19 28 27_5d02d529](https://github.com/user-attachments/assets/1d86bd5f-77d1-4583-983a-26362f4f1269)

<img width="778" height="489" alt="image" src="https://github.com/user-attachments/assets/3a1eb56d-ab0a-4968-b19e-bc0d176643ba" />

🔟 Install GitLab Runner

```
sudo curl -L --output /usr/local/bin/gitlab-runner \
https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64

sudo chmod +x /usr/local/bin/gitlab-runner
sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
sudo gitlab-runner start
```

![WhatsApp Image 2025-11-28 at 19 29 33_7cb5542c](https://github.com/user-attachments/assets/98fac8d9-d0df-4b81-bf94-495856979330)

Register runner:

```
gitlab-runner register
```

![WhatsApp Image 2025-11-28 at 19 35 47_a691d813](https://github.com/user-attachments/assets/de18a23e-30ff-40de-817f-5f90d3df2e3e)

## 1. 📌 Aplikasi – Spesifikasi

Aplikasi dibangun menggunakan Python + FastAPI, dengan requirement:

Endpoint: /

Response: JSON → {"msg": "Hello World"}

Header: Content-Type: application/json

Port: 8080

1️⃣ Buat folder project

```
mkdir devops-test && cd devops-test
```

2️⃣ Buat aplikasi FastAPI

app/main.py :

```
from fastapi import FastAPI
from fastapi.responses import JSONResponse

app = FastAPI()

@app.get("/")
def root():
    return JSONResponse(content={"msg": "Hello World"}, media_type="application/json")
```

app/main.py :

```
fastapi
uvicorn
```

## 2. 📌 Dockerization

Menggunakan multi-stage build + Alpine Base Image.

Dockerfile : 

```
# Stage 1 - builder
FROM python:3.11-alpine AS builder
WORKDIR /app
COPY app/requirements.txt .
RUN apk add --no-cache build-base && \
    pip install --no-cache-dir --user -r requirements.txt

# Stage 2 - runtime
FROM python:3.11-alpine
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY app /app
ENV PATH=/root/.local/bin:$PATH
EXPOSE 8080
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
```

Build:

```
docker build -t yourname/devops-test:latest .
```

Run:

```
docker run -p 8080:8080 yourname/devops-test:latest
```

## 3. 📌 Upload Image ke Docker HUB

Login:

```
docker login
```

Push:
```

docker push yourname/devops-test:latest
```


## 4. 📌 GITHUB ACTIONS (CI BUILD + PUSH)

.github/workflows/ci.yml
```
name: CI - Build & Push Docker Image

on:
  push:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repo
        uses: actions/checkout@v3

      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DH_USER }}
          password: ${{ secrets.DH_TOKEN }}

      - name: Build Docker Image
        run: |
          docker build -t ${{ secrets.DH_USER }}/devops-test:latest .

      - name: Push Docker Image
        run: |
          docker push ${{ secrets.DH_USER }}/devops-test:latest
```

## 5. 📌 JENKINS PIPELINE (DEPLOY KE K8S)

Jenkinsfile

```
pipeline {
    agent any

    stages {
        stage('Pull Image') {
            steps {
                sh 'docker pull yourname/devops-test:latest'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                kubectl apply -f k8s/deployment.yaml
                kubectl apply -f k8s/service.yaml
                kubectl apply -f k8s/ingress.yaml
                kubectl rollout status deployment/hello-deploy
                '''
            }
        }

        stage('Smoke Test') {
            steps {
                sh 'curl -f http://localhost || exit 1'
            }
        }
    }
}
```

## 6. 📌 Kubernetes Deployment (Minikube)

Struktur folder:

k8s/

 ├── deployment.yaml

```
 apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-deploy
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hello
  template:
    metadata:
      labels:
        app: hello
    spec:
      containers:
        - name: hello
          image: <YOUR_DOCKERHUB_IMAGE>
          ports:
            - containerPort: 8080
```
 
 ├── service.yaml

 ```
apiVersion: v1
kind: Service
metadata:
  name: hello-svc
spec:
  selector:
    app: hello
  ports:
    - port: 80
      targetPort: 8080
```
 
 └── ingress.yaml

 ```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello-ingress
spec:
  ingressClassName: nginx
  rules:
    - host: localhost
      http:
        paths:
          - backend:
              service:
                name: hello-svc
                port:
                  number: 80
            path: /
            pathType: Prefix
```

Apply:

```
kubectl apply -f k8s/
```

Test:

```
curl http://localhost/
```

## 7. 📌CI/CD Pipelines (Gitlab, Runner Local)

```
stages:
  - build
  - push
  - deploy

variables:
  DOCKER_IMAGE: "$DOCKERHUB_USERNAME/devops-test:latest"

before_script:
  - echo "Running job on $(hostname)"
  - docker --version
  - kubectl version --client=true

build:
  stage: build
  script:
    - echo "Building Docker image..."
    - docker build -t $DOCKER_IMAGE .
  only:
    - main

push:
  stage: push
  script:
    - echo "Logging in to Docker Hub..."
    - echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
    - docker push $DOCKER_IMAGE
  only:
    - main

deploy:
  stage: deploy
  script:
    - echo "Deploying to Kubernetes..."
    - kubectl apply -f k8s/
    - kubectl rollout status deployment/hello-deploy
  only:
    - main
```

## HASIL :

<img width="490" height="180" alt="image" src="https://github.com/user-attachments/assets/3ff7e85d-be32-4cf5-a6df-1749d46d93dc" />

<img width="761" height="287" alt="image" src="https://github.com/user-attachments/assets/a1a72afc-b34a-4c1f-b21b-1142d704bfdc" />

<img width="425" height="379" alt="image" src="https://github.com/user-attachments/assets/1577c42f-c892-41c7-8452-5ca013844f84" />


