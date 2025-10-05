#!/bin/bash

hostURL="https://raw.githubusercontent.com/supraboy981322/teenyHTTP/main"

printf "\nstarting teenyHTTP install...\n\n"

function newOverRide() {
    printf "\n..what path would you like to override?\n"
    printf "....please enter the path the user enters for the URL, as exampled before\n"
    printf "......leave blank for no path (meaning \"your.web.site\" without a file path)\n"
    printf "....for example, just enter \"foo\" for the address \"your.web.site/foo\"\n"
    printf ".....(or \"fizz/buzz\" for the address \"your.web.site/fizz/buzz\")\n"
    read -r urlPath
    printf "\n..what file would you like to serve for this override?\n"
    printf "...(relative to your working directory)\n"
    printf "....for example: \"fizz/buzz.html\" for a file named \"buzz.html in the directory \"fizz\"\n"
    printf ".....or, \"404\" to block the file from being accessed\n"
    read -r filePath
    printf "\n....updating \"override.json\"\n"
    addTOjson "$urlPath" "$filePath" override.json
    printf "\n..would you like to create another override?\n"
    printf "...(this can always be done later, by editing the\"override.json\" file)\n"
    promptYesOrNo
    if [[ $value == "true" ]]; then
      newOverRide
    fi
}

function promptYesOrNo() {
    printf "[y/n]\n"
    read -r yOn
    case "$yOn" in
        "Y"|"y"|"yes"|"Yes"|"YES"|"yES"|"yeS"|"YeS"|"YEs")
            value="true"
            ;;
        "N"|"n"|"no"|"No"|"nO"|"NO") 
            value="false"
            ;;
        *)
            printf "invalid answer.\n  this is a \"yes\" or \"no\" question.\n"
            promptYesOrNo
            ;;
    esac
}

function addTOjson() {
    local selector="$1"
    local value="$2"
    file="$3"
    local length=$(cat "$file" | wc -l)
    local length=$((length))
    local currentLine="$(head -n $((length - 1)) "$file" | tail -1)"
    local newValueLine=",\n    \"${selector}\": \"${value}\""
    sed -i "$((length - 1))c\\${currentLine}${newValueLine}" "$file"
}


for program in "wget" "curl" "wcurl"; do
    if command -v "$program" &> /dev/null; then
        printf "using $program\n"
        case "$program" in
            "curl")
                downloader=(curl -fsS -O --progress-bar)
                ;;
            "wcurl")
                downloader=(wcurl --curl-options="progress-bar")
                ;;
            "wget")
                downloader=(wget -q)
                ;;
            *)
                downloader=""
                ;;
        esac
        break
    fi
done

if [[ -z "$downloader" ]]; then
    printf "missing dependencies...\n"
    printf "for auto-install any of the following is required:\n"
    printf "  - wget\n"
    printf "  - curl\n"
    printf "  - wcurl\n"
    printf "\n"
    exit
fi

printf "\n"

"${downloader[@]}" "${hostURL}/teenyHTTP.tar.gz" || { echo "download failed"; exit 1; }

tar -xzf teenyHTTP.tar.gz

printf "\nwould you like to change some settings now?\n"
promptYesOrNo
if [[ $value == "true" ]]; then
    printf "\n..what port do you want to run on?\n"
    read -r port
    printf "....updating \"settings.json\"\n\n"
    sed -i "2c\    \"port\": \"${port}\"," settings.json
    printf "..do you want to be able to manually override file paths in the address?\n"
    printf "....as in:\n"
    printf "......do you want \"your.web.site\" (without specifying a file) to serve \"index.html\"\n"
    printf "........so users don't have to type \"your.web.site/index.html\" to go to your home page\"\n"
    printf "......alternatively, this can be used to block access to certain files\n"
    printf "........If you have a file named \"secret.txt\" you can override it to \"404\" to prevent access\n"
    promptYesOrNo
    printf "....updating \"settings.json\"\n\n"
    sed -i "3c\    \"override\": ${value}" settings.json
    if [[ $value == "true" ]]; then
        printf "..would you like to set some overrides now?\n"
        promptYesOrNo
        if [[ $value == "true" ]]; then
            newOverRide
        fi
    fi
fi

printf "setup complete\n"
printf "thank you for picking teenyHTTP\n"
