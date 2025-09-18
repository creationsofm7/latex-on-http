#!/bin/bash

# ECR Push Script for LaTeX-On-HTTP
# This script pushes Docker images to AWS ECR

set -e

# Configuration
AWS_REGION=${AWS_REGION:-us-east-1}
ECR_REGISTRY=${ECR_REGISTRY}
ECR_REPOSITORY_TL_DISTRIB=${ECR_REPOSITORY_TL_DISTRIB:-latexonhttp-tl-distrib}
ECR_REPOSITORY_PYTHON=${ECR_REPOSITORY_PYTHON:-latexonhttp-python}
ECR_REPOSITORY_MAIN=${ECR_REPOSITORY_MAIN:-latexonhttp}

# Check if ECR_REGISTRY is set
if [ -z "$ECR_REGISTRY" ]; then
    echo "Error: ECR_REGISTRY environment variable is not set"
    echo "Please set ECR_REGISTRY to your AWS account ID (e.g., 123456789012.dkr.ecr.us-east-1.amazonaws.com)"
    exit 1
fi

# Login to ECR
echo "Logging in to Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

# Function to push image with multiple tags
push_image() {
    local local_image=$1
    local ecr_repo=$2
    local tag=$3
    
    echo "Tagging and pushing $local_image to $ECR_REGISTRY/$ecr_repo:$tag"
    docker tag $local_image $ECR_REGISTRY/$ecr_repo:$tag
    docker push $ECR_REGISTRY/$ecr_repo:$tag
}

# Push TL-Distrib image
echo "Pushing TL-Distrib image..."
push_image "yoant/latexonhttp-tl-distrib:debian" $ECR_REPOSITORY_TL_DISTRIB "debian"
push_image "yoant/latexonhttp-tl-distrib:debian" $ECR_REPOSITORY_TL_DISTRIB "latest"

# Push Python image
echo "Pushing Python image..."
push_image "yoant/latexonhttp-python:debian" $ECR_REPOSITORY_PYTHON "debian"
push_image "yoant/latexonhttp-python:debian" $ECR_REPOSITORY_PYTHON "latest"

# Push main image
echo "Pushing main image..."
push_image "latexonhttp:latest" $ECR_REPOSITORY_MAIN "latest"

echo "All images pushed successfully to ECR!"
echo "Registry: $ECR_REGISTRY"
echo "Repositories:"
echo "  - $ECR_REPOSITORY_TL_DISTRIB"
echo "  - $ECR_REPOSITORY_PYTHON"
echo "  - $ECR_REPOSITORY_MAIN"
