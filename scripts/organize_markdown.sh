#!/bin/bash

# Cicla su tutti i file .md nella cartella corrente
for file in *.md; do
    # Verifica che sia un file esistente per evitare errori se non ci sono match
    if [[ -f "$file" ]]; then
        # Estrae il nome del file senza l'estensione .md
        dir_name="${file%.md}"
        
        # Crea la cartella (mkdir -p evita errori se esiste già)
        mkdir -p "$dir_name"
        
        # Sposta il file nella nuova cartella
        mv "$file" "$dir_name/"
        echo "Spostato '$file' in '$dir_name/'"
    fi
done
