#!/bin/bash

# Скрипт для правильного destroy Terraform ресурсів (Варіант 1)
# Видаляє тільки дорогі компоненти, залишає дешеві для економії коштів

set -e  # Зупинитися при помилці

echo "=== Terraform Destroy Script (Варіант 1) ==="
echo ""

# Експорт необхідних змінних
export TFENV_ARCH=amd64
export GODEBUG=asyncpreemptoff=1

# 1. Перевірка, чи Terraform ініціалізований
echo "📝 Крок 1: Перевірка Terraform..."
if [ ! -d .terraform ]; then
    echo "⚠️  Terraform не ініціалізований, виконуємо init..."
    terraform init
fi
echo "✅ Terraform готовий"
echo ""

# 2. Спочатку видалити Helm releases (щоб не залишилися залежності)
echo "📝 Крок 2: Видалення Helm releases..."
if kubectl get namespace jenkins &>/dev/null; then
    echo "  Видалення Jenkins..."
    helm uninstall jenkins -n jenkins 2>/dev/null || true
    echo "  ✅ Jenkins видалено"
fi

if kubectl get namespace argocd &>/dev/null; then
    echo "  Видалення Argo CD..."
    helm uninstall argocd -n argocd 2>/dev/null || true
    helm uninstall argocd-apps -n argocd 2>/dev/null || true
    echo "  ✅ Argo CD видалено"
fi
echo ""

# 3. Terraform destroy тільки дорогих компонентів
echo "📝 Крок 3: Видалення дорогих ресурсів..."
echo "⚠️  Зараз буде видалено:"
echo "    • EKS кластер (найбільш дорогий)"
echo "    • Jenkins (LoadBalancer та ресурси)"
echo "    • Argo CD (LoadBalancer та ресурси)"
echo ""
echo "✅ Залишаться (дешево/безкоштовно):"
echo "    • VPC (безкоштовно)"
echo "    • ECR репозиторій (безкоштовно для малих обсягів)"
echo "    • S3 bucket для state (дешево)"
echo "    • DynamoDB для locks (дешево)"
echo ""
read -p "Продовжити? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Destroy скасовано"
    exit 1
fi

echo ""
echo "🔥 Починаємо видалення ресурсів..."
echo ""

# Видалити модулі в правильному порядку (спочатку залежні)
terraform destroy -target=module.jenkins -target=module.argo_cd -target=module.eks -auto-approve

echo ""
echo "=== ✅ Destroy завершено! ==="
echo ""

echo "📋 Що було зроблено:"
echo "  ✓ Видалено: EKS кластер, Jenkins, Argo CD"
echo "  ✓ Залишено: VPC, ECR, S3 bucket, DynamoDB"
echo ""
echo "📋 Для наступного запуску використай:"
echo "  ./init-and-apply.sh"
echo ""
echo "  Або вручну:"
echo "  terraform init && terraform apply"
echo ""

