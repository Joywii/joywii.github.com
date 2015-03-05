#!/bin/bash

cd _deploy
# 添加 gitcafe 源
git remote add gitcafe git@gitcafe.com:joywii/joywii.git >> /dev/null 2>&1
# 提交博客内容
echo "### Pushing to GitCafe..."
git push -u -f gitcafe master:gitcafe-pages
echo "### Done"%
