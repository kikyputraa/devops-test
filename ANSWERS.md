# 1. Strategi agar aplikasi tetap berjalan dan selalu available 24/7

Untuk memastikan aplikasi selalu berjalan stabil dan tidak mengalami downtime, saya menerapkan beberapa strategi berikut:

## a. Menjalankan aplikasi di dalam container

Aplikasi dijalankan menggunakan Docker sehingga environment lebih konsisten dan meminimalkan error akibat perbedaan konfigurasi server.

## b. Orkestrasi menggunakan Kubernetes (Minikube)

Dengan menggunakan Kubernetes, aplikasi dijalankan dalam bentuk Deployment yang memiliki mekanisme:

Self-healing → Jika pod crash, Kubernetes otomatis membuat pod baru.

ReplicaSet → Menjaga jumlah pod sesuai spesifikasi sehingga layanan tetap tersedia.

Rolling updates → Update versi aplikasi tanpa downtime.

## c. Nginx Ingress sebagai entry point

Nginx Ingress digunakan sebagai load balancer dan reverse proxy, memastikan:

Routing trafik stabil

Mendukung konfigurasi SSL/TLS

Mendukung zero-downtime deployment

## d. CI/CD pipeline

Menggunakan Jenkins / GitHub Actions untuk:

Build otomatis

Test otomatis

Deploy otomatis

Dengan pipeline otomatis, resiko human-error berkurang dan aplikasi bisa selalu berada pada kondisi siap jalan.

## e. Monitoring dan logging

Menambahkan observability menggunakan:

Metrics (misal: Kubernetes metrics server / Prometheus)

Logging (Docker logs, kubectl logs, atau ELK stack jika diperlukan)

Monitoring memastikan masalah bisa terdeteksi lebih cepat sebelum menyebabkan downtime.

# 2. Strategi mengatasi lonjakan traffic

Untuk menghadapi rencana peningkatan traffic (scaling plan), beberapa strategi diterapkan:

## a. Horizontal Pod Autoscaler (HPA)

Menggunakan HPA di Kubernetes untuk melakukan autoscaling berdasarkan:

CPU usage

Memory usage

Custom metrics

Ketika load meningkat → jumlah pod otomatis bertambah.
Ketika load turun → pod otomatis dikurangi agar efisien.

## b. Nginx Ingress load balancing

Nginx Ingress mendistribusikan trafik ke banyak pod secara merata, mencegah bottleneck dan meningkatkan throughput.

## c. Penggunaan container ringan dan optimal

Dengan:

Base image minimalis (misal: alpine)

Multi-stage build

Resource limit & request pada Kubernetes

Aplikasi menjadi lebih efisien dan scalable.

## d. Menjaga kualitas pipeline

Pipeline memastikan:

Build bersih dan konsisten

Deployment cepat

Aplikasi segera tersedia ketika perlu menambah lebih banyak pod

## e. Caching dan optimisasi aplikasi (opsional)

Jika dibutuhkan:

Caching di layer aplikasi

CDN untuk static files

Connection pooling

Optimasi log & DB

Strategi ini meningkatkan performa tanpa harus menambah banyak resource.
