# Best Buy - Cloud-Native Microservices Application

## Overview

This is a cloud-native microservices application built for Best Buy, demonstrating modern DevOps practices and Kubernetes deployment. The application consists of 5 microservices that work together to provide a complete e-commerce solution.

## Architecture

### Architecture Diagram

![Architecture Diagram](architecture-diagram.png)

*Note: Please add your Draw.io architecture diagram here. The diagram should show:*
- All 5 microservices and their interactions
- MongoDB StatefulSet
- RabbitMQ message queue
- Kubernetes cluster components
- CI/CD pipeline flow
- External access points (LoadBalancers)

### Application Components

The application consists of the following microservices:

1. **Store-Front** - Customer-facing web application built with Vue.js
   - Allows customers to browse products and place orders
   - Port: 8080

2. **Store-Admin** - Employee web application built with Vue.js
   - Allows employees to manage products and process orders
   - Port: 8081

3. **Order-Service** - Order processing API built with Node.js/Fastify
   - Handles order creation and management
   - Port: 3000
   - Communicates with RabbitMQ for order queuing

4. **Product-Service** - Product management API built with Rust/Actix
   - Manages product catalog and inventory
   - Port: 3002

5. **Makeline-Service** - Background worker service built with Go/Gin
   - Processes orders from the queue and updates order status
   - Port: 3001
   - Consumes messages from RabbitMQ and stores data in MongoDB

### Infrastructure Components

- **MongoDB** - StatefulSet for persistent order storage
- **RabbitMQ** - Message queue for asynchronous order processing

## Repository Links

