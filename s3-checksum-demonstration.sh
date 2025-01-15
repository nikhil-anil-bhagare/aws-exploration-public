#!/usr/bin/env bash

# Script to demonstrate S3 bucket creation, checksum generation, file upload, metadata verification, and cleanup.

# Step 1: Create an S3 bucket
aws s3api create-bucket \
    --bucket nikhil-bhagare-85-bucket \
    --region us-east-1
echo "S3 bucket 'nikhil-bhagare-85-bucket' created successfully."

# Step 2: Create a file named 'checksum.txt'
echo "This is the content of the checksum file." > checksum.txt
echo "File 'checksum.txt' created with sample content."

# Step 3: Generate a checksum for the file (SHA-256) and encode it in Base64
CHECKSUM=$(openssl dgst -sha256 -binary checksum.txt | base64)
echo "Checksum generated: $CHECKSUM"

# Step 4: Upload the file to the S3 bucket with the pre-calculated checksum
aws s3api put-object \
    --bucket nikhil-bhagare-85-bucket \
    --key checksum.txt \
    --body checksum.txt \
    --checksum-sha256 "$CHECKSUM"
echo "File 'checksum.txt' uploaded to S3 bucket with checksum."

# Step 5: Retrieve the object's metadata and verify the checksum
aws s3api get-object-attributes \
    --bucket nikhil-bhagare-85-bucket \
    --key checksum.txt \
    --object-attributes Checksum
echo "Retrieved metadata for 'checksum.txt' to verify checksum."

# Step 6: Delete the S3 object
aws s3api delete-object \
    --bucket nikhil-bhagare-85-bucket \
    --key checksum.txt
echo "File 'checksum.txt' deleted from S3 bucket."

# Step 7: Delete the S3 bucket
aws s3api delete-bucket \
    --bucket nikhil-bhagare-85-bucket \
    --region us-east-1
echo "S3 bucket 'nikhil-bhagare-85-bucket' deleted successfully."
