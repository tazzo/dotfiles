#!/bin/bash
# Script per resettare Nautilus quando si incasina dopo lo standby

echo "Chiusura di Nautilus in corso..."
# Chiusura gentile
nautilus -q 

# Aspettiamo un secondo
sleep 1

# Forza la chiusura se è ancora appeso
killall -9 nautilus 2>/dev/null

echo "Riavvio di Nautilus..."
# Lo lanciamo in background senza bloccare il terminale
nohup nautilus --new-window > /dev/null 2>&1 &

echo "Nautilus resettato con successo!"
