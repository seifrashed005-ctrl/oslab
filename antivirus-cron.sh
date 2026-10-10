#!/bin/bash

dir="$1"
malicious_dir="$2"

if [ "$#" -ne 2 ]; then
    echo "Usage: bash antivirus-cron.sh dir malicious_dir"
    exit 1
fi

if [ ! -d "$dir" ]; then
    echo "The folder does not exist"
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

ls -l "$dir" > cron-directory-info.new

if [ ! -f cron-directory-info.last ]; then
    scan_files
elif ! cmp -s cron-directory-info.last cron-directory-info.new; then
    scan_files
fi

ls -l "$dir" > cron-directory-info.new
cp cron-directory-info.new cron-directory-info.last
