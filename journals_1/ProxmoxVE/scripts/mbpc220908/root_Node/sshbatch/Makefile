# Makefile for sshbatch

.PHONY: batch-init single-init

# batch-init: Run batch_sshinit.sh to initialize multiple hosts from .env
# !! 需要先在 .env 中設定 USER_HOST1, KEY_NAME1, PASSWORD1, USER_HOST2, KEY_NAME2, PASSWORD2, ...
bat:
	bash batch_sshinit.sh

# single-init: Run sshinit.sh for a single host (usage: make single-init USER_HOST=host KEY_NAME=key [PASSWORD=pw])
sin:
	bash sshinit.sh "$(USER_HOST)" "$(KEY_NAME)" "$(WORKDIR)" "$(PASSWORD)" 