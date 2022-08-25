#!/bin/bash

aws dynamodb create-table \
    --table-name 'vote-result' \
    --attribute-definitions \
        'AttributeName=PK,AttributeType=S' \
        'AttributeName=SK,AttributeType=S' \
    --key-schema \
        'AttributeName=PK,KeyType=HASH' \
        'AttributeName=SK,KeyType=RANGE' \
    --billing-mode PAY_PER_REQUEST \
    --endpoint http://localhost:8000