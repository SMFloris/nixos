#/usr/bin/env bash

RELEASE=24.11
HOME_MANAGER_RELEASE=24.11

# List of inputs to search for in the channel's URL
inputs=("home-manager" "nixos" "nixos-unstable")
# Get the channel's URL
declare -A urls
urls["home-manager"]="https://github.com/nix-community/home-manager/archive/release-${HOME_MANAGER_RELEASE}.tar.gz"
urls["nixos"]="https://nixos.org/channels/nixos-${RELEASE}"
urls["nixos-unstable"]="https://nixos.org/channels/nixos-unstable"
# Iterate over the list of inputs
for input in "${inputs[@]}"
do
    channel_url=$(nix-channel --list | grep -o "$input https://.*")
    # Check if the channel's URL contains the current input
    if [[ $channel_url == *"$input"* ]]; then
        echo "The channel's URL contains '$input'"
        # In bash write some code that gets second column of channel_url string (split by whitespace) and checks it against a key value array that has the key 'input'
        channel_url_split=($channel_url)
        if [[ ${channel_url_split[1]} == ${urls[$input]} ]]; then
            echo "Channel is ok"
        else
            nix-channel --remove ${input}
            nix-channel --add ${urls[$input]} ${input}
            echo "Nix channel replaced with latest url"
        fi
    else
        echo "The channel's URL does not contain '$input'"
        nix-channel --add ${urls[$input]} ${input}
        echo "Added the correct url"
    fi
done

echo "Updating channels"
nix-channel --update

