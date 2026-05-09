APP_NAME := Quick Thoughts
APP_DIR := dist/$(APP_NAME).app
INSTALL_DIR := /Applications

.PHONY: build run test bundle install uninstall clean

# Default: just build (debug)
build:
	swift build

# Run the app from terminal (debug binary). Ctrl-C to quit.
run:
	swift run

test:
	swift test

# Produce dist/Quick Thoughts.app (release-mode + ad-hoc signed)
bundle:
	bash scripts/bundle.sh

# Install (or update) the app into /Applications. Requires sudo on first run
# because /Applications is system-owned. Use `make install-user` to install
# to ~/Applications without sudo.
install: bundle
	@echo "==> Installing to $(INSTALL_DIR)/$(APP_NAME).app"
	@if [ -d "$(INSTALL_DIR)/$(APP_NAME).app" ]; then \
		sudo rm -rf "$(INSTALL_DIR)/$(APP_NAME).app"; \
	fi
	sudo cp -R "$(APP_DIR)" "$(INSTALL_DIR)/$(APP_NAME).app"
	@echo "✓ Installed. Open via Spotlight or Launchpad: $(APP_NAME)"

# Per-user install — no sudo needed
install-user: bundle
	@mkdir -p "$$HOME/Applications"
	@echo "==> Installing to $$HOME/Applications/$(APP_NAME).app"
	@rm -rf "$$HOME/Applications/$(APP_NAME).app"
	@cp -R "$(APP_DIR)" "$$HOME/Applications/$(APP_NAME).app"
	@echo "✓ Installed to ~/Applications/$(APP_NAME).app"

uninstall:
	@if [ -d "$(INSTALL_DIR)/$(APP_NAME).app" ]; then \
		sudo rm -rf "$(INSTALL_DIR)/$(APP_NAME).app"; \
		echo "✓ Removed $(INSTALL_DIR)/$(APP_NAME).app"; \
	fi
	@if [ -d "$$HOME/Applications/$(APP_NAME).app" ]; then \
		rm -rf "$$HOME/Applications/$(APP_NAME).app"; \
		echo "✓ Removed ~/Applications/$(APP_NAME).app"; \
	fi

clean:
	rm -rf .build dist
