alias wgetciv='download_file'

download_file() {
    if [ -z "$2" ]; then
        echo "Please enter both a switch and a URL"
        return 1
    fi

    # Store the switch in a separate variable
    switch="$1"
    shift

    # Check if the switch is -m or -l
    case "$switch" in
        -l|--lora)
            SD_INSTALL_DIR="/path/stable-diffusion-webui/models/Lora"
            ;;
        -m|--model)
            SD_INSTALL_DIR="/path/stable-diffusion-webui/models/Stable-diffusion"
            ;;
        *)
            echo "Invalid switch. Please use -l or -m as the first argument"
            return 1
            ;;
    esac

    # Store the URL in a separate variable
    url_to_download="$1"

    # Append token to URL if it doesn't already contain a query string
    token="TOKEN"  # Replace with actual token
    if [[ "$url_to_download" != *'?'* ]]; then
        url_to_download="${url_to_download}?token=${token}"
    else
        url_to_download="${url_to_download}&token=${token}"
    fi

    # Download the file
    wget --content-disposition -P "$SD_INSTALL_DIR" "$url_to_download"
}
