#!/bin/bash

# Lab 04 : Messaging (SQS & SNS)

echo "--- Création d'un sujet SNS ---"
TOPIC_ARN=$(awslocal sns create-topic --name my-topic --query 'TopicArn' --output text)

echo "--- Création d'une file SQS Standard ---"
QUEUE_URL=$(awslocal sqs create-queue --queue-name my-standard-queue --query 'QueueUrl' --output text)
QUEUE_ARN=$(awslocal sqs get-queue-attributes --queue-url $QUEUE_URL --attribute-names QueueArn --query 'Attributes.QueueArn' --output text)

echo "--- Création d'une file SQS FIFO ---"
FIFO_QUEUE_URL=$(awslocal sqs create-queue --queue-name my-fifo-queue.fifo --attributes FifoQueue=true,ContentBasedDeduplication=true --query 'QueueUrl' --output text)

echo "--- Abonnement de la file SQS au sujet SNS (Pattern Fan-out) ---"
awslocal sns subscribe \
    --topic-arn $TOPIC_ARN \
    --protocol sqs \
    --notification-endpoint $QUEUE_ARN

echo "--- Configuration d'une politique de filtrage (Optionnel) ---"
awslocal sns set-subscription-attributes \
    --subscription-arn $(awslocal sns list-subscriptions-by-topic --topic-arn $TOPIC_ARN --query 'Subscriptions[0].SubscriptionArn' --output text) \
    --attribute-name FilterPolicy \
    --attribute-value '{"event_type": ["order_placed"]}'

echo "--- Test : Publication d'un message sur SNS ---"
awslocal sns publish --topic-arn $TOPIC_ARN --message "Bonjour depuis SNS!"

echo "--- Test : Réception du message depuis SQS ---"
awslocal sqs receive-message --queue-url $QUEUE_URL

echo "Messaging Setup Complete!"
