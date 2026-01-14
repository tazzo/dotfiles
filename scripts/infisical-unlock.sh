#!/bin/bash

# infisical-unlock.sh
# Script per autenticazione e setup ambiente TazLab

echo "🔐 == TazLab Zero-Trust Login =="
echo "Avvio procedura di login su Infisical EU..."

# 1. Login Interattivo
infisical login --domain https://eu.infisical.com/api

# 2. Esecuzione Setup (Scarica le chiavi in RAM)
# Cerchiamo lo script nel path standard di DevPod
SETUP_SCRIPT="$HOME/workspaces/tazlab-k8s/.devcontainer/setup-runtime.sh"

# Fallback se siamo nella cartella corrente
if [ ! -f "$SETUP_SCRIPT" ] && [ -f ".devcontainer/setup-runtime.sh" ]; then
    SETUP_SCRIPT=".devcontainer/setup-runtime.sh"
fi

if [ -f "$SETUP_SCRIPT" ]; then
    echo "🚀 Login effettuato. Scarico i segreti in RAM..."
    bash "$SETUP_SCRIPT"
    
    echo ""
    echo "✅ == PRONTO =="
    echo "I segreti sono in /tmp. Per attivarli in questa shell, digita:"
    echo "  source ~/.cluster-secrets"
    echo ""
else
    echo "❌ Errore: Non trovo lo script di setup ($SETUP_SCRIPT)"
    echo "Assicurati di essere nel workspace tazlab-k8s o che il path sia corretto."
    exit 1
fi
