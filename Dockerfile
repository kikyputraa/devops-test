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
