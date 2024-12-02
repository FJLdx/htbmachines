#!/bin/bash

# Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
grayColour="\e[0;37m\033[1m"

# URL for the main file
main_url="https://htbmachines.github.io/bundle.js"

# Difficulty translations
declare -A difficulty_map=(
    ["facil"]="Fácil" ["easy"]="Fácil"
    ["media"]="Media" ["medium"]="Media"
    ["dificil"]="Difícil" ["hard"]="Difícil"
    ["insane"]="Insane" ["insano"]="Insane"
)

# Functions
function ctrl_c() {
    echo -e "\n\n${redColour}[!] Exiting...${endColour}\n"
    tput cnorm && exit 1
}
trap ctrl_c INT

function translate_difficulty() {
    local input="$(echo "$1" | tr '[:upper:]' '[:lower:]' | sed 'y/áéíóú/aeiou/')"
    echo "${difficulty_map[$input]:-$input}"
}

function checkFile() {
    if [ ! -f bundle.js ]; then
        echo -e "${redColour}[!] bundle.js not found. Please download it using the -u option.${endColour}"
        exit 1
    fi
}

function updateFiles() {
    tput civis
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Downloading or updating files...${endColour}"
    curl -s "$main_url" > bundle_temp.js
    if [ -f bundle.js ]; then
        md5_temp=$(md5sum bundle_temp.js | awk '{print $1}')
        md5_orig=$(md5sum bundle.js | awk '{print $1}')
        if [ "$md5_temp" == "$md5_orig" ]; then
            echo -e "${yellowColour}[+]${endColour}${grayColour} No updates required.${endColour}"
            rm bundle_temp.js
        else
            mv bundle_temp.js bundle.js
            echo -e "${yellowColour}[+]${endColour}${grayColour} Files updated successfully.${endColour}"
        fi
    else
        mv bundle_temp.js bundle.js
        echo -e "${yellowColour}[+]${endColour}${grayColour} Files downloaded successfully.${endColour}"
    fi
    tput cnorm
}

function helpPanel() {
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Usage:${endColour}"
    echo -e "\t${purpleColour}u)${endColour}${grayColour} Download or update necessary files${endColour}"
    echo -e "\t${purpleColour}m)${endColour}${grayColour} Search by machine name${endColour}"
    echo -e "\t${purpleColour}i)${endColour}${grayColour} Search by IP address${endColour}"
    echo -e "\t${purpleColour}d)${endColour}${grayColour} Search by difficulty (Spanish or English, with or without accents)${endColour}"
    echo -e "\t${purpleColour}o)${endColour}${grayColour} Search by operating system${endColour}"
    echo -e "\t${purpleColour}s)${endColour}${grayColour} Search by skill${endColour}"
    echo -e "\t${purpleColour}c)${endColour}${grayColour} Search by combination of difficulty and operating system${endColour}"
    echo -e "\t${purpleColour}y)${endColour}${grayColour} Get YouTube resolution link for a machine${endColour}"
    echo -e "\t${purpleColour}h)${endColour}${grayColour} Display this help panel${endColour}"
}

function searchMachine() {
    local machineName="$1"
    checkFile
    local results
    results=$(awk "/name: \"$machineName\"/,/resuelta:/" bundle.js | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')
    if [[ -n "$results" ]]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Properties for machine ${blueColour}$machineName${endColour}:${grayColour}\n$results"
    else
        echo -e "\n${redColour}[!] The specified machine does not exist.${endColour}\n"
    fi
}

function searchIP() {
    local ip="$1"
    checkFile
    local results
    results=$(grep "ip: \"$ip\"" -B 3 bundle.js | grep "name: " | awk '{print $NF}' | tr -d '"' | tr -d ',')
    if [[ -n "$results" ]]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} The machine corresponding to IP ${blueColour}$ip${endColour} is ${purpleColour}$results${endColour}"
        searchMachine "$results"
    else
        echo -e "\n${redColour}[!] The specified IP does not exist.${endColour}\n"
    fi
}

function getYoutubeLink() {
    local machineName="$1"
    checkFile
    local youtubeLink
    youtubeLink=$(awk "/name: \"$machineName\"/,/resuelta:/" bundle.js | grep "youtube" | awk '{print $2}' | tr -d '"' | tr -d ',')

    if [[ -n "$youtubeLink" ]]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} YouTube resolution link for ${blueColour}$machineName${endColour}:${grayColour}\n$youtubeLink\n"
    else
        echo -e "${redColour}[!] No YouTube link found for the specified machine.${endColour}"
    fi
}

function getMachinesDifficulty() {
    local input_difficulty="$1"
    checkFile
    local difficulty
    difficulty=$(translate_difficulty "$input_difficulty")

    if [[ -z "$difficulty" ]]; then
        echo -e "${redColour}[!] Invalid difficulty. Supported levels: easy, medium, hard, insane.${endColour}"
        return 1
    fi

    local results
    results=$(grep "dificultad: \"$difficulty\"" -B 5 bundle.js | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)

    if [[ -n "$results" ]]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Machines with difficulty ${purpleColour}$input_difficulty${endColour}:${grayColour}\n$results"
    else
        echo -e "${redColour}[!] No machines found for the specified difficulty.${endColour}"
    fi
}

function getSkill() {
    local skill="$1"
    checkFile
    local results
    results=$(grep "skills: " -B 6 bundle.js | grep -i "$skill" -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)

    if [[ -n "$results" ]]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Machines requiring skill ${purpleColour}$skill${endColour}:${grayColour}\n$results"
    else
        echo -e "${redColour}[!] No machines found requiring the specified skill.${endColour}\n"
    fi
}

function getOSMachines() {
    local os="$1"
    checkFile
    local results
    results=$(grep "so: \"$os\"" -B 5 bundle.js | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)

    if [[ -n "$results" ]]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Machines with operating system ${purpleColour}$os${endColour}:${grayColour}\n$results"
    else
        echo -e "${redColour}[!] No machines found for the specified operating system.${endColour}\n"
    fi
}

function getOSDifficultyMachines() {
    local input_difficulty="$1"
    local os="$2"
    checkFile
    local difficulty
    difficulty=$(translate_difficulty "$input_difficulty")

    if [[ -z "$difficulty" || -z "$os" ]]; then
        echo -e "${redColour}[!] Both difficulty and operating system must be provided.${endColour

}"
        return 1
    fi

    local results
    results=$(grep "so: \"$os\"" -C 4 bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)

    if [[ -n "$results" ]]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Machines with difficulty ${purpleColour}$difficulty${endColour}${grayColour} and operating system ${purpleColour}$os${endColour}:${grayColour}\n$results"
    else
        echo -e "${redColour}[!] No machines found for the specified combination.${endColour}"
    fi
}

# Argument Handling
while getopts "m:ui:y:d:o:s:c:h" arg; do
    case $arg in
        u) updateFiles ;;
        m) searchMachine "$OPTARG" ;;
        i) searchIP "$OPTARG" ;;
        d) getMachinesDifficulty "$OPTARG" ;;
        o) getOSMachines "$OPTARG" ;;
        s) getSkill "$OPTARG" ;;
        c) getOSDifficultyMachines "$OPTARG" ;;
        y) getYoutubeLink "$OPTARG" ;;
        h) helpPanel ;;
    esac
done
