#!/bin/bash

docker build -t wonkook-ecr-repo .

docker tag wonkook-ecr-repo $AWS_ACCOUNT_ID.dkr.ecr.ap-northeast-2.amazonaws.com/wonkook-ecr-repo:$1
docker push $AWS_ACCOUNT_ID.dkr.ecr.ap-northeast-2.amazonaws.com/wonkook-ecr-repo:$1

docker tag wonkook-ecr-repo $AWS_ACCOUNT_ID.dkr.ecr.ap-northeast-2.amazonaws.com/wonkook-ecr-repo:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.ap-northeast-2.amazonaws.com/wonkook-ecr-repo:latest
