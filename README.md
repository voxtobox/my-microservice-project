# DevOps Microservice Project

## Lesson 7: Kubernetes з Helm

### Опис проекту

Проект створює інфраструктуру AWS з кластером Kubernetes (EKS), ECR репозиторієм для Docker-образів та розгортає Django-застосунок за допомогою Helm.

### Структура проекту

```
lesson-7/
├── main.tf
├── backend.tf
├── terraform.tf
├── outputs.tf
├── modules/
│   ├── vpc/
│   ├── ecr/
│   ├── eks/
│   └── s3-backend/
└── django-chart/
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
        ├── deployment.yaml
        ├── service.yaml
        ├── configmap.yaml
        └── hpa.yaml
```

### Компоненти

1. **VPC** - мережа з публічними підмережами
2. **ECR** - репозиторій для Docker-образів
3. **EKS** - Kubernetes кластер
4. **Helm Chart**:
   - Deployment з Django (2-6 реплік)
   - Service типу LoadBalancer
   - ConfigMap зі змінними середовища
   - HPA (автомасштабування при CPU > 70%)

### Кроки розгортання

#### 1. Розгортання інфраструктури

```bash
cd lesson-7
terraform init
terraform apply
```

#### 2. Налаштування kubectl

```bash
aws eks update-kubeconfig --name eks-cluster-demo --region us-west-1
```

#### 3. Завантаження Docker-образу до ECR

```bash
ECR_URL=$(terraform output -raw ecr_repository_url)
aws ecr get-login-password --region us-west-1 | docker login --username AWS --password-stdin $ECR_URL
docker tag your-django-image:latest $ECR_URL:latest
docker push $ECR_URL:latest
```

#### 4. Оновлення values.yaml

Замініть `ACCOUNT_ID` в `django-chart/values.yaml` на ваш AWS Account ID:

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
sed -i "s/ACCOUNT_ID/$ACCOUNT_ID/g" django-chart/values.yaml
```

#### 5. Встановлення Helm chart

```bash
helm install django-app ./django-chart
```

#### 6. Перевірка

```bash
kubectl get pods
kubectl get svc
kubectl get hpa
```

### Параметри

- **Replicas**: мін 2, макс 6
- **CPU threshold**: 70%
- **Service type**: LoadBalancer
- **Instance type**: t4g.small (ARM)

### Очищення

```bash
helm uninstall django-app
terraform destroy
```
