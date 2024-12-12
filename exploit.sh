#!/bin/bash

echo -e"Made By Taylor Christian Newsome 12/12/24"

# Function to generate SSL certificate and key
generate_cert() {
    local hostname=$1
    # Generate a new RSA key pair
    openssl genrsa -out "${hostname}.key" 2048
    # Generate a new certificate signing request (CSR)
    openssl req -new -key "${hostname}.key" -out "${hostname}.csr" -subj "/CN=${hostname}"
    # Sign the CSR with a self-signed certificate
    openssl x509 -req -in "${hostname}.csr" -signkey "${hostname}.key" -out "${hostname}.crt" -days 365
}

# Function to start an SSL server using OpenSSL
ssl_server() {
    local hostname=$1
    local port=$2

    # Generate the SSL certificate and key
    generate_cert "$hostname"

    # Start an SSL server using OpenSSL's s_server
    echo "[*] Listening on ${hostname}:${port}"

    # Use the `-tls1_3` flag to specify TLS 1.3
    openssl s_server -accept "$port" -cert "${hostname}.crt" -key "${hostname}.key" -CAfile "${hostname}.crt" -Verify 1 -www -tls1_3
}

# Main function
main() {
    if [ $# -ne 2 ]; then
        echo "Usage: $0 <hostname> <port>"
        exit 1
    fi

    local hostname=$1
    local port=$2

    ssl_server "$hostname" "$port"
}

# Run the main function
main "$@"
