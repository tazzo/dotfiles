import os
import json
from datetime import datetime
from typing import List, Dict, Any, Optional, Union

# --- Configurazione ---
# Directory in cui cercare i file JSON.
# Lo script userà la directory corrente (dove viene lanciato).
# Per processare i file in `~/tmp/chats/`, naviga in quella directory prima di lanciare lo script.
# Oppure, puoi modificare questa variabile per puntare a un percorso specifico:
# JSON_DIRECTORY = os.path.expanduser("~/tmp/chats/") # Esempio per percorso fisso
JSON_DIRECTORY = "." # Processa nella directory corrente di esecuzione

# Massimo numero di messaggi per file Markdown di output
MAX_MESSAGES_PER_FILE = 1000 

# --- Funzione Helper per Formattare il Timestamp ---
def format_timestamp_for_filename(timestamp_str: str) -> str:
    """
    Analizza una stringa timestamp in formato ISO 8601 e la formatta per il nome di un file,
    sostituendo ':' con '-' e rimuovendo millisecondi/timezone.
    Esempio: '2025-12-14T16:42:15.102Z' -> '2025-12-14T16-42-15'
    """
    try:
        if timestamp_str.endswith('Z'):
            timestamp_str = timestamp_str[:-1] + '+00:00'
        
        dt_object = datetime.fromisoformat(timestamp_str)
        return dt_object.strftime('%Y-%m-%dT%H-%M-%S')
    except ValueError as e:
        print(f"Errore nella formattazione del timestamp '{timestamp_str}': {e}")
        return "invalid-timestamp"

