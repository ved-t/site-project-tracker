#!/bin/bash

echo "Enter feature name:"
read feature

# convert to lowercase
feature=$(echo "$feature" | tr '[:upper:]' '[:lower:]')

BASE="lib/features/$feature"

mkdir -p $BASE/data/datasource
mkdir -p $BASE/data/models
mkdir -p $BASE/data/repositories

mkdir -p $BASE/domain/entities
mkdir -p $BASE/domain/repositories
mkdir -p $BASE/domain/usecase

mkdir -p $BASE/presentation/controllers
mkdir -p $BASE/presentation/screens
mkdir -p $BASE/presentation/widgets

echo "Feature '$feature' created successfully!"