
.PHONY: init 
init:
	chmod +x ./scripts/*

.PHONY: check-memory
check-memory:
	./scripts/check-memory.sh

.PHONY: restart-palworld
restart-palworld:
	./scripts/restart_service.sh --force-restart

.PHONY: restart-palworld-now
restart-palworld-now:
	./scripts/restart_service.sh --force-restart-now

.PHONY: check-status
check-status:
	sudo systemctl status palworld-dedicated.service

