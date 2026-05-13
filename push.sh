#!/bin/bash

MESSAGE="Auto commit: $(date)"

cd ~/final-project

if [ ! -d ".git" ]; then
    git init
    git remote add origin git@github.com:ramaatallah/final-project-UNIX.git
fi

git add .
git commit -m "$MESSAGE"
git push origin main

echo "✅ Code pushed successfully!"