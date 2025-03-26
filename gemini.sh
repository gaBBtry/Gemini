#!/bin/bash

# Script to use the Google Gemini API
# Usage: gemini [options]

# Define available models
AVAILABLE_MODELS=(
  "gemini-1.5-pro"
  "gemini-1.5-flash"
  "gemini-2.5-pro-exp-03-25"
  "gemini-pro"
  "gemini-pro-vision"
)
DEFAULT_MODEL="gemini-2.5-pro-exp-03-25"

# Function to list available models
list_models() {
  echo "Available models:"
  for model in "${AVAILABLE_MODELS[@]}"; do
    if [ "$model" = "$DEFAULT_MODEL" ]; then
      echo "  $model (default)"
    else
      echo "  $model"
    fi
  done
}

# Function to display help
show_help() {
  cat << EOF
Usage: gemini [options]

Options:
  -h, --help              Display this help message
  -m, --model MODEL       Specify the Gemini model to use
  -l, --list-models       List all available models
  -e, --editor EDITOR     Specify the text editor to use
  -v, --verbose           Display detailed status messages

Description:
  Gemini is a command line tool that facilitates interaction with the Google Gemini API.
  It opens a text editor where you can write a prompt,
  then sends this prompt to the Gemini API and displays the response in the same editor.

Environment variables:
  GOOGLE_API_KEY (required)  Your Google API key to access Gemini
  EDITOR (optional)          The text editor to use (default: nano) if -e is not specified

Example:
  gemini                     Launches the interface with the default editor and model
  gemini -e vim              Launches the interface with vim as the editor
  gemini -m gemini-1.5-pro   Uses the gemini-1.5-pro model
  gemini -v                  Displays detailed status messages during execution
EOF
  exit 0
}

# Initialize model to default
MODEL="$DEFAULT_MODEL"
# Initialize editor to null, will use EDITOR env var or default if not specified
EDITOR_CMD=""
# Initialize verbose mode (off by default)
VERBOSE=false

# Function for verbose logging
log() {
  if [ "$VERBOSE" = true ]; then
    echo "$1"
  fi
}

# Process options
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_help
      ;;
    -m|--model)
      if [ -z "$2" ]; then
        echo "Error: No model specified"
        echo ""
        show_help
      fi
      
      # Check if the specified model is valid
      VALID_MODEL=false
      for m in "${AVAILABLE_MODELS[@]}"; do
        if [ "$2" = "$m" ]; then
          VALID_MODEL=true
          break
        fi
      done
      
      if [ "$VALID_MODEL" = false ]; then
        echo "Error: Invalid model '$2'"
        list_models
        exit 1
      fi
      
      MODEL="$2"
      shift 2
      ;;
    -e|--editor)
      if [ -z "$2" ]; then
        echo "Error: No editor specified"
        echo ""
        show_help
      fi
      EDITOR_CMD="$2"
      shift 2
      ;;
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
    -l|--list-models)
      list_models
      exit 0
      ;;
    *)
      echo "Error: Unrecognized option '$1'"
      echo ""
      show_help
      ;;
  esac
done

# Check if API key is configured
if [ -z "$GOOGLE_API_KEY" ]; then
  echo "Error: Please set the GOOGLE_API_KEY environment variable"
  echo "Run: export GOOGLE_API_KEY='your-api-key'"
  exit 1
fi

# Display selected model
log "✓ Using model: $MODEL"

# Create a temporary file
TEMP_FILE=$(mktemp /tmp/gemini_prompt.XXXXXX)
log "✓ Creating temporary file: $TEMP_FILE"

# Determine which editor to use
if [ -z "$EDITOR_CMD" ]; then
  EDITOR=${EDITOR:-nano}
else
  EDITOR=$EDITOR_CMD
fi
log "✓ Using editor: $EDITOR"

# Open the editor to input the prompt
log "➤ Opening editor to enter your prompt..."
$EDITOR "$TEMP_FILE"
log "✓ Prompt entered in editor"

# Read the file content as prompt
PROMPT=$(cat "$TEMP_FILE")

# If the user didn't enter anything, quit
if [ -z "$PROMPT" ]; then
  echo "No prompt provided."
  rm "$TEMP_FILE"
  exit 0
fi

# Prepare data for the API
log "✓ Preparing API request"
JSON_DATA=$(cat <<EOF
{
  "contents": [
    {
      "parts": [
        {
          "text": "$PROMPT"
        }
      ]
    }
  ]
}
EOF
)

# Call the Gemini API with curl
log "➤ Sending request to Gemini API..."
RESPONSE=$(curl -s "https://generativelanguage.googleapis.com/v1beta/models/$MODEL:generateContent?key=$GOOGLE_API_KEY" \
  -H 'Content-Type: application/json' \
  -d "$JSON_DATA" | \
  jq -r '.candidates[0].content.parts[0].text' 2>/dev/null || \
  echo "Error generating response. Check your API key and internet connection.")
log "✓ Response received from Gemini API"

# Write the response to the temporary file, after the prompt
log "✓ Updating file with the response"
{
  echo "$PROMPT"
  echo 
  echo "=== Gemini Response ($MODEL) ==="
  echo 
  echo "$RESPONSE"
} > "$TEMP_FILE"

# Reopen the file to view the response
log "➤ Opening editor to display the response..."
$EDITOR "$TEMP_FILE"
log "✓ Response display completed"

# Delete the temporary file
rm "$TEMP_FILE"
log "✓ Temporary file deleted"
log "✓ Operation completed" 