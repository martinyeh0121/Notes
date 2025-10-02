.PHONY: install uninstall test clean help run run-interactive run-batch dev-test

# 安裝路徑
PREFIX ?= $(HOME)/.local
INSTALL_BIN_DIR = $(PREFIX)/bin
INSTALL_LIB_DIR = $(PREFIX)/lib/ssh-tools
INSTALL_CONFIG_DIR = $(PREFIX)/etc/ssh-tools

# 開發時的路徑
DEV_BIN_DIR = bin
DEV_LIB_DIR = lib
DEV_CONFIG_DIR = config

# 顏色輸出
GREEN = \033[0;32m
BLUE = \033[0;34m
NC = \033[0m

help:
	@echo "SSH 工具集安裝與管理"
	@echo
	@echo "開發與測試:"
	@echo "  make run           執行互動式設定 (ssh-setup)"
	@echo "  make run-init      執行命令列設定 (ssh-init)"
	@echo "  make run-batch     執行批次設定 (ssh-batch-init)"
	@echo "  make dev-test      執行開發測試"
	@echo
	@echo "安裝與管理:"
	@echo "  make install       安裝到系統"
	@echo "  make uninstall     從系統移除"
	@echo "  make test          執行安裝後測試"
	@echo "  make clean         清理暫存檔"

# 開發時執行目標
run:
	@echo "$(BLUE)執行互動式設定...$(NC)"
	@chmod +x $(DEV_BIN_DIR)/ssh-setup
	@$(DEV_BIN_DIR)/ssh-setup

run-init:
	@echo "$(BLUE)執行命令列設定...$(NC)"
	@if [ -z "$(USER_HOST)" ] || [ -z "$(KEY_NAME)" ]; then \
		echo "使用方式: make run-init USER_HOST=user@host KEY_NAME=keyname [PASSWORD=pass]"; \
		exit 1; \
	fi
	@chmod +x $(DEV_BIN_DIR)/ssh-init
	@$(DEV_BIN_DIR)/ssh-init "$(USER_HOST)" "$(KEY_NAME)" "$(PASSWORD)"

run-batch:
	@echo "$(BLUE)執行批次設定...$(NC)"
	@if [ ! -f "$(DEV_CONFIG_DIR)/hosts.yaml" ]; then \
		echo "錯誤: 找不到設定檔 $(DEV_CONFIG_DIR)/hosts.yaml"; \
		exit 1; \
	fi
	@chmod +x $(DEV_BIN_DIR)/ssh-batch-init
	@$(DEV_BIN_DIR)/ssh-batch-init

dev-test:
	@echo "$(BLUE)執行開發測試...$(NC)"
	@chmod +x test/testconfig.sh
	@bash test/testconfig.sh
	@echo "$(BLUE)測試完成！$(NC)"

# 安裝目標
install:
	@echo "$(GREEN)安裝 SSH 工具集...$(NC)"
	@mkdir -p $(INSTALL_BIN_DIR)
	@mkdir -p $(INSTALL_LIB_DIR)
	@mkdir -p $(INSTALL_CONFIG_DIR)
	
	# 複製執行檔
	@cp $(DEV_BIN_DIR)/ssh-* $(INSTALL_BIN_DIR)/
	@chmod +x $(INSTALL_BIN_DIR)/ssh-*
	
	# 複製函式庫
	@cp -r $(DEV_LIB_DIR)/* $(INSTALL_LIB_DIR)/
	@chmod +x $(INSTALL_LIB_DIR)/*.sh
	
	# 複製設定檔範本
	@cp -n $(DEV_CONFIG_DIR)/hosts.yaml $(INSTALL_CONFIG_DIR)/hosts.yaml.example
	
	# 更新腳本中的路徑
	@sed -i 's|UTILS_PATH=.*|UTILS_PATH="$(INSTALL_LIB_DIR)/ssh_utils.sh"|' $(INSTALL_BIN_DIR)/ssh-*
	@sed -i 's|HOSTS_FILE=.*|HOSTS_FILE="$(INSTALL_CONFIG_DIR)/hosts.yaml"|' $(INSTALL_BIN_DIR)/ssh-batch-init
	
	@echo "$(GREEN)安裝完成！$(NC)"
	@echo "執行檔位置: $(INSTALL_BIN_DIR)"
	@echo "函式庫位置: $(INSTALL_LIB_DIR)"
	@echo "設定檔位置: $(INSTALL_CONFIG_DIR)"
	@echo
	@echo "請將以下路徑加入 PATH 環境變數："
	@echo "export PATH=\$$PATH:$(INSTALL_BIN_DIR)"

uninstall:
	@echo "$(GREEN)移除 SSH 工具集...$(NC)"
	@rm -f $(INSTALL_BIN_DIR)/ssh-*
	@rm -rf $(INSTALL_LIB_DIR)
	@rm -rf $(INSTALL_CONFIG_DIR)
	@echo "$(GREEN)移除完成！$(NC)"

test:
	@echo "$(GREEN)執行安裝後測試...$(NC)"
	@bash test/testconfig.sh
	@echo "$(GREEN)測試完成！$(NC)"

clean:
	@echo "$(GREEN)清理暫存檔...$(NC)"
	@find . -name "*.tmp" -type f -delete
	@find . -name "*~" -type f -delete
	@echo "$(GREEN)清理完成！$(NC)"