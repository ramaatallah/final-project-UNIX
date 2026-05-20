#!/bin/bash

MESSAGE="Auto commit: $(date)"

cd ~/final-project || exit

git add .

git commit -m "$MESSAGE" || echo "no changes to commit"

git pull origin main --rebase

git push origin main

echo "Code pushed successfully!"