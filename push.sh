#!/bin/bash

echo "upload the code"

cd ~/final-project

git add .
git commit -m "Auto update: $(date)"
git push origin main

echo " uploading successfully"