# AWS ECR Setup Guide

This guide explains how to set up AWS ECR (Elastic Container Registry) for your LaTeX-On-HTTP project.

## Prerequisites

1. AWS Account with appropriate permissions
2. AWS CLI configured locally (for testing)
3. GitHub repository with Actions enabled

## Required GitHub Secrets

Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions):

### Required Secrets

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | AWS Access Key ID | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Access Key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |

### Optional Environment Variables

You can also set these as repository variables (Settings → Secrets and variables → Actions → Variables):

| Variable Name | Description | Default |
|---------------|-------------|---------|
| `AWS_REGION` | AWS region for ECR | `us-east-1` |
| `ECR_REPOSITORY_TL_DISTRIB` | ECR repository name for TL-Distrib | `latexonhttp-tl-distrib` |
| `ECR_REPOSITORY_PYTHON` | ECR repository name for Python | `latexonhttp-python` |
| `ECR_REPOSITORY_MAIN` | ECR repository name for main app | `latexonhttp` |

## AWS IAM Permissions

Create an IAM user with the following policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:PutImage",
                "ecr:CreateRepository",
                "ecr:DescribeRepositories"
            ],
            "Resource": "*"
        }
    ]
}
```

## Local Testing

### 1. Configure AWS CLI

```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and region
```

### 2. Set Environment Variables

```bash
export AWS_REGION=us-east-1
export ECR_REGISTRY=123456789012.dkr.ecr.us-east-1.amazonaws.com
export ECR_REPOSITORY_TL_DISTRIB=latexonhttp-tl-distrib
export ECR_REPOSITORY_PYTHON=latexonhttp-python
export ECR_REPOSITORY_MAIN=latexonhttp
```

### 3. Build and Push Images

```bash
# Build all images
make docker-build-all

# Push all images to ECR
make ecr-push-all

# Or push individual images
make ecr-push-tl-distrib
make ecr-push-python
make ecr-push-main
```

## Workflow Files

- **`.github/workflows/docker-hub-publish.yml`** - Original Docker Hub workflow
- **`.github/workflows/ecr-publish.yml`** - New ECR workflow

## Image URLs

After pushing, your images will be available at:

- `{ECR_REGISTRY}/latexonhttp-tl-distrib:debian`
- `{ECR_REGISTRY}/latexonhttp-tl-distrib:latest`
- `{ECR_REGISTRY}/latexonhttp-python:debian`
- `{ECR_REGISTRY}/latexonhttp-python:latest`
- `{ECR_REGISTRY}/latexonhttp:latest`

## Troubleshooting

### Common Issues

1. **Authentication Error**: Ensure AWS credentials are correctly set in GitHub secrets
2. **Repository Not Found**: The workflow will automatically create repositories if they don't exist
3. **Permission Denied**: Check IAM permissions for the ECR actions
4. **Region Mismatch**: Ensure the AWS region matches your ECR repositories

### Debug Commands

```bash
# Test AWS authentication
aws sts get-caller-identity

# List ECR repositories
aws ecr describe-repositories --region us-east-1

# Test ECR login
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
```

## Migration from Docker Hub

To migrate from Docker Hub to ECR:

1. Set up the GitHub secrets as described above
2. The ECR workflow will automatically create repositories on first run
3. You can keep both workflows running if needed
4. Update your deployment scripts to use ECR image URLs instead of Docker Hub URLs

## Cost Considerations

- **ECR Storage**: ~$0.10 per GB per month
- **Data Transfer**: Free within the same AWS region
- **API Calls**: $0.0004 per 1,000 requests

Compare this with Docker Hub's pricing for private repositories.
