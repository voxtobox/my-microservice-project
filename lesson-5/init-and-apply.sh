#!/bin/bash

# Скрипт для швидкого запуску після destroy

set -e  # Зупинитися при помилці

echo "=== Terraform Init & Apply Script ==="
echo ""

# Експорт необхідних змінних
export TFENV_ARCH=amd64
export GODEBUG=asyncpreemptoff=1

# 1. Розкоментувати s3_backend якщо він закоментований
echo "📝 Крок 1: Перевірка main.tf..."
if grep -q "^# module \"s3_backend\"" main.tf; then
    echo "Розкоментування модуля s3_backend..."
    sed -i.bak '/^# module "s3_backend"/,/^# }/s/^# //' main.tf
    echo "✅ Модуль s3_backend розкоментовано"
else
    echo "✅ Модуль s3_backend вже активний"
fi
echo ""

# 2. Повернути backend.tf якщо потрібно
echo "📝 Крок 2: Перевірка backend.tf..."
if [ ! -f backend.tf ] && [ -f backend.tf.disabled ]; then
    mv backend.tf.disabled backend.tf
    echo "✅ backend.tf відновлено"
elif [ -f backend.tf ]; then
    echo "✅ backend.tf вже існує"
else
    echo "⚠️  backend.tf не знайдено, створюємо..."
    cat > backend.tf << 'EOF'
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-vao-01"
    key            = "lesson-5/terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
EOF
    echo "✅ backend.tf створено"
fi
echo ""

# 3. Terraform init
echo "📝 Крок 3: Ініціалізація Terraform..."
rm -rf .terraform
terraform init
echo "✅ Terraform ініціалізовано"
echo ""

# 4. Terraform apply
echo "📝 Крок 4: Застосування конфігурації..."
echo "⚠️  Це створить: S3, DynamoDB, VPC, EKS, ECR"
echo ""

terraform apply

echo ""
echo "=== ✅ Apply завершено! ==="
echo ""
echo "📋 Корисні команди:"
echo "  • Перевірити nodes: kubectl get nodes"
echo "  • Перевірити кластер: aws eks describe-cluster --name eks-cluster-demo --region us-west-1"
echo "  • Outputs: terraform output"
echo ""

