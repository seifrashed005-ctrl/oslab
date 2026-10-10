# Simple Antivirus — Lab 2

## Overview

This project is a simple antivirus system written in Bash.

The antivirus checks a folder for changes. When a change happens, it scans the files for specific extensions and keywords. Flagged files are copied to a quarantine folder and removed from their original folder.

The restore tool lets the user review quarantined files and choose whether to restore, permanently delete, or leave each file in quarantine.

This project also includes a Makefile, a cron version of the antivirus, and a whitelist for files that the user restores.

## Folder Structure

The main project folder contains:

- antivirusd.sh — runs the antivirus continuously.
- restore.sh — lets the user review quarantined files.
- antivirus-cron.sh — runs one monitoring check when called by cron.
- Makefile — provides commands to run the tools and create the quarantine folder.
- README.md — explains the project.

Other files and folders are created when the tools run:

- test_files/ — the default folder monitored by the Makefile.
- quarantine/ — the default quarantine folder.
- whitelist.txt — stores the full paths of restored files.
- directory-info.last — stores the previous directory listing for the antivirus.
- directory-info.new — stores the current directory listing for the antivirus.
- cron-directory-info.last — stores the previous listing for the cron script.
- cron-directory-info.new — stores the current listing for the cron script.
- cron_test/ — the source folder used in the cron example.
- cron_quarantine/ — the quarantine folder used in the cron example.
- cron.log — stores output and errors from the cron job.

The source and quarantine folders contain files directly inside them. The scripts do not scan nested folders.

## Prerequisites

The project runs on Ubuntu and needs Bash, GNU coreutils, grep, and make. Git is needed if you want to use the GitHub repository. Cron is needed for Bonus 1.

Install the required packages:

    sudo apt update
    sudo apt install bash coreutils grep make git cron

GNU coreutils provides commands such as ls, cp, mv, rm, and realpath.

Enable and start cron:

    sudo systemctl enable --now cron

Check that it is running:

    systemctl is-active cron

The expected output is:

    active

The commands below assume the project is in ~/oslab. If you put it somewhere else, change the paths accordingly.

Run the tools from the project folder so they use the same whitelist and directory-listing files.

## Running the Antivirus

1. Open an Ubuntu terminal and enter the project folder:

       cd ~/oslab

2. Create the source folder:

       mkdir -p test_files

3. Put the files you want to scan inside test_files.

4. Run the antivirus:

       bash antivirusd.sh test_files quarantine 5

The three inputs are:

- test_files — the folder being monitored.
- quarantine — the folder where flagged files are copied.
- 5 — the number of seconds between checks.

The source folder must already exist. The script creates the quarantine folder if needed.

The antivirus scans immediately when it starts. After that, it compares directory listings every five seconds. It scans again when the listings differ.

For each file successfully quarantined and removed, it prints:

    <file> is malicious and it is DELETED

To stop the antivirus, press Ctrl+C in its terminal.

## Running the Restore Tool

Stop the antivirus before using the restore tool. If the cron job is enabled, pause it too.

Run:

    cd ~/oslab
    bash restore.sh test_files quarantine

Both folders must exist.

The tool displays a numbered list of quarantined files.

1. Enter the number of the file you want to review.
2. Choose one of these actions:

   - 1 — restore the file to the source folder and add it to the whitelist.
   - 2 — permanently delete the file from quarantine.
   - 3 — leave the file in quarantine and return to the list.

3. Enter 0 at the file-number prompt to exit.

The numbers can change after a file is restored or deleted, so use the numbers shown in the current list.

After restoring a file, the tool prints:

    Restored <file> to <dir>.

After permanently deleting a file, it prints:

    <file> permanently deleted.

If quarantine is empty, it prints:

    No malicious files to review.

## Using the Makefile

The Makefile uses these default values:

- DIR = test_files
- MALICIOUS_DIR = quarantine
- INTERVAL = 5

Create the source folder first:

    mkdir -p test_files

Run the antivirus:

    make run

The default command also runs the antivirus:

    make

Stop it with Ctrl+C before running the restore tool:

    make restore

Create the quarantine folder without running either tool:

    make create

The run and restore targets depend on create, so the quarantine folder is created automatically if it does not exist.

You can use different folders and intervals without editing the Makefile:

    make run DIR=my_files MALICIOUS_DIR=my_quarantine INTERVAL=10

Run the restore tool with the same folders:

    make restore DIR=my_files MALICIOUS_DIR=my_quarantine

## Flagged Extensions and Keywords

The extension list is defined in the case statement inside scan_files() in both antivirusd.sh and antivirus-cron.sh.

The required extensions are:

- .exe
- .bat
- .vbs
- .scr
- .ps1

The keyword list is defined in the grep command inside scan_files() in both scripts:

    grep -qiE 'virus|trojan|malware|worm|ransomware' "$file"

The required keywords are:

- virus
- trojan
- malware
- worm
- ransomware

The keyword check is case-insensitive. For example, VIRUS and virus both match.

