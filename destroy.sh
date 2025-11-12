#!/bin/bash

# Скрипт для правильного destroy Terraform ресурсів
# Після цього можна знову запустити terraform init && terraform apply

set -e  # Зупинитися при помилці

echo "=== Terraform Destroy Script ==="
echo ""

# Експорт необхідних змінних
export TFENV_ARCH=amd64
export GODEBUG=asyncpreemptoff=1

# 1. Закоментувати модуль s3_backend в main.tf та outputs.tf
echo "📝 Крок 1: Закоментування модуля s3_backend..."
sed -i.bak '/^module "s3_backend"/,/^}/s/^/# /' main.tf
sed -i.bak '/^output "s3_bucket_name"/,/^}/s/^/# /; /^output "dynamodb_table_name"/,/^}/s/^/# /' outputs.tf
echo "✅ Модуль s3_backend і його outputs закоментовано"
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
    mv outputs.tf.bak outputs.tf 2>/dev/null || true
    mv backend.tf.disabled backend.tf 2>/dev/null || true
    exit 1
fi

echo ""
echo "🔥 Починаємо видалення ресурсів..."
echo ""

terraform destroy

echo ""
echo "=== ✅ Destroy завершено! ==="
echo ""

# 5. Повернути все назад для наступного запуску
echo "📝 Крок 5: Відновлення конфігурації..."

# Розкоментувати s3_backend в main.tf
if [ -f main.tf.bak ]; then
    sed -i '' '/^# module "s3_backend"/,/^# }/s/^# //' main.tf
    echo "✅ Модуль s3_backend розкоментовано"
fi

# Розкоментувати outputs
if [ -f outputs.tf.bak ]; then
    sed -i '' '/^# output "s3_bucket_name"/,/^# }/s/^# //; /^# output "dynamodb_table_name"/,/^# }/s/^# //' outputs.tf
    echo "✅ Outputs розкоментовано"
fi

# Повернути backend.tf
if [ -f backend.tf.disabled ]; then
    mv backend.tf.disabled backend.tf
    echo "✅ backend.tf відновлено"
fi

# Видалити backup файли
rm -f main.tf.bak outputs.tf.bak

echo ""
echo "📋 Що було зроблено:"
echo "  ✓ Видалено: EKS кластер, VPC, ECR repository"
echo "  ✓ Залишено: S3 bucket, DynamoDB таблиця"
echo "  ✓ Конфігурація відновлена для наступного запуску"
echo ""
echo "📋 Для наступного запуску просто виконай:"
echo "  terraform init && terraform apply"
echo ""
echo "  Або використай скрипт:"
echo "  ./init-and-apply.sh"
echo ""

