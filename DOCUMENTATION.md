📘 DevOps Test – Full Documentation

# 🚀 AssistX DevOps Test – Deployment + CI/CD Documentation

Proyek ini adalah implementasi aplikasi sederhana “Hello World”, 
containerization menggunakan Docker, deployment ke Kubernetes (Minikube), serta otomatisasi CI/CD menggunakan GitLab Runner (Shell Executor).

## 0. 📌 PREPARATION (LINUX SETUP)
1️⃣ Update Linux

```
sudo apt update && sudo apt upgrade -y
```
<img src=![WhatsApp Image 2025-11-28 at 19 16 02_99e9ec90](https://github.com/user-attachments/assets/f542dbf9-5c40-47d2-9211-86e0e04671ce)>

2️⃣ Install Git

```
sudo apt install git -y
```

3️⃣ Install Python

Untuk membuat aplikasi sederhana.

```
sudo apt install python3 python3-pip -y
```

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

Tambahkan user ke group docker:

```
sudo usermod -aG docker $USER
```

Test:

```
docker run hello-world
```

5️⃣ Install Docker Compose

```
sudo apt install docker-compose-plugin -y
```

6️⃣ Install kubectl

```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

7️⃣ Install Minikube

```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

Start Minikube:

```
minikube start --driver=docker
```

Instalasi NGINX Ingress + LoadBalancer (Minikube Tunnel)

```
minikube addons enable ingress
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
sudo -E minikube tunnel
```

## 1. 📌 Aplikasi – Spesifikasi

Aplikasi dibangun menggunakan Python + FastAPI, dengan requirement:

Endpoint: /

Response: JSON → {"msg": "Hello World"}

Header: Content-Type: application/json

Port: 8080

main.py :

```
from fastapi import FastAPI
from fastapi.responses import JSONResponse

app = FastAPI()

@app.get("/")
def root():
    return JSONResponse(content={"msg": "Hello World"}, media_type="application/json")
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

## 3. 📌 Kubernetes Deployment (Minikube)

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