# --- Funzione Principale di Elaborazione ---
def process_json_files_to_markdown():
    current_working_directory = os.getcwd()

    target_directory = JSON_DIRECTORY if JSON_DIRECTORY != "." else current_working_directory
    
    print(f"Cercando file JSON nella directory: '{target_directory}'")

    json_files = [f for f in os.listdir(target_directory) if f.endswith(".json")]

    if not json_files:
        print(f"Nessun file JSON trovato nella directory: '{target_directory}'.")
        return

    print(f"Trovati {len(json_files)} file JSON da processare.")

    for json_filename in json_files:
        file_path = os.path.join(target_directory, json_filename)
        print(f"\n--- Processo il file: {json_filename} ---")

        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
        except FileNotFoundError:
            print(f"Errore: File non trovato a {file_path}")
            continue
        except json.JSONDecodeError:
            print(f"Errore: Impossibile decodificare JSON da {file_path}. Salto il file.")
            continue
        except Exception as e:
            print(f"Un errore inatteso si è verificato durante la lettura di {file_path}: {e}. Salto il file.")
            continue

        # Valida le chiavi richieste e la struttura principale
        if 'messages' not in data or not isinstance(data['messages'], list):
            print(f"Salto {json_filename}: la chiave 'messages' non è presente o non è una lista.")
            continue

        all_messages = data['messages']
        if not all_messages:
            print(f"Salto {json_filename}: la lista 'messages' è vuota.")
            continue

        # Ottieni e formatta il timestamp dal primo messaggio per il nome del file di output
        first_message_timestamp_str = None
        if isinstance(all_messages[0], dict) and 'timestamp' in all_messages[0]:
            first_message_timestamp_str = all_messages[0]['timestamp']
        else:
            print(f"Attenzione: Il primo messaggio in {json_filename} non è un dizionario o manca del campo 'timestamp'. Uso l'ora corrente per il nome del file.")
            first_message_timestamp_str = datetime.utcnow().isoformat() + "Z" # Fallback

        formatted_timestamp_for_file_base = format_timestamp_for_filename(first_message_timestamp_str)
        if formatted_timestamp_for_file_base == "invalid-timestamp":
            print(f"Salto {json_filename} a causa del formato timestamp non valido per il nome file.")
            continue

        # --- Splitting logic and Markdown generation ---
        num_messages = len(all_messages)
        num_chunks = (num_messages + MAX_MESSAGES_PER_FILE - 1) // MAX_MESSAGES_PER_FILE # Ceil division

        print(f"  Trovati {num_messages} messaggi. Verranno generati {num_chunks} file Markdown.")

        for i in range(num_chunks):
            start_index = i * MAX_MESSAGES_PER_FILE
            end_index = start_index + MAX_MESSAGES_PER_FILE
            message_chunk = all_messages[start_index:end_index]

            markdown_output = f"# Resoconto Conversazione - {formatted_timestamp_for_file_base.replace('T', ' ')} (Parte {i+1} di {num_chunks})\n\n---\n\n"
            
            for msg in message_chunk:
                timestamp_raw = msg.get('timestamp', 'timestamp sconosciuto')
                display_timestamp = timestamp_raw 

                msg_type = msg.get('type', 'unknown')
                content = msg.get('content', '')
                
                if isinstance(content, str):
                    content = content.strip()

                markdown_output += f"### **`[{display_timestamp}]` - {msg_type.capitalize()}**\n"

                if content:
                    if "\n" in content:
                        markdown_output += f"> {content.replace('\n', '\n> ')}\n"
                    else:
                        markdown_output += f"{content}\n"

                if msg_type == 'gemini':
                    
                    tool_calls = msg.get('toolCalls')
                    if tool_calls:
                        for tc in tool_calls:
                            markdown_output += f"\n#### Tool Call\n"
                            markdown_output += f"**ID:** `{tc.get('id', 'N/A')}`\n"
                            markdown_output += f"**Name:** `{tc.get('name', 'N/A')}`\n"
                            markdown_output += f"**Status:** `{tc.get('status', 'N/A')}`\n"
                            markdown_output += f"**Timestamp:** `{tc.get('timestamp', 'N/A')}`\n"
                            
                            tc_description = tc.get('description', 'N/A')
                            if tc_description:
                                markdown_output += f"**Description:**\n> {tc_description.replace('\n', '\n> ')}\n"
                            
                            args = tc.get('args')
                            if args:
                                markdown_output += f"**Arguments:**\n```json\n{json.dumps(args, indent=2, ensure_ascii=False)}\n```\n"
                            
                            result = tc.get('result')
                            if result and isinstance(result, list) and result:
                                markdown_output += f"**Tool Result:**\n"
                                if tc.get('name') == 'run_shell_command' and isinstance(result[0], dict) and 'functionResponse' in result[0]:
                                    response_data = result[0]['functionResponse'].get('response', {})
                                    stdout = response_data.get('output', '(empty)')
                                    stderr = response_data.get('error', '(none)')
                                    error_msg = response_data.get('error', '(none)')
                                    exit_code = response_data.get('exit_code', '(none)')
                                    command_executed = response_data.get('command', '(N/A)')
                                    directory = response_data.get('directory', '(N/A)')

                                    markdown_output += f"  Command: `{command_executed}`\n"
                                    markdown_output += f"  Directory: `{directory}`\n"
                                    markdown_output += f"  Stdout:\n```text\n{stdout}\n```\n"
                                    markdown_output += f"  Stderr:\n```text\n{stderr}\n```\n"
                                    markdown_output += f"  Error: `{error_msg}`\n"
                                    markdown_output += f"  Exit Code: `{exit_code}`\n"
                                    markdown_output += f"  Signal: `{response_data.get('signal', '(none)')}`\n"
                                else:
                                    markdown_output += f"```json\n{json.dumps(result, indent=2, ensure_ascii=False)}\n```\n"
                        
                    markdown_output += "\n" # Ensure some space after gemini content


            markdown_output += "---\n\n" # Separator between messages


            # --- Scrivi il contenuto Markdown nel nuovo file ---
            output_markdown_filename = f"chat_{formatted_timestamp_for_file_base}-{i}.md" if num_chunks > 1 else f"chat_{formatted_timestamp_for_file_base}.md"
            output_markdown_file_path = os.path.join(target_directory, output_markdown_filename)

            try:
                with open(output_markdown_file_path, 'w', encoding='utf-8') as f:
                    f.write(markdown_output)
                print(f"  -> Creato con successo: {output_markdown_filename} (Parte {i+1} di {num_chunks}, {len(message_chunk)} messaggi)")
            except Exception as e:
                print(f"  Errore durante la scrittura del file Markdown {output_markdown_file_path}: {e}")


# --- Esecuzione ---
if __name__ == "__main__":
    process_json_files_to_markdown()
