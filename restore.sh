#!/bin/bash

dir="$1"
malicious_dir="$2"

if [ "$#" -ne 2 ]; then
    echo "Usage: bash restore.sh dir malicious_dir"
    exit 1
fi

if [ ! -d "$dir" ] || [ ! -d "$malicious_dir" ]; then
    echo "Both folders must exist"
    exit 1
fi

while true; do
    files=()

    for file in "$malicious_dir"/*; do
        [ -f "$file" ] || continue
        files+=("$file")
    done

    if [ "${#files[@]}" -eq 0 ]; then
        echo "No malicious files to review."
        break
    fi

    echo "Quarantined files:"
    for i in "${!files[@]}"; do
        echo "$((i + 1))) $(basename "${files[$i]}")"
    done

    read -r -p "Choose a file number, or 0 to exit: " number

    if ! [[ "$number" =~ ^[0-9]+$ ]]; then
        echo "Invalid file number."
        continue
    fi

    number=$((10#$number))

    if [ "$number" -eq 0 ]; then
        break
    fi

    if [ "$number" -gt "${#files[@]}" ]; then
        echo "Invalid file number."
        continue
    fi

    file="${files[$((number - 1))]}"
    name=$(basename "$file")

    echo "File: $name"
    echo "1) Restore"
    echo "2) Delete permanently"
    echo "3) Leave in quarantine"
    read -r -p "Choose 1, 2, or 3: " choice

    case "$choice" in
        1)
            if mv "$file" "$dir/$name"; then
                safe_path=$(realpath "$dir/$name")

                if ! grep -Fxq -- "$safe_path" whitelist.txt 2>/dev/null; then
                    echo "$safe_path" >> whitelist.txt
                fi

                echo "Restored $name to $dir."
            fi
            ;;
        2)
            if rm "$file"; then
                echo "$name permanently deleted."
            fi
            ;;
        3)
            echo "$name left in quarantine."
            ;;
        *)
            echo "Invalid choice. $name left in quarantine."
            ;;
    esac
done
