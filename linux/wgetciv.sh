alias wgetciv='download_file'

download_file() {
    if [ -z "$1" ]; then
        echo "Usage: wgetciv [-l|--lora] [-m|--model] <URL>"
        return 1
    fi

    url="$1"
    token="YOUR_API_TOKEN_HERE"  # Replace "YOUR_API_TOKEN_HERE" with your actual API token
    filename=$(basename "$url")
    SD_INSTALL_DIR="/path/to/stable/diffusion/installation"  # Replace "/path/to/stable/diffusion/installation" with the actual path

    # Parse command line options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -l|--lora)
                SD_INSTALL_DIR="$SD_INSTALL_DIR/models/Lora"
                shift
                ;;
            -m|--model)
                SD_INSTALL_DIR="$SD_INSTALL_DIR/models/Stable-diffusion"
                shift
                ;;
            *)
                echo "Usage: wgetciv [-l|--lora] [-m|--model] <URL>"
                return 1
                ;;
        esac
    done

    # Append token to URL if it doesn't already contain a query string
    if [[ "$url" != *'?'* ]]; then
        url="${url}?token=${token}"
    else
        url="${url}&token=${token}"
    fi

    wget --content-disposition -P "$SD_INSTALL_DIR" "$url"
}
