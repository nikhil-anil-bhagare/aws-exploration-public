#!/usr/bin/env bash

# Exit script on error
set -e

# Variables
POLICY_FILE="iam/deny_iam_policy.json"
POLICY_NAME="DenyIAMPolicy"
POLICY_DESCRIPTION="Deny IAM actions"
POLICY_TYPE="SERVICE_CONTROL_POLICY"

# Create SCP policy
create_policy() {
  echo "Creating SCP policy..."
  POLICY_ID=$(aws organizations create-policy \
    --content file://$POLICY_FILE \
    --description "$POLICY_DESCRIPTION" \
    --name "$POLICY_NAME" \
    --type "$POLICY_TYPE" \
    --query 'Policy.PolicySummary.Id' \
    --output text)
  echo "Policy created with ID: $POLICY_ID"
}

# Get organization root ID
get_root_id() {
  echo "Fetching organization root ID..."
  ROOT_ID=$(aws organizations list-roots \
    --query 'Roots[0].Id' \
    --output text)
  echo "Root ID: $ROOT_ID"
}

# Enable SCP policy type
enable_policy_type() {
  echo "Enabling policy type $POLICY_TYPE..."
  aws organizations enable-policy-type \
    --root-id $ROOT_ID \
    --policy-type $POLICY_TYPE
  echo "Policy type enabled."
}

# Attach SCP to organization
attach_policy() {
  echo "Attaching policy $POLICY_ID to root $ROOT_ID..."
  aws organizations attach-policy \
    --policy-id $POLICY_ID \
    --target-id $ROOT_ID
  echo "Policy attached successfully."
}

# Test policy restrictions
test_policy() {
  echo "Testing policy restrictions by attempting to create a user..."
  if aws iam create-user --user-name testuser; then
    echo "ERROR: User creation succeeded, policy is not enforced!"
  else
    echo "User creation blocked as expected. SCP is enforced."
  fi
}

# Main script execution
main() {
  create_policy
  get_root_id
  enable_policy_type
  attach_policy
  test_policy
}

main
