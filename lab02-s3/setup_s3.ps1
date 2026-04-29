# Lab 02 : Simple Storage Service (S3)

$timestamp = Get-Date -UFormat "%s"
$BUCKET_NAME = "mon-bucket-de-test-$timestamp"

Write-Host "--- Création d'un bucket S3 : $BUCKET_NAME ---"
awslocal s3 mb s3://$BUCKET_NAME

Write-Host "--- Activation du versioning ---"
awslocal s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled

Write-Host "--- Configuration d'une politique de cycle de vie (Expiration après 30 jours) ---"
$lifecycle = @{
    Rules = @(
        @{
            ID = "ExpireOldVersions"
            Status = "Enabled"
            Prefix = ""
            Expiration = @{ Days = 30 }
        }
    )
} | ConvertTo-Json -Depth 10
$lifecycle | Out-File -FilePath "lifecycle.json" -Encoding utf8
awslocal s3api put-bucket-lifecycle-configuration --bucket $BUCKET_NAME --lifecycle-configuration file://lifecycle.json

Write-Host "--- Configuration pour l'hébergement d'un site web statique ---"
"<h1>Bienvenue sur mon site S3</h1>" | Out-File -FilePath index.html -Encoding utf8
"<h1>Oups, erreur 404</h1>" | Out-File -FilePath error.html -Encoding utf8

awslocal s3 cp index.html s3://$BUCKET_NAME/index.html
awslocal s3 cp error.html s3://$BUCKET_NAME/error.html

$websiteConfig = @{
    IndexDocument = @{ Suffix = "index.html" }
    ErrorDocument = @{ Key = "error.html" }
} | ConvertTo-Json -Depth 10
awslocal s3api put-bucket-website --bucket $BUCKET_NAME --website-configuration $websiteConfig

Write-Host "--- Configuration d'une politique de bucket (Accès public en lecture) ---"
$bucketPolicy = @{
    Version = "2012-10-17"
    Statement = @(
        @{
            Sid = "PublicRead"
            Effect = "Allow"
            Principal = "*"
            Action = "s3:GetObject"
            Resource = "arn:aws:s3:::$BUCKET_NAME/*"
        }
    )
} | ConvertTo-Json -Depth 10
$bucketPolicy | Out-File -FilePath "bucket-policy.json" -Encoding utf8
awslocal s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://bucket-policy.json

Write-Host "--- Nettoyage des fichiers temporaires ---"
Remove-Item lifecycle.json, bucket-policy.json, index.html, error.html

Write-Host "S3 Setup Complete! Bucket: $BUCKET_NAME"
