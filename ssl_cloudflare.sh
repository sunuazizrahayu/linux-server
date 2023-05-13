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

# Update Config Permission
chmod 0700 $(dirname "$secrets_file")
chmod 0400 $secrets_file


# Generate SSL
# Prompt user if they want to generate SSL
read -p "Do you want to generate an SSL? (y/N): " ssl

# If user selects yes (y), prompt for SSL domain
if [[ "$ssl" =~ ^[Yy]$ ]]; then
  # Prompt user for SSL domain
  echo "Enter domains (press Enter without typing to finish):"
  
  # Initialize ssl_domain variable
  ssl_domain=""
  
  # Loop to prompt user for SSL domain until they finish
  while read -p "> " line
  do
    # Stop the loop if user does not enter any domain
    if [[ -z "$line" ]]; then
      break
    fi
    
    # Append domain to ssl_domain variable with comma separator
    ssl_domain="$ssl_domain,$line"
  done
  
  # Remove the comma at the beginning of the ssl_domain variable
  ssl_domain=${ssl_domain#","}
  
  # Print user input for SSL domain to screen
  if [[ -z "$ssl_domain" ]]; then
    echo "You did not enter any domains. Please try again."
  else
    echo "Generate SSL for the following domains: $ssl_domain"
    docker run -it --rm --name certbot \
      -v "/etc/letsencrypt:/etc/letsencrypt" \
      -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
      -v "/root/.secrets/cloudflare.ini:/root/.secrets/cloudflare.ini" \
      certbot/dns-cloudflare certonly --dns-cloudflare --dns-cloudflare-credentials /root/.secrets/cloudflare.ini -d $ssl_domain --preferred-challenges dns-01
  fi
else
  # Print message that SSL will not be generated
  echo "You chose not to generate an SSL."
fi
