#!/bin/bash


dart format lib/


git add .


read -p "Enter commit message: " message
git commit -m "$message"


git push origin "$(git symbolic-ref --short HEAD)"