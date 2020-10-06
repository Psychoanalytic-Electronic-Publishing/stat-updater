#!/bin/bash

function SetAwsProfile()
{
	aws configure set aws_access_key_id $AwsAccessKey --profile $SvcName-$AwsStage
	aws configure set aws_secret_access_key $AwsSecretKey --profile $SvcName-$AwsStage
	aws configure set region $AwsRegion --profile $SvcName-$AwsStage
}

function SetServerlessProfile()
{
	sls config credentials --provider aws --key $AwsAccessKey --secret $AwsSecretKey --profile $SvcName-$AwsStage --overwrite
}

function AwsEncrypt () #Parameters: TargetString, KmsKey
{
	echo $(aws kms encrypt --key-id $2 --plaintext "$1" --output text --query CiphertextBlob --profile $SvcName-$AwsStage --region $AwsRegion)
}

"$@"