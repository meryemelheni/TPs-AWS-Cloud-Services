#!/bin/bash

# Lab 03 : Elastic Compute Cloud (EC2)

KEY_NAME="my-key-pair"

echo "--- Création d'une paire de clés ---"
awslocal ec2 create-key-pair --key-name $KEY_NAME --query 'KeyMaterial' --output text > $KEY_NAME.pem
chmod 400 $KEY_NAME.pem

echo "--- Création d'un Security Group (HTTP & SSH) ---"
SG_ID=$(awslocal ec2 create-security-group --group-name my-sg --description "Security group for web server" --query 'GroupId' --output text)

awslocal ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0
awslocal ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0

echo "--- Préparation du script de démarrage (User Data) ---"
cat <<EOF > user-data.sh
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello from EC2 Bootstrapped by User Data</h1>" > /var/www/html/index.html
EOF

echo "--- Lancement d'une instance EC2 ---"
# Note: Dans LocalStack, les AMI IDs sont souvent simulés (ex: ami-df5de72)
INSTANCE_ID=$(awslocal ec2 run-instances \
    --image-id ami-df5de72 \
    --count 1 \
    --instance-type t2.micro \
    --key-name $KEY_NAME \
    --security-group-ids $SG_ID \
    --user-data file://user-data.sh \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "--- Vérification du statut de l'instance ---"
awslocal ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].State.Name'

echo "EC2 Setup Complete! Instance ID: $INSTANCE_ID"
