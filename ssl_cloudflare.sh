#!/bin/bash

## check for sudo/root
if ! [ $(id -u) = 0 ]; then
  echo "This script must run with sudo, try again..."
  exit 1
fi


# Set the path of the secrets file to a variable
secrets_file="$HOME/.secrets/cloudflare.ini"

# Check if the secrets file exists and prompt for overwrite if it does
if [ -f "$secrets_file" ]; then
  read -p "Secrets file $secrets_file exists. Do you want to overwrite the contents of the file? (y/N) " confirm_overwrite
  if [ "${confirm_overwrite,,}" != "y" ]; then
    echo "Skipping overwrite of $secrets_file."
  fi
fi

# Prompt for email and global api key input if file is empty or being overwritten
if [ ! -s "$secrets_file" ] || [ "${confirm_overwrite,,}" == "y" ]; then
  # Get input email and global API key
  read -p "Enter your Cloudflare email: " email
  read -p "Enter your Cloudflare global API key: " api_key

  # Create the secrets directory and file if they don't exist
  mkdir -p "$(dirname "$secrets_file")"
  touch "$secrets_file"

  # Write email and global api key to the secrets file
  echo "dns_cloudflare_email = \"$email\"" > "$secrets_file"
  echo "dns_cloudflare_api_key = \"$api_key\"" >> "$secrets_file"

  # Check if the secrets file has been successfully written
  if [ -s "$secrets_file" ]; then
    echo "Successfully wrote email and global API key to $secrets_file."
  else
    echo "Error: Failed to write to $secrets_file."
    exit 1
  fi
fi


# Check if the secrets file exists before generating SSL
if [ ! -f "$secrets_file" ]; then
  echo "Error: $secrets_file not found"
  exit 1
fi


echo "next skrip to generate SSL"
