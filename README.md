# Lab Project: Cloud-Native App for Best Buy

### Akash Nadackanal Vinod

## Demo Video

**[YouTube Demo Video](https://youtube.com)**

---

## Overview

This project is a cloud-native microservices application built for Best Buy, demonstrating modern DevOps practices and Kubernetes deployment. The application is based on the Algonquin Pet Store (On Steroids) architecture and consists of 5 microservices that work together to provide a complete e-commerce solution.

### Brief Application Explanation

The Best Buy application is designed as a microservices-based e-commerce platform where:

- **Customers** can browse products and place orders through the Store-Front web application
- **Employees** can manage products and process orders through the Store-Admin web application
- **Order-Service** handles order creation and queues orders to RabbitMQ for asynchronous processing
- **Product-Service** manages the product catalog and inventory
- **Makeline-Service** processes orders from the message queue and stores them in MongoDB

The architecture follows cloud-native principles with containerization, orchestration, and automated CI/CD pipelines. Each service is independently deployable and scalable, making the system resilient and maintainable.

---

## Architecture Diagram

The architecture diagram shows the complete system design, including all microservices, infrastructure components, and the CI/CD pipeline.

**View the architecture diagram:** [architecture-diagram.md](architecture-diagram.md)

### Design Choices

- **Microservices Architecture**: Each service is independently deployable, allowing for better scalability and maintainability
- **Kubernetes Orchestration**: Using AKS for container orchestration provides automatic scaling, self-healing, and service discovery
- **Message Queue (RabbitMQ)**: Asynchronous order processing ensures the system remains responsive even under high load
- **StatefulSet for MongoDB**: Ensures persistent storage with stable network identities for the database
- **ConfigMaps and Secrets**: Centralized configuration management and secure credential storage
- **CI/CD Pipeline**: Automated builds and deployments reduce manual errors and speed up the development cycle

---

## Application Components

### Microservices

1. **Store-Front** - Customer-facing web application
   - Technology: Vue.js 3, Nginx
   - Port: 8080
   - Purpose: Allows customers to browse products and place orders

2. **Store-Admin** - Employee web application
   - Technology: Vue.js 3, Nginx
   - Port: 8081
   - Purpose: Allows employees to manage products and process orders

3. **Order-Service** - Order processing API
   - Technology: Node.js, Fastify
   - Port: 3000
   - Purpose: Handles order creation and queues orders to RabbitMQ

4. **Product-Service** - Product management API
   - Technology: Rust, Actix Web
   - Port: 3002
   - Purpose: Manages product catalog and inventory

5. **Makeline-Service** - Background worker service
   - Technology: Go, Gin
   - Port: 3001
   - Purpose: Processes orders from RabbitMQ queue and stores them in MongoDB

### Infrastructure Components

- **MongoDB** - StatefulSet for persistent order storage (Port: 27017)
- **RabbitMQ** - Message queue for asynchronous order processing (Port: 5672)

---

## Repository Links and Docker Hub Images

| Service | GitHub Repository | Docker Hub Image |
|---------|------------------|------------------|
| Store-Front | [store-front-bestbuy](https://github.com/nada0038/store-front-bestbuy) | [nada0038/store-front-bestbuy](https://hub.docker.com/r/nada0038/store-front-bestbuy) |
| Store-Admin | [store-admin-bestbuy](https://github.com/nada0038/store-admin-bestbuy) | [nada0038/store-admin-bestbuy](https://hub.docker.com/r/nada0038/store-admin-bestbuy) |
| Order-Service | [order-service-bestbuy](https://github.com/nada0038/order-service-bestbuy) | [nada0038/order-service-bestbuy](https://hub.docker.com/r/nada0038/order-service-bestbuy) |
| Product-Service | [product-service-bestbuy](https://github.com/nada0038/product-service-bestbuy) | [nada0038/product-service-bestbuy](https://hub.docker.com/r/nada0038/product-service-bestbuy) |
| Makeline-Service | [makeline-service-bestbuy](https://github.com/nada0038/makeline-service-bestbuy) | [nada0038/makeline-service-bestbuy](https://hub.docker.com/r/nada0038/makeline-service-bestbuy) |

### Deployment Files

All Kubernetes deployment manifests are located in the [Deployment Files/](Deployment%20Files/) directory.

---

## Deployment Instructions

### Prerequisites

- Azure Kubernetes Service (AKS) cluster
- `kubectl` configured to access your AKS cluster
- Docker Hub account with access tokens
- GitHub account with Actions enabled

### Step 1: Configure Kubernetes Access

1. Get your AKS credentials:
   ```bash
   az aks get-credentials --resource-group bestbuy-rg --name bestbuy-aks --overwrite-existing
   ```

2. Verify cluster access:
   ```bash
   kubectl get nodes
   ```

### Step 2: Set Up GitHub Secrets

For each microservice repository, add the following secrets under **Settings → Secrets and variables → Actions**:

- `DOCKER_USERNAME`: nada0038
- `DOCKER_PASSWORD`: Docker Hub access token
- `KUBE_CONFIG`: Base64-encoded Kubernetes configuration file

For detailed instructions on setting up `KUBE_CONFIG`, see [`.github/KUBE_CONFIG_SETUP.md`](.github/KUBE_CONFIG_SETUP.md)

### Step 3: Deploy to Kubernetes

All Kubernetes deployment manifests are located in the `Deployment Files/` directory. Deploy them in order:

```bash
# 1. Create namespace
kubectl apply -f "Deployment Files/01-namespace.yaml"

# 2. Deploy MongoDB StatefulSet
kubectl apply -f "Deployment Files/02-mongodb-statefulset.yaml"

# 3. Deploy RabbitMQ
kubectl apply -f "Deployment Files/03-rabbitmq-deployment.yaml"

# 4. Create ConfigMaps
kubectl apply -f "Deployment Files/04-configmaps.yaml"

# 5. Create Secrets
kubectl apply -f "Deployment Files/05-secrets.yaml"

# 6. Deploy Product Service
kubectl apply -f "Deployment Files/06-product-service.yaml"

# 7. Deploy Order Service
kubectl apply -f "Deployment Files/07-order-service.yaml"

# 8. Deploy Makeline Service
kubectl apply -f "Deployment Files/08-makeline-service.yaml"

# 9. Deploy Store-Front
kubectl apply -f "Deployment Files/09-store-front.yaml"

# 10. Deploy Store-Admin
kubectl apply -f "Deployment Files/10-store-admin.yaml"
```

### Step 4: Verify Deployment

Check the status of all deployments:

```bash
# Check all pods
kubectl get pods -n bestbuy

# Check all services
kubectl get svc -n bestbuy

# Check deployment status
kubectl get deployments -n bestbuy
```

### Step 5: Access the Application

Get the external IPs for the LoadBalancer services:

```bash
kubectl get svc -n bestbuy
```

Access the applications:
- **Store-Front**: `http://52.240.209.87/`
- **Store-Admin**: `http://130.131.29.143/`
- **RabbitMQ**: `http://localhost:15672/`

---

## CI/CD Pipeline

Each microservice has a GitHub Actions workflow that automatically:

1. Builds Docker images when code is pushed to the `main` branch
2. Pushes images to Docker Hub with tags: `latest` and commit SHA
3. Deploys to Kubernetes (AKS) automatically

### Testing the CI/CD Pipeline

1. Make a change to any service code
2. Commit and push to the `main` branch:
   ```bash
   git add .
   git commit -m "Update service"
   git push origin main
   ```
3. Go to the repository's **Actions** tab on GitHub
4. Watch the workflow build and deploy the service
5. Verify the deployment in your Kubernetes cluster

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
│   ├── 09-store-front.yaml        # Store-Front deployment
│   └── 10-store-admin.yaml       # Store-Admin deployment
├── .github/
│   ├── workflows/                # CI/CD pipeline workflows
│   └── KUBE_CONFIG_SETUP.md      # Kubernetes setup guide
├── architecture-diagram.md       # Architecture diagram
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

## Notes

- All services are containerized using Docker
- Kubernetes ConfigMaps and Secrets are used for configuration management
- MongoDB uses StatefulSet for persistent storage
- CI/CD pipelines are implemented for each microservice
- The application follows cloud-native best practices
  
### Tools Used
Draw.io (for diagram)

### AI usage
Chatgpt used to make md files from normal text.
