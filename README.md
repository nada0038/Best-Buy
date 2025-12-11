# Lab Project: Cloud-Native App for Best Buy

## Demo Video

**[YouTube]()**



---

## Overview

This is a cloud-native microservices application built for Best Buy, demonstrating modern DevOps practices and Kubernetes deployment. The application consists of 5 microservices that work together to provide a complete e-commerce solution, based on the Algonquin Pet Store (On Steroids) architecture.

### Brief Application Explanation

The Best Buy cloud-native application is a microservices-based e-commerce platform that allows customers to browse products, place orders, and enables employees to manage inventory and process orders. The application follows cloud-native principles with:

- **Microservices Architecture**: Each service is independently deployable and scalable
- **Containerization**: All services are containerized using Docker
- **Orchestration**: Deployed on Azure Kubernetes Service (AKS)
- **Message Queue**: Asynchronous order processing using RabbitMQ
- **Persistent Storage**: MongoDB StatefulSet for order data
- **CI/CD**: Automated build and deployment pipelines using GitHub Actions

The application flow:
1. Customers browse products and place orders through the **Store-Front** web app
2. Orders are sent to **Order-Service** which queues them in RabbitMQ
3. **Makeline-Service** processes orders from the queue and stores them in MongoDB
4. Employees use **Store-Admin** to view and process orders
5. **Product-Service** manages the product catalog

---


## Application Components

### Microservices