| Service | GitHub Repository | Docker Hub Image |
|---------|------------------|------------------|
| Store-Front | [store-front-bestbuy](https://github.com/nada0038/store-front-bestbuy) | [nada0038/store-front-bestbuy](https://hub.docker.com/r/nada0038/store-front-bestbuy) |
| Store-Admin | [store-admin-bestbuy](https://github.com/nada0038/store-admin-bestbuy) | [nada0038/store-admin-bestbuy](https://hub.docker.com/r/nada0038/store-admin-bestbuy) |
| Order-Service | [order-service-bestbuy](https://github.com/nada0038/order-service-bestbuy) | [nada0038/order-service-bestbuy](https://hub.docker.com/r/nada0038/order-service-bestbuy) |
| Product-Service | [product-service-bestbuy](https://github.com/nada0038/product-service-bestbuy) | [nada0038/product-service-bestbuy](https://hub.docker.com/r/nada0038/product-service-bestbuy) |
| Makeline-Service | [makeline-service-bestbuy](https://github.com/nada0038/makeline-service-bestbuy) | [nada0038/makeline-service-bestbuy](https://hub.docker.com/r/nada0038/makeline-service-bestbuy) |

## Prerequisites

- Azure subscription (Student subscription works)
- Azure CLI installed and configured
- kubectl installed
- Docker installed (for local development)
- Access to Docker Hub (for pushing images)

## Deployment Instructions

### 1. Create Azure Kubernetes Service (AKS) Cluster

Follow the instructions in [AKS-SETUP.md](AKS-SETUP.md) to create your AKS cluster.

### 2. Configure kubectl

After creating the AKS cluster, configure kubectl to connect to your cluster:

```bash
az aks get-credentials --resource-group <resource-group-name> --name <aks-cluster-name>
```

### 3. Deploy Application

Deploy all components in order:

```bash
# Navigate to Deployment Files directory
cd "Deployment Files"

# Apply all manifests in order
kubectl apply -f 01-namespace.yaml
kubectl apply -f 05-secrets.yaml
kubectl apply -f 04-configmaps.yaml
kubectl apply -f 02-mongodb-statefulset.yaml
kubectl apply -f 03-rabbitmq-deployment.yaml

# Wait for MongoDB and RabbitMQ to be ready
kubectl wait --for=condition=ready pod -l app=mongodb -n bestbuy --timeout=300s
kubectl wait --for=condition=ready pod -l app=rabbitmq -n bestbuy --timeout=300s

# Deploy microservices
kubectl apply -f 06-product-service.yaml
kubectl apply -f 07-order-service.yaml
kubectl apply -f 08-makeline-service.yaml
kubectl apply -f 09-store-front.yaml
kubectl apply -f 10-store-admin.yaml
```

### 4. Verify Deployment

Check the status of all pods:

```bash
kubectl get pods -n bestbuy
```

Check services:

```bash
kubectl get services -n bestbuy
```

### 5. Access the Application

Get the external IP addresses for the frontend services:

```bash
# Get Store-Front URL
kubectl get service store-front -n bestbuy

# Get Store-Admin URL
kubectl get service store-admin -n bestbuy
```

The LoadBalancer services will be assigned external IPs. Access:
- **Store-Front**: `http://<store-front-external-ip>`
- **Store-Admin**: `http://<store-admin-external-ip>`

## CI/CD Pipeline

Each microservice has a GitHub Actions workflow that:
1. Builds the Docker image on push to `main` branch
2. Pushes the image to Docker Hub with tags: `latest` and commit SHA
3. Can be extended to deploy to AKS automatically

### Setting up CI/CD Secrets

In each GitHub repository, add the following secrets:
- `DOCKERHUB_USERNAME`: Your Docker Hub username (nada0038)
- `DOCKERHUB_TOKEN`: Your Docker Hub access token

### Building and Pushing Docker Images

**Important**: The Docker images must be built and pushed to Docker Hub before deploying to Kubernetes. 

See [BUILD-AND-PUSH-IMAGES.md](BUILD-AND-PUSH-IMAGES.md) for detailed instructions on:
- Building images manually
- Setting up CI/CD to build automatically
- Troubleshooting 404 errors

**Quick Start**: Use the provided PowerShell script:
```powershell
# Make sure you're logged into Docker Hub first
docker login

# Run the build script
.\build-all-images.ps1
```

## Local Development

### Running with Docker Compose

Each service includes a `docker-compose.yml` file for local development:

```bash
cd store-front-bestbuy
docker-compose up
```

## Monitoring and Troubleshooting

### View Logs

```bash
# View logs for a specific service
kubectl logs -f deployment/product-service -n bestbuy

# View logs for all pods in namespace
kubectl logs -f -l app=product-service -n bestbuy
```

### Check Service Health

```bash
# Port forward to test services locally
kubectl port-forward service/product-service 3002:3002 -n bestbuy

# Test health endpoint
curl http://localhost:3002/health
```

### Common Issues

1. **Pods not starting**: Check pod logs and describe the pod for events
   ```bash
   kubectl describe pod <pod-name> -n bestbuy
   ```

2. **Services not accessible**: Verify service endpoints
   ```bash
   kubectl get endpoints -n bestbuy
   ```

3. **MongoDB connection issues**: Ensure MongoDB StatefulSet is ready
   ```bash
   kubectl get statefulset mongodb -n bestbuy
   ```

## Demo Video

[Link to YouTube Demo Video](https://www.youtube.com/watch?v=YOUR_VIDEO_ID)

*Please add your demo video link here after uploading to YouTube.*

## Project Structure

```
Best-Buy/
├── Deployment Files/          # Kubernetes manifests
│   ├── 01-namespace.yaml
│   ├── 02-mongodb-statefulset.yaml
│   ├── 03-rabbitmq-deployment.yaml
│   ├── 04-configmaps.yaml
│   ├── 05-secrets.yaml
│   ├── 06-product-service.yaml
│   ├── 07-order-service.yaml
│   ├── 08-makeline-service.yaml
│   ├── 09-store-front.yaml
│   └── 10-store-admin.yaml
├── store-front-bestbuy/       # Customer web app
├── store-admin-bestbuy/       # Employee web app
├── order-service-bestbuy/     # Order API
├── product-service-bestbuy/   # Product API
├── makeline-service-bestbuy/  # Background worker
└── README.md                  # This file
```

## Technologies Used

- **Frontend**: Vue.js 3, Nginx
- **Backend**: Node.js (Fastify), Go (Gin), Rust (Actix)
- **Database**: MongoDB
- **Message Queue**: RabbitMQ
- **Container Orchestration**: Kubernetes (AKS)
- **CI/CD**: GitHub Actions
- **Container Registry**: Docker Hub

## Contributors

- nada0038

## License

This project is for educational purposes.
