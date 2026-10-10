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
for file in "$malicious_dir"/*; do
    [ -f "$file" ] || continue
    name=$(basename "$file")
    echo "File: $name"
    echo "1) Restore"
    echo "2) Delete permanently"
    echo "3) Leave in quarantine"
    read -r -p "Choose 1, 2, or 3: " choice
    case "$choice" in
        1)
            if mv "$file" "$dir/$name"; then
                echo "$name restored"
            fi
            ;;
        2)
            if rm "$file"; then
                echo "$name permanently deleted"
            fi
            ;;
        3)
            echo "$name left in quarantine"
            ;;
        *)
            echo "Invalid choice. $name left in quarantine"
            ;; 
esac
done
