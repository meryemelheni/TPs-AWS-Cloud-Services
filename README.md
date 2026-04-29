# Compte Rendu des TPs AWS Cloud Services

Ce dépôt contient l'ensemble des travaux pratiques (Labs) réalisés dans le cadre du cours AWS Cloud Services. L'objectif est de maîtriser les services fondamentaux d'AWS en utilisant **LocalStack** pour l'émulation locale.

---

## 🛠️ Pré-requis & Installation

Avant de commencer, assurez-vous d'avoir installé les outils suivants :

```bash
# Installation de l'AWS CLI (nécessaire pour awslocal)
pip install awscli

# Installation de LocalStack et de l'utilitaire awslocal
pip install localstack awscli-local

# Lancement de LocalStack via Docker (Recommandé pour éviter les erreurs de licence)
docker run -d -p 4566:4566 -p 4510-4559:4510-4559 --name localstack_main localstack/localstack:2.3.2
```

---

## 🚀 Comment exécuter les TPs

Chaque Lab dispose de scripts automatisés pour la mise en œuvre. Choisissez la version selon votre système :

### Sur Windows (PowerShell)
```powershell
# Lab 01 : IAM
cd lab01-iam; .\setup_iam.ps1

# Lab 02 : S3
cd ..\lab02-s3; .\setup_s3.ps1

# Lab 03 : EC2
cd ..\lab03-ec2; .\setup_ec2.ps1

# Lab 04 : Messaging
cd ..\lab04-messaging; .\setup_messaging.ps1
```

### Sur Linux / macOS / Git Bash
```bash
# Lab 01 : IAM
cd lab01-iam; sh setup_iam.sh

# Lab 02 : S3
cd ../lab02-s3; sh setup_s3.sh

# Lab 03 : EC2
cd ../lab03-ec2; sh setup_ec2.sh

# Lab 04 : Messaging
cd ../lab04-messaging; sh setup_messaging.sh
```

---

## 🧪 Lab 00 : Configuration de l'environnement

**Objectif :** Découvrir que l'ensemble de la surface API AWS peut être émulé localement.

### Commandes de vérification
```bash
# Vérifier si LocalStack est bien lancé
localstack status services

# Tester la communication avec awslocal
awslocal sts get-caller-identity
```

---

## 👤 Lab 01 : Identity and Access Management (IAM)

**Objectif :** Mettre en œuvre le principe du moindre privilège, créer des utilisateurs, des groupes et des rôles de service.

### Commandes de vérification
```bash
# Vérifier la création de l'utilisateur
awslocal iam list-users

# Vérifier les groupes
awslocal iam list-groups

# Vérifier le rôle de service EC2
awslocal iam list-roles --query "Roles[?RoleName=='EC2ServiceRole']"
```

---

## 📦 Lab 02 : Simple Storage Service (S3)

**Objectif :** Gérer des buckets, le versioning, les politiques de bucket et l'hébergement de sites statiques.

### Commandes de vérification
```bash
# Lister les buckets existants
awslocal s3 ls

# Vérifier si le versioning est activé (remplacer par le nom de votre bucket)
awslocal s3api get-bucket-versioning --bucket mon-bucket-de-test-XXXXXXXXXX
```

---

## 💻 Lab 03 : Elastic Compute Cloud (EC2)

**Objectif :** Lancer des instances de calcul avec des paires de clés, des groupes de sécurité et des scripts User Data.

### Commandes de vérification
```bash
# Vérifier l'état de l'instance EC2
awslocal ec2 describe-instances --query "Reservations[*].Instances[*].{ID:InstanceId,State:State.Name}"

# Vérifier le Security Group
awslocal ec2 describe-security-groups --group-names my-sg
```

---

## ✉️ Lab 04 : Messaging (SQS & SNS)

**Objectif :** Construire un pipeline de messagerie asynchrone utilisant le pattern Fan-out.

### Commandes de vérification
```bash
# Vérifier les files SQS
awslocal sqs list-queues

# Vérifier le sujet SNS
awslocal sns list-topics

# Vérifier les abonnements
awslocal sns list-subscriptions
```

---

## 🏗️ Lab 05 : Infrastructure as Code (IaC)

**Objectif :** Automatiser le déploiement de l'ensemble de l'infrastructure via **Terraform** ou **CloudFormation**.

Le dossier `lab05-iac` contient deux approches :
1. **Terraform** (`main.tf`)
2. **CloudFormation** (`template.yaml`)

### Commandes de vérification (CloudFormation)
```bash
# Déployer le stack CloudFormation
awslocal cloudformation create-stack --stack-name my-stack --template-body file://lab05-iac/template.yaml

# Vérifier le statut du stack
awslocal cloudformation describe-stacks --stack-name my-stack
```

---

## 🚀 Conclusion

Ce projet démontre la capacité à déployer une architecture cloud complète de manière reproductible et sécurisée. Les principes de couplage faible et de moindre privilège ont été appliqués tout au long des Labs.

---
**Auteur :** meryemelheni  
**Lien GitHub :** [https://github.com/meryemelheni/TPs-AWS-Cloud-Services.git](https://github.com/meryemelheni/TPs-AWS-Cloud-Services.git)
