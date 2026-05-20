#!/bin/bash

MESSAGE="Auto commit: $(date)"

cd "/c/Users/USER-Q/Desktop/يونكس راوند 2/final-project-UNIX" || exit

git add .

git commit -m "$MESSAGE" || echo "no changes to commit"

git pull origin new_branch --rebase

git push origin new_branch

echo "Code pushed successfully!"