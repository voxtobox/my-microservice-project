#!/bin/bash

# Скрипт для швидкого запуску після destroy (Варіант 1)
# Створює тільки дорогі компоненти, використовує існуючі VPC та ECR

set -e  # Зупинитися при помилці

echo "=== Terraform Init & Apply Script (Варіант 1) ==="
echo ""

# Експорт необхідних змінних
export TFENV_ARCH=amd64
export GODEBUG=asyncpreemptoff=1

# 1. Перевірка secrets.auto.tfvars
echo "📝 Крок 1: Перевірка змінних..."
if [ ! -f secrets.auto.tfvars ]; then
    echo "⚠️  Файл secrets.auto.tfvars не знайдено!"
    echo "   Створіть його з прикладу:"
    echo "   cp secrets.auto.tfvars.example secrets.auto.tfvars"
    echo "   та заповніть необхідні значення"
    exit 1
fi
echo "✅ secrets.auto.tfvars знайдено"
echo ""

# 2. Terraform init
echo "📝 Крок 2: Ініціалізація Terraform..."
if [ -d .terraform ]; then
    echo "  Очищення старого .terraform..."
    rm -rf .terraform
fi
terraform init
echo "✅ Terraform ініціалізовано"
echo ""

# 3. Перевірка, чи існують ресурси, які потрібно імпортувати
echo "📝 Крок 3: Перевірка існуючих ресурсів..."
if aws eks describe-cluster --name eks-cluster-demo --region us-west-1 &>/dev/null; then
    echo "⚠️  EKS кластер вже існує!"
    echo "   Перевіряємо, чи він в state..."
    
    if ! terraform state list | grep -q "module.eks.aws_eks_cluster.eks"; then
        echo "   EKS кластер не в state, потрібен імпорт"
        echo ""
        read -p "Імпортувати існуючий EKS кластер? (yes/no): " import_confirm
        
        if [ "$import_confirm" = "yes" ]; then
            echo "  Імпорт EKS кластера..."
            terraform import module.eks.aws_eks_cluster.eks eks-cluster-demo || true
            
            echo "  Імпорт IAM ролей..."
            terraform import module.eks.aws_iam_role.eks eks-cluster-demo-eks-cluster || true
            terraform import module.eks.aws_iam_role.nodes eks-cluster-demo-eks-nodes || true
            
            echo "✅ Імпорт завершено"
        else
            echo "⚠️  Продовжуємо без імпорту (можуть виникнути помилки про вже існуючі ресурси)"
        fi
    else
        echo "✅ EKS кластер вже в state"
    fi
else
    echo "✅ EKS кластер не існує, буде створено новий"
fi
echo ""

# 4. Terraform plan
echo "📝 Крок 4: Планування змін..."
echo "⚠️  Це створить/оновить:"
echo "    • EKS кластер (якщо не існує)"
echo "    • Jenkins з автоматичною конфігурацією"
echo "    • Argo CD з Application та Repository"
echo ""
echo "    Використає існуючі:"
echo "    • VPC (якщо існує)"
echo "    • ECR репозиторій (якщо існує)"
echo ""
read -p "Продовжити з plan? (yes/no): " plan_confirm

if [ "$plan_confirm" != "yes" ]; then
    echo "❌ Plan скасовано"
    exit 1
fi

terraform plan

echo ""
read -p "Застосувати зміни? (yes/no): " apply_confirm

if [ "$apply_confirm" != "yes" ]; then
    echo "❌ Apply скасовано"
    exit 1
fi

# 5. Terraform apply
echo ""
echo "📝 Крок 5: Застосування конфігурації..."
echo "🔥 Починаємо створення ресурсів..."
echo ""

terraform apply -auto-approve

echo ""
echo "=== ✅ Apply завершено! ==="
echo ""
echo "📋 Корисні команди:"
echo "  • Jenkins URL:"
echo "    kubectl get svc -n jenkins jenkins -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
echo ""
echo "  • Argo CD URL:"
echo "    kubectl get svc -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
echo ""
echo "  • Argo CD пароль:"
echo "    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
echo ""
echo "  • Перевірити nodes: kubectl get nodes"
echo "  • Перевірити кластер: aws eks describe-cluster --name eks-cluster-demo --region us-west-1"
echo "  • Outputs: terraform output"
echo ""

