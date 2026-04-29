#!/bin/bash

# Lab 02 : Simple Storage Service (S3)

BUCKET_NAME="mon-bucket-de-test-$(date +%s)"

echo "--- Création d'un bucket S3 : $BUCKET_NAME ---"
awslocal s3 mb s3://$BUCKET_NAME

echo "--- Activation du versioning ---"
awslocal s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled

echo "--- Configuration d'une politique de cycle de vie (Expiration après 30 jours) ---"
cat <<EOF > lifecycle.json
{
    "Rules": [
        {
            "ID": "ExpireOldVersions",
            "Status": "Enabled",
            "Prefix": "",
            "Expiration": {
                "Days": 30
            }
        }
    ]
}
EOF
awslocal s3api put-bucket-lifecycle-configuration --bucket $BUCKET_NAME --lifecycle-configuration file://lifecycle.json

echo "--- Configuration pour l'hébergement d'un site web statique ---"
echo "<h1>Bienvenue sur mon site S3</h1>" > index.html
echo "<h1>Oups, erreur 404</h1>" > error.html

awslocal s3 cp index.html s3://$BUCKET_NAME/index.html
awslocal s3 cp error.html s3://$BUCKET_NAME/error.html

awslocal s3api put-bucket-website --bucket $BUCKET_NAME --website-configuration '{
    "IndexDocument": {"Suffix": "index.html"},
    "ErrorDocument": {"Key": "error.html"}
}'

echo "--- Configuration d'une politique de bucket (Accès public en lecture) ---"
cat <<EOF > bucket-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicRead",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
        }
    ]
}
EOF
awslocal s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://bucket-policy.json

echo "--- Nettoyage des fichiers temporaires ---"
rm lifecycle.json bucket-policy.json index.html error.html

echo "S3 Setup Complete! Bucket: $BUCKET_NAME"
