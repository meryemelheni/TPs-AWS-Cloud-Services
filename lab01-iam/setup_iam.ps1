# Lab 01 : Identity and Access Management (IAM)

Write-Host "--- Création d'un groupe d'administrateurs ---"
awslocal iam create-group --group-name Admins

Write-Host "--- Création d'un utilisateur 'dev-user' ---"
awslocal iam create-user --user-name dev-user

Write-Host "--- Ajout de 'dev-user' au groupe 'Admins' ---"
awslocal iam add-user-to-group --user-name dev-user --group-name Admins

Write-Host "--- Création d'une politique personnalisée (S3 Read-Only) ---"
$s3Policy = @{
    Version = "2012-10-17"
    Statement = @(
        @{
            Effect = "Allow"
            Action = @("s3:Get*", "s3:List*")
            Resource = "*"
        }
    )
} | ConvertTo-Json -Depth 10
$s3Policy | Out-File -FilePath "s3-readonly-policy.json" -Encoding utf8

awslocal iam create-policy --policy-name S3ReadOnlyAccess --policy-document file://s3-readonly-policy.json

Write-Host "--- Création d'un rôle de service pour EC2 ---"
$trustPolicy = @{
    Version = "2012-10-17"
    Statement = @(
        @{
            Effect = "Allow"
            Principal = @{ Service = "ec2.amazonaws.com" }
            Action = "sts:AssumeRole"
        }
    )
} | ConvertTo-Json -Depth 10
$trustPolicy | Out-File -FilePath "trust-policy.json" -Encoding utf8

awslocal iam create-role --role-name EC2ServiceRole --assume-role-policy-document file://trust-policy.json

Write-Host "--- Attachement de la politique au rôle ---"
awslocal iam attach-role-policy --role-name EC2ServiceRole --policy-arn arn:aws:iam::000000000000:policy/S3ReadOnlyAccess

Write-Host "--- Nettoyage des fichiers temporaires ---"
Remove-Item s3-readonly-policy.json, trust-policy.json

Write-Host "IAM Setup Complete!"
