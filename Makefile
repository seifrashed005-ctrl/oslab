DIR = test_files
MALICIOUS_DIR = quarantine
INTERVAL = 5
run:
	bash antivirusd.sh "$(DIR)" "$(MALICIOUS_DIR)" "$(INTERVAL)"
restore:
	bash restore.sh "$(DIR)" "$(MALICIOUS_DIR)"
.PHONY: run restore
