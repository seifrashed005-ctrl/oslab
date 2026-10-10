DIR = test_files
MALICIOUS_DIR = quarantine
INTERVAL = 5

run: create
	bash antivirusd.sh "$(DIR)" "$(MALICIOUS_DIR)" "$(INTERVAL)"

restore: create
	bash restore.sh "$(DIR)" "$(MALICIOUS_DIR)"

create:
	mkdir -p "$(MALICIOUS_DIR)"

.PHONY: run restore create
