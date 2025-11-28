📘 DevOps Test – Full Documentation

# 🚀 AssistX DevOps Test – Deployment + CI/CD Documentation

Proyek ini adalah implementasi aplikasi sederhana “Hello World”, 
containerization menggunakan Docker, deployment ke Kubernetes (Minikube), serta otomatisasi CI/CD menggunakan GitLab Runner (Shell Executor).

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

