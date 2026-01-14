#!/bin/bash

# infisical-unlock.sh
# Script helper per sbloccare l'ambiente TazLab

echo "🔐 == TazLab Zero-Trust Unlock =="

# 1. Login (se necessario)
if ! infisical user get > /dev/null 2>&1; then
    echo "🔑 Avvio login Infisical EU..."
    infisical login --domain https://eu.infisical.com/api
else
    echo "✅ Già loggato."
fi

# 2. Esecuzione Setup (che ora scaricherà i segreti perché siamo loggati)
SETUP_SCRIPT="$HOME/workspaces/tazlab-k8s/.devcontainer/setup-runtime.sh"

# Fallback path
if [ ! -f "$SETUP_SCRIPT" ] && [ -f ".devcontainer/setup-runtime.sh" ]; then
    SETUP_SCRIPT=".devcontainer/setup-runtime.sh"
fi

if [ -f "$SETUP_SCRIPT" ]; then
    bash "$SETUP_SCRIPT"
    
    echo ""
    echo "🎉 == PRONTO =="
    echo "Digita questo per attivare la shell corrente:"
    echo "  source ~/.cluster-secrets"
    echo ""
else
    echo "❌ Errore: Script di setup non trovato."
    exit 1
fi
