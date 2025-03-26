# gemini-cli

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Bash](https://img.shields.io/badge/bash-compatible-brightgreen)

A simple command-line interface for interacting with Google's Gemini AI models.

## Synopsis

```
gemini [options]
```

## Description

gemini-cli is a command-line tool that facilitates interaction with the Google Gemini API. It opens a text editor where you can write a prompt, then sends this prompt to the Gemini API and displays the response in the same editor.

## Prerequisites

- A Google API key (environment variable `GOOGLE_API_KEY`)
- curl
- jq

## Environment Variables

- `GOOGLE_API_KEY` (required): Your Google API key to access Gemini
- `EDITOR` (optional): The text editor to use (default: nano) if not specified with `-e` option

## Command-line Options

- `-h, --help`: Display help message
- `-m, --model MODEL`: Specify the Gemini model to use
- `-l, --list-models`: List all available models
- `-e, --editor EDITOR`: Specify the text editor to use
- `-v, --verbose`: Display detailed status messages

## Available Models

- gemini-1.5-pro
- gemini-1.5-flash
- gemini-2.5-pro-exp-03-25 (default)
- gemini-pro
- gemini-pro-vision

## How It Works

1. Checks that the `GOOGLE_API_KEY` environment variable is defined
2. Creates a temporary file
3. Opens your text editor so you can enter your prompt
4. Sends your prompt to the Google Gemini API
5. Adds the response to the file, after your prompt
6. Reopens the editor to display the response
7. Deletes the temporary file once you close the editor

## Project Structure

```
.
├── gemini.sh       # Main executable script
├── gemini.1        # Man page documentation
├── LICENSE         # MIT License file
└── README.md       # Project documentation
```

## Installation

1. Make sure the `gemini.sh` script is executable:
   ```
   chmod +x gemini.sh
   ```

2. For easier access, place it in a directory included in your PATH or create a symbolic link:
   ```
   sudo ln -s /path/to/gemini.sh /usr/local/bin/gemini
   ```

3. Configure your API key:
   ```
   export GOOGLE_API_KEY='your-api-key'
   ```
   
   To make this configuration permanent, add this line to your `.bashrc` or `.zshrc` file.

4. To install the man page (optional):
   ```
   sudo cp gemini.1 /usr/local/share/man/man1/
   sudo mandb
   ```

## Usage Examples

### Basic Usage

```
gemini
```

### With a Specific Editor

```
gemini -e vim
```

### Using a Different Model

```
gemini -m gemini-1.5-pro
```

### Verbose Mode

```
gemini -v
```

### List Available Models

```
gemini -l
```

## Notes

- The temporary file is created in the `/tmp/` directory
- The script displays confirmation messages when verbose mode is enabled
- If no text is entered in the editor, the script terminates without calling the API

## Troubleshooting

If you receive an error message, check that:
- Your API key is properly configured
- You have a functioning internet connection

## Version History

### 1.0.0 (2024-05)
- Initial release
- Support for multiple Gemini models
- Custom editor selection
- Man page documentation

## Roadmap

- Add support for saving conversations
- Implement configuration file for default settings
- Add stream mode for real-time responses
- Support for context windows (multi-turn conversations)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Issues

If you encounter any problems or have suggestions, please [open an issue](https://github.com/gaBBtry/gemini-cli/issues) on the GitHub repository.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 