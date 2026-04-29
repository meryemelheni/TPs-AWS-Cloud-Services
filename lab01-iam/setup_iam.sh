#!/bin/bash

# Lab 01 : Identity and Access Management (IAM)

echo "--- Création d'un groupe d'administrateurs ---"
awslocal iam create-group --group-name Admins

echo "--- Création d'un utilisateur 'dev-user' ---"
awslocal iam create-user --user-name dev-user

echo "--- Ajout de 'dev-user' au groupe 'Admins' ---"
awslocal iam add-user-to-group --user-name dev-user --group-name Admins

echo "--- Création d'une politique personnalisée (S3 Read-Only) ---"
cat <<EOF > s3-readonly-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": "*"
        }
    ]
}
EOF

awslocal iam create-policy --policy-name S3ReadOnlyAccess --policy-document file://s3-readonly-policy.json

echo "--- Création d'un rôle de service pour EC2 ---"
cat <<EOF > trust-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

awslocal iam create-role --role-name EC2ServiceRole --assume-role-policy-document file://trust-policy.json

echo "--- Attachement de la politique au rôle ---"
awslocal iam attach-role-policy --role-name EC2ServiceRole --policy-arn arn:aws:iam::000000000000:policy/S3ReadOnlyAccess

echo "--- Nettoyage des fichiers temporaires ---"
rm s3-readonly-policy.json trust-policy.json

echo "IAM Setup Complete!"
