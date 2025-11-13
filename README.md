# DevOps Microservice Project

## Lesson 8-9: Jenkins + Argo CD + CI/CD

### Опис проекту

Проект створює повний CI/CD pipeline з використанням Jenkins, Helm, Terraform та Argo CD. Автоматично збирає Docker-образ для Django-застосунку, публікує його в Amazon ECR, оновлює Helm chart у репозиторії та синхронізує застосунок у кластері через Argo CD.

### Структура проекту

```
.
├── main.tf
├── backend.tf
├── terraform.tf
├── variables.tf
├── outputs.tf
├── kubernetes_providers.tf
├── secrets.auto.tfvars.example
├── modules/
│   ├── vpc/
│   ├── ecr/
│   ├── eks/
│   ├── jenkins/
│   │   ├── jenkins.tf
│   │   ├── variables.tf
│   │   ├── providers.tf
│   │   ├── values.yaml.tpl
│   │   └── outputs.tf
│   └── argo_cd/
│       ├── argo_cd.tf
│       ├── variables.tf
│       ├── providers.tf
│       ├── values.yaml
│       ├── outputs.tf
│       └── charts/
│           ├── Chart.yaml
│           ├── values.yaml.tpl
│           └── templates/
│               ├── application.yaml
│               └── repository.yaml
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
3. **EKS** - Kubernetes кластер з EBS CSI Driver
4. **Jenkins** - CI/CD сервер з Kaniko для збірки образів
5. **Argo CD** - GitOps інструмент для автоматичної синхронізації
6. **Helm Chart**:
   - Deployment з Django (2-6 реплік)
   - Service типу LoadBalancer
   - ConfigMap зі змінними середовища
   - HPA (автомасштабування при CPU > 70%)

### Кроки розгортання

#### 1. Налаштування змінних

Скопіюйте приклад файлу з секретами та заповніть його:

```bash
cp secrets.auto.tfvars.example secrets.auto.tfvars
```

Відредагуйте `secrets.auto.tfvars` та вкажіть:

- `github_username` - ваш GitHub username
- `github_pat` - GitHub Personal Access Token з правами `repo`
- `github_repo_url` - URL репозиторію з Jenkinsfile та Django кодом
- `app_repo_url` - URL репозиторію з Helm chart (зазвичай той самий)
- `app_repo_username` - GitHub username для Argo CD
- `app_repo_password` - GitHub PAT для Argo CD

#### 2. Застосування Terraform

```bash
terraform init
terraform plan
terraform apply
```

Terraform створить:

- VPC, ECR, EKS кластер
- Jenkins з автоматичною конфігурацією через JCasC
- Argo CD з Application та Repository для Helm chart

**Примітка:** Якщо EKS кластер вже існує, може знадобитися імпорт ресурсів:

```bash
terraform import module.eks.aws_eks_cluster.eks eks-cluster-demo
terraform import module.eks.aws_iam_role.eks eks-cluster-demo-eks-cluster
terraform import module.eks.aws_iam_role.nodes eks-cluster-demo-eks-nodes
```

#### 3. Налаштування kubectl

```bash
aws eks update-kubeconfig --name eks-cluster-demo --region us-west-1
```

#### 4. Перевірка Jenkins

Отримайте URL Jenkins LoadBalancer:

```bash
kubectl get svc -n jenkins jenkins -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

Або через Terraform output (namespace):

```bash
terraform output jenkins_namespace
```

Відкрийте Jenkins UI в браузері:

- **Username:** `admin`
- **Password:** `admin`

**Перевірка Jenkins job:**

1. У Jenkins UI знайдіть job `seed-job`
2. Натисніть **"Build Now"** для запуску
3. Після успішного виконання `seed-job` з'явиться pipeline `goit-django-docker`
4. Запустіть pipeline `goit-django-docker` - він:
   - Збере Docker образ з Django застосунком
   - Запушить його до ECR
   - Оновить `values.yaml` в Git репозиторії з новим тегом образу

Перевірте логи pipeline для діагностики:

- Відкрийте job → **"Console Output"**

#### 5. Перевірка Argo CD

Отримайте URL Argo CD LoadBalancer:

```bash
kubectl get svc -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

**Примітка:** Якщо LoadBalancer ще не призначив IP (статус `<pending>`), зачекайте кілька хвилин та перевірте знову.

Отримайте початковий пароль адміністратора:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Відкрийте Argo CD UI в браузері:

- **Username:** `admin`
- **Password:** (з команди вище)

**Як побачити результат в Argo CD:**

1. Після входу в Argo CD UI ви побачите Application (наприклад, `example-app`)
2. Натисніть на Application для перегляду деталей
3. Argo CD автоматично синхронізує зміни з Git репозиторію
4. Якщо Jenkins оновив `values.yaml` з новим тегом образу, Argo CD:
   - Визначить зміни в Git
   - Автоматично синхронізує (якщо увімкнено `automated.syncPolicy`)
   - Оновить Deployment в Kubernetes з новим образом

**Статуси в Argo CD:**

- 🟢 **Synced** - Application синхронізовано з Git
- 🟡 **OutOfSync** - Є зміни в Git, які потрібно синхронізувати
- 🔴 **Degraded** - Помилка синхронізації

**Ручна синхронізація:**

- Натисніть кнопку **"Sync"** на Application
- Виберіть ресурси для синхронізації
- Натисніть **"Synchronize"**

#### 6. Перевірка застосунку

```bash
kubectl get pods -n default
kubectl get svc -n default
kubectl get hpa -n default
```

### Параметри

- **Replicas**: мін 2, макс 6
- **CPU threshold**: 70%
- **Service type**: LoadBalancer
- **Instance type**: t4g.small (ARM)

### Очищення

```bash
# Видалити Helm releases
helm uninstall django-app -n default
helm uninstall jenkins -n jenkins
helm uninstall argocd -n argocd
helm uninstall argocd-apps -n argocd

# Видалити інфраструктуру
terraform destroy
```

**Примітка:** Якщо виникають помилки з lock файлами:

```bash
terraform force-unlock -force <LOCK_ID>
```
