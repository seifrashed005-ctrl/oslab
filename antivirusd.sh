#!/bin/bash

dir="$1"
malicious_dir="$2"
interval="$3"

if [ "$#" -ne 3 ]; then
    echo "Usage: bash antivirusd.sh dir malicious_dir interval-secs"
    exit 1
fi

if [ ! -d "$dir" ]; then
    echo "The folder does not exist"
    exit 1
fi

if ! [[ "$interval" =~ ^[0-9]+$ ]] || [ "$interval" -eq 0 ]; then
    echo "The interval must be positive and a whole number"
    exit 1
fi

mkdir -p "$malicious_dir" || exit 1

scan_files() {
    for file in "$dir"/*; do
        [ -f "$file" ] || continue
        file_path=$(realpath "$file")

        if grep -Fxq -- "$file_path" whitelist.txt 2>/dev/null; then
            continue
        fi

        malicious=false

        case "$file" in
            *.exe|*.bat|*.vbs|*.scr|*.ps1)
                malicious=true
                ;;
        esac

        if grep -qiE 'virus|trojan|malware|worm|ransomware' "$file"; then
            malicious=true
        fi

        if [ "$malicious" = true ]; then
            name=$(basename "$file")

            if cp "$file" "$malicious_dir/$name"; then
                if rm "$file"; then
                    echo "$name is malicious and it is DELETED"
                fi
            fi
        fi
    done
}

scan_files
ls -l "$dir" > directory-info.last

while true; do
    sleep "$interval"

    ls -l "$dir" > directory-info.new

    if ! cmp -s directory-info.last directory-info.new; then
        scan_files
        ls -l "$dir" > directory-info.new
        cp directory-info.new directory-info.last
    fi
done