A file is flagged if its extension matches the extension list or its contents contain a listed keyword. Whitelisted files are skipped.

## Bonus 1: Cron Job

The antivirus-cron.sh script performs one monitoring check and then exits. Cron runs it repeatedly instead of using a loop inside the script.

It compares the current directory listing with the saved listing. It scans on its first run or when a change is detected.

The cron script uses the same extensions, keywords, quarantine behavior, and whitelist as the regular antivirus.

### Configure the Cron Job

1. Install cron if it is not already installed:

       sudo apt update
       sudo apt install cron

2. Enable and start it:

       sudo systemctl enable --now cron

3. Check the service:

       systemctl is-active cron

   It should print active.

4. Enter the project folder:

       cd ~/oslab

5. Create the folders used by this example:

       mkdir -p cron_test cron_quarantine

6. Make sure antivirus-cron.sh is saved in the project folder.

7. Open your user crontab:

       EDITOR=nano crontab -e

8. Add this line:

       * * * * * sleep 23; cd "$HOME/oslab" && /bin/bash antivirus-cron.sh cron_test cron_quarantine >> cron.log 2>&1

9. Save with Ctrl+O, press Enter, then exit with Ctrl+X.

10. Check the saved schedule:

        crontab -l

The five stars schedule the command every minute. Since standard cron does not have a seconds field, sleep 23 delays the script until approximately second 23.

The cd command enters the project folder before running the script.

The output and errors are appended to cron.log. Read the log with:

    cat ~/oslab/cron.log

Ubuntu must be running for the cron job to execute. The job will not run while the virtual machine is powered off or suspended.

### Pause the Cron Job

Open:

    EDITOR=nano crontab -e

Add # at the beginning of the antivirus schedule line, then save and exit.

Remove that # to enable the job again.

Pause the cron job before running restore.sh. Avoid running the regular antivirus and the cron scanner at the same time.

### Every Third Friday at 12:31 AM

To run on the third Friday of each month at 12:31 AM, use this alternative schedule:

    31 0 * * 5 [ "$(date +\%d)" -ge 15 ] && [ "$(date +\%d)" -le 21 ] && cd "$HOME/oslab" && /bin/bash antivirus-cron.sh cron_test cron_quarantine >> cron.log 2>&1

The cron expression schedules Fridays at 00:31. The date checks allow the script to run only when the day of the month is between 15 and 21, which identifies the third Friday.

The % sign is escaped because crontab treats it specially.

This is an alternative to the every-minute schedule. The time follows Ubuntu's configured timezone.

## Bonus 2: Whitelist

When the user restores a file using option 1, restore.sh adds its full absolute path to whitelist.txt.

The whitelist is saved on disk, so it remains available after the antivirus stops or restarts.

Both antivirusd.sh and antivirus-cron.sh check the whitelist before checking a file's extension or contents.

The check uses:

    grep -Fxq -- "$file_path" whitelist.txt 2>/dev/null

This looks for an exact full-line match of the file's path.

To mark a quarantined file as safe:

1. Stop the antivirus and pause its cron job.
2. Run the restore tool.
3. Select the file.
4. Choose option 1.
5. Restart the antivirus or enable the cron job again.

To check the whitelist:

    cd ~/oslab
    cat whitelist.txt

The restored file's full path should appear in the output.

The whitelist identifies files by their paths. Moving a file to a different path means it will no longer match that entry. A replacement file at the same whitelisted path will also be skipped.

## Testing

Use harmless text files to test the lab rules.

Create a test folder:

    mkdir -p test_files

Create a normal file:

    echo "hello world" > test_files/normal.txt

Create a file with a flagged extension:

    echo "sample" > test_files/test.exe

Create a file containing a flagged keyword:

    echo "This contains VIRUS" > test_files/bad.txt

Run:

    bash antivirusd.sh test_files quarantine 5

The expected result is that test.exe and bad.txt are quarantined while normal.txt remains.

While the antivirus is running, create another flagged file from a second terminal:

    cd ~/oslab
    echo "malware" > test_files/new_bad.txt

It should be detected at a later check.

Stop the antivirus with Ctrl+C before testing restore.sh.

Use the restore tool to test all three actions: restore, permanently delete, and leave in quarantine.

After restoring test.exe, restart the antivirus. The restored file should remain in the source folder because it is whitelisted.

To test the cron script manually:

    echo "worm" > cron_test/cron_bad.txt
    bash antivirus-cron.sh cron_test cron_quarantine

The file should be quarantined, and the command should return to the terminal prompt.

To test the actual cron job, enable its schedule, create another flagged file in cron_test, and check cron.log after the next scheduled run.

## Limitations

This is a simplified lab project. It flags files based only on the required extensions and keywords, so harmless files may be flagged.

The scripts scan files directly inside the source folder. They do not scan nested folders, and the current wildcard does not include hidden files.

Change detection uses ls -l listings. Some content changes may not change the displayed listing, so they may not trigger another scan.

The restore tool moves files back using their original names. An existing file with the same name in the source folder may be overwritten.
