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

```
from fastapi import FastAPI
from fastapi.responses import JSONResponse

app = FastAPI()

@app.get("/")
def root():
    return JSONResponse(content={"msg": "Hello World"}, media_type="application/json")
```