1. **Store-Front** - Customer-facing web application
   - Technology: Vue.js 3, Nginx
   - Port: 8080
   - Purpose: Allows customers to browse products and place orders
   - Repository: [store-front-bestbuy](https://github.com/nada0038/store-front-bestbuy)

2. **Store-Admin** - Employee web application
   - Technology: Vue.js 3, Nginx
   - Port: 8081
   - Purpose: Allows employees to manage products and process orders
   - Repository: [store-admin-bestbuy](https://github.com/nada0038/store-admin-bestbuy)

3. **Order-Service** - Order processing API
   - Technology: Node.js, Fastify
   - Port: 3000
   - Purpose: Handles order creation and queues orders to RabbitMQ
   - Repository: [order-service-bestbuy](https://github.com/nada0038/order-service-bestbuy)

4. **Product-Service** - Product management API
   - Technology: Rust, Actix Web
   - Port: 3002
   - Purpose: Manages product catalog and inventory
   - Repository: [product-service-bestbuy](https://github.com/nada0038/product-service-bestbuy)

5. **Makeline-Service** - Background worker service
   - Technology: Go, Gin
   - Port: 3001
   - Purpose: Processes orders from RabbitMQ queue and stores them in MongoDB
   - Repository: [makeline-service-bestbuy](https://github.com/nada0038/makeline-service-bestbuy)

### Infrastructure Components

- **MongoDB** - StatefulSet for persistent order storage
- **RabbitMQ** - Message queue for asynchronous order processing (AMQP 1.0)

---

## Repository Links and Docker Hub Images

| Service | GitHub Repository | Docker Hub Image |
|---------|------------------|------------------|
| Store-Front | [store-front-bestbuy](https://github.com/nada0038/store-front-bestbuy) | [nada0038/store-front-bestbuy](https://hub.docker.com/r/nada0038/store-front-bestbuy) |
| Store-Admin | [store-admin-bestbuy](https://github.com/nada0038/store-admin-bestbuy) | [nada0038/store-admin-bestbuy](https://hub.docker.com/r/nada0038/store-admin-bestbuy) |
| Order-Service | [order-service-bestbuy](https://github.com/nada0038/order-service-bestbuy) | [nada0038/order-service-bestbuy](https://hub.docker.com/r/nada0038/order-service-bestbuy) |
| Product-Service | [product-service-bestbuy](https://github.com/nada0038/product-service-bestbuy) | [nada0038/product-service-bestbuy](https://hub.docker.com/r/nada0038/product-service-bestbuy) |
| Makeline-Service | [makeline-service-bestbuy](https://github.com/nada0038/makeline-service-bestbuy) | [nada0038/makeline-service-bestbuy](https://hub.docker.com/r/nada0038/makeline-service-bestbuy) |

---



Access the applications:
Store front (http://52.240.209.87/)
Store Admin (http://130.131.29.143/)
RabbitMQ (http://localhost:15672/)

---

## CI/CD Pipeline

Each microservice has a GitHub Actions workflow (`.github/workflows/ci_cd.yaml`) that automatically:

1. **Builds** the Docker image when code is pushed to the `main` branch
2. **Pushes** the image to Docker Hub with tags:
   - `latest` - Always points to the most recent build
   - `${{ github.sha }}` - Tagged with the commit SHA for versioning

### Setting up CI/CD Secrets

In each GitHub repository, add the following secrets under **Settings → Secrets and variables → Actions**:

- `DOCKER_USERNAME`: Your Docker Hub username (e.g., `nada0038`)
- `DOCKER_PASSWORD`: Your Docker Hub access token

To create a Docker Hub access token:
1. Go to [Docker Hub](https://hub.docker.com/)
2. Sign in → Account Settings → Security
3. Create New Access Token with **Read & Write** permissions

### CI/CD Workflow Demonstration

To demonstrate the CI/CD pipeline:

1. Make a change to any service code
2. Commit and push to the `main` branch:
   ```bash
   git add .
   git commit -m "Update service"
   git push origin main
   ```
3. Go to the repository's **Actions** tab on GitHub
4. Watch the workflow build and push the Docker image
5. Verify the new image on Docker Hub

---

## Project Structure

```
Best-Buy/
├── Deployment Files/              # Kubernetes manifests
│   ├── 01-namespace.yaml         # Namespace definition
│   ├── 02-mongodb-statefulset.yaml  # MongoDB StatefulSet
│   ├── 03-rabbitmq-deployment.yaml  # RabbitMQ deployment
│   ├── 04-configmaps.yaml        # Configuration maps
│   ├── 05-secrets.yaml           # Secrets (credentials)
│   ├── 06-product-service.yaml   # Product service deployment
│   ├── 07-order-service.yaml     # Order service deployment
│   ├── 08-makeline-service.yaml  # Makeline service deployment
│   ├── 09-store-front.yaml       # Store-Front deployment
│   └── 10-store-admin.yaml       # Store-Admin deployment
├── store-front-bestbuy/          # Customer web app
│   ├── .github/workflows/        # CI/CD pipeline
│   ├── src/                      # Vue.js source code
│   ├── Dockerfile                # Container image definition
│   └── README.md                 # Service documentation
├── store-admin-bestbuy/          # Employee web app
│   ├── .github/workflows/        # CI/CD pipeline
│   ├── src/                      # Vue.js source code
│   ├── Dockerfile                # Container image definition
│   └── README.md                 # Service documentation
├── order-service-bestbuy/        # Order API
│   ├── .github/workflows/        # CI/CD pipeline
│   ├── routes/                   # API routes
│   ├── plugins/                  # Fastify plugins
│   ├── Dockerfile                # Container image definition
│   └── README.md                 # Service documentation
├── product-service-bestbuy/      # Product API
│   ├── .github/workflows/        # CI/CD pipeline
│   ├── src/                      # Rust source code
│   ├── Dockerfile                # Container image definition
│   └── README.md                 # Service documentation
├── makeline-service-bestbuy/     # Background worker
│   ├── .github/workflows/        # CI/CD pipeline
│   ├── *.go                      # Go source files
│   ├── Dockerfile                # Container image definition
│   └── README.md                 # Service documentation
└── README.md                     # This file
```

---

## Technologies Used

- **Frontend**: Vue.js 3, Nginx
- **Backend**: 
  - Node.js (Fastify) - Order Service
  - Go (Gin) - Makeline Service
  - Rust (Actix Web) - Product Service
- **Database**: MongoDB (StatefulSet)
- **Message Queue**: RabbitMQ
- **Container Orchestration**: Kubernetes (Azure Kubernetes Service - AKS)
- **CI/CD**: GitHub Actions
- **Container Registry**: Docker Hub
- **Infrastructure**: Microsoft Azure

---
