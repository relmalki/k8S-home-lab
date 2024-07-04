#!/bin/bash

# Install cfssl and cfssljson if not already installed
if ! command -v cfssl &> /dev/null || ! command -v cfssljson &> /dev/null; then
  echo "Installing cfssl and cfssljson..."
  wget -q --show-progress --https-only --timestamping \
    https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 \
    https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64

  chmod +x cfssl_linux-amd64 cfssljson_linux-amd64
  sudo mv cfssl_linux-amd64 /usr/local/bin/cfssl
  sudo mv cfssljson_linux-amd64 /usr/local/bin/cfssljson
fi

# Create CA configuration file
cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

# Create CA CSR file
cat > ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 4096
  },
  "names": [
    {
      "C": "US",
      "L": "Seattle",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Washington"
    }
  ]
}
EOF

# Generate CA certificate and key
cfssl gencert -initca ca-csr.json | cfssljson -bare ca

# Function to create CSR JSON file
generate_csr_json() {
  local cn=$1
  local filename=$2
  local hosts=$3
  local organization=$4

  cat > ${filename}-csr.json <<EOF
{
  "CN": "${cn}",
  "key": {
    "algo": "rsa",
    "size": 4096
  },
  "names": [
    {
      "C": "US",
      "L": "Seattle",
      "O": "${organization}",
      "OU": "Kubernetes",
      "ST": "Washington"
    }
  ],
  "hosts": [${hosts}]
}
EOF
}

# Generate CSR JSON files for each component
generate_csr_json "admin" "admin" "" "system:masters"
generate_csr_json "kube-apiserver" "kube-apiserver" "\"127.0.0.1\", \"192.168.50.11\", \"server.kubernetes.local\", \"kubernetes\", \"kubernetes.default\", \"kubernetes.default.svc\", \"kubernetes.default.svc.cluster\", \"kubernetes.svc.cluster.local\"" "Kubernetes"
generate_csr_json "system:kube-controller-manager" "kube-controller-manager" "" "system:kube-controller-manager"
generate_csr_json "system:kube-scheduler" "kube-scheduler" "" "system:kube-scheduler"
generate_csr_json "system:node:node-0" "node-0" "\"192.168.50.12\", \"node-0.kubernetes.local\"" "system:nodes"
generate_csr_json "system:node:node-1" "node-1" "\"192.168.50.13\", \"node-1.kubernetes.local\"" "system:nodes"
generate_csr_json "system:kube-proxy" "kube-proxy" "" "system:node-proxier"
generate_csr_json "service-accounts" "service-accounts" "" "Kubernetes"

# Function to generate certificate using cfssl
generate_certificate() {
  local name=$1
  cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes ${name}-csr.json | cfssljson -bare ${name}
}

# Generate certificates for each component
generate_certificate "admin"
generate_certificate "kube-apiserver"
generate_certificate "kube-controller-manager"
generate_certificate "kube-scheduler"
generate_certificate "node-0"
generate_certificate "node-1"
generate_certificate "kube-proxy"
generate_certificate "service-accounts"

echo "Certificates generated successfully."

# Distribute the certificates to nodes
for host in node-0 node-1; do
  ssh root@$host mkdir -p /var/lib/kubelet/
  
  scp ca.pem root@$host:/var/lib/kubelet/
    
  scp ${host}.pem \
    root@$host:/var/lib/kubelet/kubelet.pem
    
  scp ${host}-key.pem \
    root@$host:/var/lib/kubelet/kubelet-key.pem
done


echo "Certificates and kubeconfig files distributed successfully."
