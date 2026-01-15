#!/bin/bash

# infisical-unlock.sh
# Script per autenticazione e sblocco segreti TazLab

echo "🔐 == TazLab Zero-Trust Unlock =="

# 1. Login (Sempre eseguito per garantire token fresco)
echo "🔑 Avvio login Infisical EU..."
infisical login --domain https://eu.infisical.com/api

# 2. Recupero Segreti
echo "🚀 Recupero segreti da Infisical Cloud (Env: dev)..."
TMP_AGE=$(infisical secrets get SOPS_AGE_KEY --env dev --plain --silent 2>/dev/null)
TMP_KUBE=$(infisical secrets get KUBECONFIG_CONTENT --env dev --plain --silent 2>/dev/null)
TMP_TALOS=$(infisical secrets get TALOSCONFIG_CONTENT --env dev --plain --silent 2>/dev/null)

if [[ $TMP_AGE == AGE-SECRET-KEY-* ]]; then
    echo "$TMP_AGE" > /tmp/age.key
    echo "$TMP_KUBE" > /tmp/kubeconfig
    echo "$TMP_TALOS" > /tmp/talosconfig
    chmod 600 /tmp/age.key /tmp/kubeconfig /tmp/talosconfig
    
    # Generiamo il file delle variabili
    cat << EOF > "$HOME/.tazlab-env"
# --- TAZLAB CLUSTER SECRETS ---
export SOPS_AGE_KEY_FILE="/tmp/age.key"
export KUBECONFIG="/tmp/kubeconfig"
export TALOSCONFIG="/tmp/talosconfig"
EOF
    chmod 600 "$HOME/.tazlab-env"
    
    echo "✅ Segreti scaricati in RAM."
    echo "🔗 Per attivare: source ~/.tazlab-env (o usa l'alias 'unlock')"
    source "$HOME/.tazlab-env"
else
    echo "❌ Errore: Recupero fallito. Verifica il login."
    exit 1
fi
