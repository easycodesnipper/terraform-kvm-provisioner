#!/bin/bash
set -e

echo "Checking for required tools..."
if ! command -v terraform &> /dev/null; then
    echo "Error: terraform is not installed."
    exit 1
fi

if ! command -v mkisofs &> /dev/null; then
    echo "Warning: mkisofs is not installed. Some provider features might fail."
    echo "Install it with: sudo apt-get install mkisofs"
fi

echo "Running Terraform Format Check..."
terraform fmt -check

echo "Running Terraform Init..."
terraform init

echo "Running Terraform Validate..."
terraform validate

echo "All checks passed!"
