#!/bin/bash

# Скрипт для правильного destroy Terraform ресурсів
# Після цього можна знову запустити terraform init && terraform apply

set -e  # Зупинитися при помилці

echo "=== Terraform Destroy Script ==="
echo ""

# Експорт необхідних змінних
export TFENV_ARCH=amd64
export GODEBUG=asyncpreemptoff=1

# 1. Закоментувати модуль s3_backend в main.tf
echo "📝 Крок 1: Закоментування модуля s3_backend..."
sed -i.bak '/^module "s3_backend"/,/^}/s/^/# /' main.tf
echo "✅ Модуль s3_backend закоментовано"
echo ""

# 2. Видалити backend.tf (зробити backup)
echo "📝 Крок 2: Видалення backend.tf..."
if [ -f backend.tf ]; then
    mv backend.tf backend.tf.disabled
    echo "✅ backend.tf перейменовано в backend.tf.disabled"
else
    echo "⚠️  backend.tf не знайдено, пропускаємо"
fi
echo ""

# 3. Переініціалізація з локальним state
echo "📝 Крок 3: Переініціалізація Terraform з локальним state..."
rm -rf .terraform
terraform init
echo "✅ Terraform переініціалізовано"
echo ""

# 4. Terraform destroy
echo "📝 Крок 4: Видалення ресурсів..."
echo "⚠️  Зараз буде видалено: EKS, VPC, ECR"
echo "✅ Залишаться: S3 bucket, DynamoDB (для наступного разу)"
echo ""
read -p "Продовжити? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Destroy скасовано"
    # Повернути зміни
    mv main.tf.bak main.tf 2>/dev/null || true
    mv backend.tf.disabled backend.tf 2>/dev/null || true
    exit 1
fi

terraform destroy

echo ""
echo "=== ✅ Destroy завершено! ==="
echo ""
echo "📋 Що було зроблено:"
echo "  ✓ Видалено: EKS кластер, VPC, ECR repository"
echo "  ✓ Залишено: S3 bucket, DynamoDB таблиця"
echo ""
echo "📋 Для наступного запуску:"
echo "  1. terraform init"
echo "  2. terraform apply"
echo ""
echo "💡 Скрипт створив backup файли (.bak), можеш їх видалити:"
echo "   rm main.tf.bak"
echo ""

