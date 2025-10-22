#!/bin/bash

set -e

# Функція для перевірки чи інструмент вже встановлено
check_installed() {
    command -v "$1" >/dev/null 2>&1
}

echo "Starting installation of DevOps tools on macOS..."

# Перевірка Homebrew, встановлення якщо відсутній
if ! check_installed brew; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew is already installed"
fi

# Оновлення Homebrew
echo "Updating Homebrew..."
brew update

# Встановлення Docker
if check_installed docker; then
    echo "Docker is already installed"
else
    echo "Installing Docker..."
    brew install --cask docker
    echo "Please start Docker.app manually or from the Applications folder to finish setup."
fi

# Встановлення Docker Compose (Docker Desktop включає docker-compose, але перевіряємо окремо)
if check_installed docker-compose; then
    echo "Docker Compose is already installed"
else
    echo "Installing Docker Compose..."
    brew install docker-compose
fi

# Встановлення Python 3.9+ (brew автоматично ставить останню версію)
if check_installed python3; then
    PYTHON_VERSION=$(python3 -V 2>&1 | awk '{print $2}')
    echo "Detected Python version: $PYTHON_VERSION"
else
    echo "Installing Python 3.x..."
    brew install python
fi

# Встановлення Django через pip
if python3 -m django --version >/dev/null 2>&1; then
    echo "Django is already installed"
else
    echo "Installing Django..."
    pip3 install django
fi

echo "🎉 All DevOps tools have been installed successfully!"
