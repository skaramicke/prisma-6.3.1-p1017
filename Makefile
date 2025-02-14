MIN_POSTGRESQL_VERSION = 10
MIN_PRISMA_VERSION = 5
VERSION_TARGETS_TRIGGER_WORDS = VERSION MAKE TARGETS

versions:
	mkdir -p versions

versions/postgresql: versions
	@echo "Fetching PostgreSQL versions...\n"
	@url="https://registry.hub.docker.com/v2/repositories/library/postgres/tags"; \
	while [ "$$url" != "null" ]; do \
		response=$$(curl -s "$$url"); \
		postgresql_versions="$$postgresql_versions $$(echo "$$response" | jq -r '.results[].name' | grep -E '^[0-9]+\.[0-9]+$$' | awk -F. '$$1 >= ${MIN_POSTGRESQL_VERSION}')"; \
		postgresql_versions=$$(echo "$$postgresql_versions" | tr ' ' '\n' | sort -V -u | tr '\n' ' '); \
		tput cuu1; tput el; \
		echo "Found $$(echo "$$postgresql_versions" | wc -w) versions"
		url=$$(echo "$$response" | jq -r '.next'); \
	done; \
	postgresql_versions=$$(echo "$$postgresql_versions" | xargs)
	echo "$$postgresql_versions" > versions/postgresql

versions/prisma: versions
	@echo "Fetching Prisma versions..."
	@url="https://api.github.com/repos/prisma/prisma/tags"; \
	while [ "$$url" != "null" ]; do \
		response=$$(curl -s "$$url"); \
		prisma_versions="$$prisma_versions $$(echo "$$response" | jq -r '.[].name' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$$' | awk -F. '$$1 >= ${MIN_PRISMA_VERSION}')"; \
		prisma_versions=$$(echo "$$prisma_versions" | tr ' ' '\n' | sort -V -u | tr '\n' ' '); \
		tput cuu1; tput el; \
		echo "Found $$(echo "$$prisma_versions" | wc -w) versions"; \
		url="null"; \
	done; \
	prisma_versions=$$(echo "$$prisma_versions" | xargs); \
	if [ -n "$$prisma_versions" ]; then \
		echo "$$prisma_versions" > versions/prisma; \
	else \
		echo "No Prisma versions found"; \
	fi

.PHONY: version_make_targets
version_make_targets: versions/prisma versions/postgresql
	echo "Generating version make targets..."
	@target_names=""; \
	for pg_version in $$(cat versions/postgresql); do \
		for prisma_version in $$(cat versions/prisma); do \
			target_name="results/$$pg_version/$$prisma_version/result"; \
			target_names="$$target_names $$target_name"; \
			echo "## PostgreSQL $$pg_version, Prisma $$prisma_version, " >> ./Makefile; \
			echo "results/$$pg_version/$$prisma_version/result: results" >> ./Makefile; \
			echo "\t@echo \"Building PostgreSQL $$pg_version with Prisma $$prisma_version...\"" >> ./Makefile; \
			echo "\t@./test_compatibility.sh $$pg_version $$prisma_version" >> ./Makefile; \
			echo "\n" >> ./Makefile; \
		done; \
	done; \
	target_names=$$(echo "$$target_names" | xargs); \
	echo ".PHONY: all_versions" >> ./Makefile; \
	echo "all_versions: $$target_names" >> ./Makefile; \
	echo "\n" >> ./Makefile; \
	
.PHONY: clean
clean:
	@sed -i '' '/## ${VERSION_TARGETS_TRIGGER_WORDS}/,$$d' ./Makefile
	@echo "## ${VERSION_TARGETS_TRIGGER_WORDS}" >> ./Makefile

results:
	@mkdir -p results

results.md:
	@echo "# Results" > results.md
	@header="| "; \
	divider="| -"; \
	pg_versions=$$(cat versions/postgresql); \
	prisma_versions=$$(cat versions/prisma); \
	for pg_version in $$pg_versions; do \
		header="$$header | PostgreSQL $$pg_version "; \
		divider="$$divider | -"; \
	done; \
	echo "$$header |" >> results.md; \
	echo "$$divider |" >> results.md; \
	for prisma_version in $$prisma_versions; do \
		row="| Prisma $$prisma_version "; \
		for pg_version in $$pg_versions; do \
			result_file="results/$$pg_version/$$prisma_version/result"; \
			if [ -f $$result_file ]; then \
				if grep -q 'failure' $$result_file; then \
					result="❌"; \
				elif grep -q 'success' $$result_file; then \
					result="✅"; \
				else \
					result="❓"; \
				fi; \
			else \
				result="N/A"; \
			fi; \
			row="$$row | $$result"; \
		done; \
		echo "$$row |" >> results.md; \
	done;

## VERSION MAKE TARGETS
## PostgreSQL 10.0, Prisma 5.9.0, 
results/10.0/5.9.0/result: results
	@echo "Building PostgreSQL 10.0 with Prisma 5.9.0..."
	@./test_compatibility.sh 10.0 5.9.0


## PostgreSQL 10.0, Prisma 5.10.0, 
results/10.0/5.10.0/result: results
	@echo "Building PostgreSQL 10.0 with Prisma 5.10.0..."
	@./test_compatibility.sh 10.0 5.10.0


## PostgreSQL 10.0, Prisma 5.11.0, 
results/10.0/5.11.0/result: results
	@echo "Building PostgreSQL 10.0 with Prisma 5.11.0..."
	@./test_compatibility.sh 10.0 5.11.0


## PostgreSQL 10.0, Prisma 5.12.0, 
results/10.0/5.12.0/result: results
	@echo "Building PostgreSQL 10.0 with Prisma 5.12.0..."
	@./test_compatibility.sh 10.0 5.12.0


## PostgreSQL 10.0, Prisma 5.13.0, 
results/10.0/5.13.0/result: results
	@echo "Building PostgreSQL 10.0 with Prisma 5.13.0..."
	@./test_compatibility.sh 10.0 5.13.0


## PostgreSQL 10.0, Prisma 5.14.0, 
results/10.0/5.14.0/result: results
	@echo "Building PostgreSQL 10.0 with Prisma 5.14.0..."
	@./test_compatibility.sh 10.0 5.14.0


## PostgreSQL 10.0, Prisma 5.15.0, 
results/10.0/5.15.0/result: results
	@echo "Building PostgreSQL 10.0 with Prisma 5.15.0..."
	@./test_compatibility.sh 10.0 5.15.0


## PostgreSQL 10.0, Prisma 5.16.0, 
results/10.0/5.16.0/result: results
	@echo "Building PostgreSQL 10.0 with Prisma 5.16.0..."
	@./test_compatibility.sh 10.0 5.16.0


## PostgreSQL 10.0, Prisma 5.17.0, 
results/10.0/5.17.0/result: results
	@echo "Building PostgreSQL 10.0 with Prisma 5.17.0..."
	@./test_compatibility.sh 10.0 5.17.0


## PostgreSQL 10.0, Prisma 5.18.0, 
results/10.0/5.18.0/result: results
	@echo "Building PostgreSQL 10.0 with Prisma 5.18.0..."
	@./test_compatibility.sh 10.0 5.18.0


## PostgreSQL 10.0, Prisma 5.19.0, 
results/10.0/5.19.0/result: results
	@echo "Building PostgreSQL 10.0 with Prisma 5.19.0..."
	@./test_compatibility.sh 10.0 5.19.0


## PostgreSQL 10.0, Prisma 5.20.0, 
results/10.0/5.20.0/result: results
	@echo "Building PostgreSQL 10.0 with Prisma 5.20.0..."
	@./test_compatibility.sh 10.0 5.20.0


## PostgreSQL 10.0, Prisma 5.21.0, 
results/10.0/5.21.0/result: results
	@echo "Building PostgreSQL 10.0 with Prisma 5.21.0..."
	@./test_compatibility.sh 10.0 5.21.0


## PostgreSQL 10.0, Prisma 5.22.0, 
results/10.0/5.22.0/result: results
	@echo "Building PostgreSQL 10.0 with Prisma 5.22.0..."
	@./test_compatibility.sh 10.0 5.22.0


## PostgreSQL 10.0, Prisma 6.0.0, 
results/10.0/6.0.0/result: results
	@echo "Building PostgreSQL 10.0 with Prisma 6.0.0..."
	@./test_compatibility.sh 10.0 6.0.0


## PostgreSQL 10.0, Prisma 6.1.0, 
results/10.0/6.1.0/result: results
	@echo "Building PostgreSQL 10.0 with Prisma 6.1.0..."
	@./test_compatibility.sh 10.0 6.1.0


## PostgreSQL 10.0, Prisma 6.2.0, 
results/10.0/6.2.0/result: results
	@echo "Building PostgreSQL 10.0 with Prisma 6.2.0..."
	@./test_compatibility.sh 10.0 6.2.0


## PostgreSQL 10.0, Prisma 6.2.1, 
results/10.0/6.2.1/result: results
	@echo "Building PostgreSQL 10.0 with Prisma 6.2.1..."
	@./test_compatibility.sh 10.0 6.2.1


## PostgreSQL 10.0, Prisma 6.3.0, 
results/10.0/6.3.0/result: results
	@echo "Building PostgreSQL 10.0 with Prisma 6.3.0..."
	@./test_compatibility.sh 10.0 6.3.0


## PostgreSQL 10.0, Prisma 6.3.1, 
results/10.0/6.3.1/result: results
	@echo "Building PostgreSQL 10.0 with Prisma 6.3.1..."
	@./test_compatibility.sh 10.0 6.3.1


## PostgreSQL 11.0, Prisma 5.9.0, 
results/11.0/5.9.0/result: results
	@echo "Building PostgreSQL 11.0 with Prisma 5.9.0..."
	@./test_compatibility.sh 11.0 5.9.0


## PostgreSQL 11.0, Prisma 5.10.0, 
results/11.0/5.10.0/result: results
	@echo "Building PostgreSQL 11.0 with Prisma 5.10.0..."
	@./test_compatibility.sh 11.0 5.10.0


## PostgreSQL 11.0, Prisma 5.11.0, 
results/11.0/5.11.0/result: results
	@echo "Building PostgreSQL 11.0 with Prisma 5.11.0..."
	@./test_compatibility.sh 11.0 5.11.0


## PostgreSQL 11.0, Prisma 5.12.0, 
results/11.0/5.12.0/result: results
	@echo "Building PostgreSQL 11.0 with Prisma 5.12.0..."
	@./test_compatibility.sh 11.0 5.12.0


## PostgreSQL 11.0, Prisma 5.13.0, 
results/11.0/5.13.0/result: results
	@echo "Building PostgreSQL 11.0 with Prisma 5.13.0..."
	@./test_compatibility.sh 11.0 5.13.0


## PostgreSQL 11.0, Prisma 5.14.0, 
results/11.0/5.14.0/result: results
	@echo "Building PostgreSQL 11.0 with Prisma 5.14.0..."
	@./test_compatibility.sh 11.0 5.14.0


## PostgreSQL 11.0, Prisma 5.15.0, 
results/11.0/5.15.0/result: results
	@echo "Building PostgreSQL 11.0 with Prisma 5.15.0..."
	@./test_compatibility.sh 11.0 5.15.0


## PostgreSQL 11.0, Prisma 5.16.0, 
results/11.0/5.16.0/result: results
	@echo "Building PostgreSQL 11.0 with Prisma 5.16.0..."
	@./test_compatibility.sh 11.0 5.16.0


## PostgreSQL 11.0, Prisma 5.17.0, 
results/11.0/5.17.0/result: results
	@echo "Building PostgreSQL 11.0 with Prisma 5.17.0..."
	@./test_compatibility.sh 11.0 5.17.0


## PostgreSQL 11.0, Prisma 5.18.0, 
results/11.0/5.18.0/result: results
	@echo "Building PostgreSQL 11.0 with Prisma 5.18.0..."
	@./test_compatibility.sh 11.0 5.18.0


## PostgreSQL 11.0, Prisma 5.19.0, 
results/11.0/5.19.0/result: results
	@echo "Building PostgreSQL 11.0 with Prisma 5.19.0..."
	@./test_compatibility.sh 11.0 5.19.0


## PostgreSQL 11.0, Prisma 5.20.0, 
results/11.0/5.20.0/result: results
	@echo "Building PostgreSQL 11.0 with Prisma 5.20.0..."
	@./test_compatibility.sh 11.0 5.20.0


## PostgreSQL 11.0, Prisma 5.21.0, 
results/11.0/5.21.0/result: results
	@echo "Building PostgreSQL 11.0 with Prisma 5.21.0..."
	@./test_compatibility.sh 11.0 5.21.0


## PostgreSQL 11.0, Prisma 5.22.0, 
results/11.0/5.22.0/result: results
	@echo "Building PostgreSQL 11.0 with Prisma 5.22.0..."
	@./test_compatibility.sh 11.0 5.22.0


## PostgreSQL 11.0, Prisma 6.0.0, 
results/11.0/6.0.0/result: results
	@echo "Building PostgreSQL 11.0 with Prisma 6.0.0..."
	@./test_compatibility.sh 11.0 6.0.0


## PostgreSQL 11.0, Prisma 6.1.0, 
results/11.0/6.1.0/result: results
	@echo "Building PostgreSQL 11.0 with Prisma 6.1.0..."
	@./test_compatibility.sh 11.0 6.1.0


## PostgreSQL 11.0, Prisma 6.2.0, 
results/11.0/6.2.0/result: results
	@echo "Building PostgreSQL 11.0 with Prisma 6.2.0..."
	@./test_compatibility.sh 11.0 6.2.0


## PostgreSQL 11.0, Prisma 6.2.1, 
results/11.0/6.2.1/result: results
	@echo "Building PostgreSQL 11.0 with Prisma 6.2.1..."
	@./test_compatibility.sh 11.0 6.2.1


## PostgreSQL 11.0, Prisma 6.3.0, 
results/11.0/6.3.0/result: results
	@echo "Building PostgreSQL 11.0 with Prisma 6.3.0..."
	@./test_compatibility.sh 11.0 6.3.0


## PostgreSQL 11.0, Prisma 6.3.1, 
results/11.0/6.3.1/result: results
	@echo "Building PostgreSQL 11.0 with Prisma 6.3.1..."
	@./test_compatibility.sh 11.0 6.3.1


## PostgreSQL 12.0, Prisma 5.9.0, 
results/12.0/5.9.0/result: results
	@echo "Building PostgreSQL 12.0 with Prisma 5.9.0..."
	@./test_compatibility.sh 12.0 5.9.0


## PostgreSQL 12.0, Prisma 5.10.0, 
results/12.0/5.10.0/result: results
	@echo "Building PostgreSQL 12.0 with Prisma 5.10.0..."
	@./test_compatibility.sh 12.0 5.10.0


## PostgreSQL 12.0, Prisma 5.11.0, 
results/12.0/5.11.0/result: results
	@echo "Building PostgreSQL 12.0 with Prisma 5.11.0..."
	@./test_compatibility.sh 12.0 5.11.0


## PostgreSQL 12.0, Prisma 5.12.0, 
results/12.0/5.12.0/result: results
	@echo "Building PostgreSQL 12.0 with Prisma 5.12.0..."
	@./test_compatibility.sh 12.0 5.12.0


## PostgreSQL 12.0, Prisma 5.13.0, 
results/12.0/5.13.0/result: results
	@echo "Building PostgreSQL 12.0 with Prisma 5.13.0..."
	@./test_compatibility.sh 12.0 5.13.0


## PostgreSQL 12.0, Prisma 5.14.0, 
results/12.0/5.14.0/result: results
	@echo "Building PostgreSQL 12.0 with Prisma 5.14.0..."
	@./test_compatibility.sh 12.0 5.14.0


## PostgreSQL 12.0, Prisma 5.15.0, 
results/12.0/5.15.0/result: results
	@echo "Building PostgreSQL 12.0 with Prisma 5.15.0..."
	@./test_compatibility.sh 12.0 5.15.0


## PostgreSQL 12.0, Prisma 5.16.0, 
results/12.0/5.16.0/result: results
	@echo "Building PostgreSQL 12.0 with Prisma 5.16.0..."
	@./test_compatibility.sh 12.0 5.16.0


## PostgreSQL 12.0, Prisma 5.17.0, 
results/12.0/5.17.0/result: results
	@echo "Building PostgreSQL 12.0 with Prisma 5.17.0..."
	@./test_compatibility.sh 12.0 5.17.0


## PostgreSQL 12.0, Prisma 5.18.0, 
results/12.0/5.18.0/result: results
	@echo "Building PostgreSQL 12.0 with Prisma 5.18.0..."
	@./test_compatibility.sh 12.0 5.18.0


## PostgreSQL 12.0, Prisma 5.19.0, 
results/12.0/5.19.0/result: results
	@echo "Building PostgreSQL 12.0 with Prisma 5.19.0..."
	@./test_compatibility.sh 12.0 5.19.0


## PostgreSQL 12.0, Prisma 5.20.0, 
results/12.0/5.20.0/result: results
	@echo "Building PostgreSQL 12.0 with Prisma 5.20.0..."
	@./test_compatibility.sh 12.0 5.20.0


## PostgreSQL 12.0, Prisma 5.21.0, 
results/12.0/5.21.0/result: results
	@echo "Building PostgreSQL 12.0 with Prisma 5.21.0..."
	@./test_compatibility.sh 12.0 5.21.0


## PostgreSQL 12.0, Prisma 5.22.0, 
results/12.0/5.22.0/result: results
	@echo "Building PostgreSQL 12.0 with Prisma 5.22.0..."
	@./test_compatibility.sh 12.0 5.22.0


## PostgreSQL 12.0, Prisma 6.0.0, 
results/12.0/6.0.0/result: results
	@echo "Building PostgreSQL 12.0 with Prisma 6.0.0..."
	@./test_compatibility.sh 12.0 6.0.0


## PostgreSQL 12.0, Prisma 6.1.0, 
results/12.0/6.1.0/result: results
	@echo "Building PostgreSQL 12.0 with Prisma 6.1.0..."
	@./test_compatibility.sh 12.0 6.1.0


## PostgreSQL 12.0, Prisma 6.2.0, 
results/12.0/6.2.0/result: results
	@echo "Building PostgreSQL 12.0 with Prisma 6.2.0..."
	@./test_compatibility.sh 12.0 6.2.0


## PostgreSQL 12.0, Prisma 6.2.1, 
results/12.0/6.2.1/result: results
	@echo "Building PostgreSQL 12.0 with Prisma 6.2.1..."
	@./test_compatibility.sh 12.0 6.2.1


## PostgreSQL 12.0, Prisma 6.3.0, 
results/12.0/6.3.0/result: results
	@echo "Building PostgreSQL 12.0 with Prisma 6.3.0..."
	@./test_compatibility.sh 12.0 6.3.0


## PostgreSQL 12.0, Prisma 6.3.1, 
results/12.0/6.3.1/result: results
	@echo "Building PostgreSQL 12.0 with Prisma 6.3.1..."
	@./test_compatibility.sh 12.0 6.3.1


## PostgreSQL 13.0, Prisma 5.9.0, 
results/13.0/5.9.0/result: results
	@echo "Building PostgreSQL 13.0 with Prisma 5.9.0..."
	@./test_compatibility.sh 13.0 5.9.0


## PostgreSQL 13.0, Prisma 5.10.0, 
results/13.0/5.10.0/result: results
	@echo "Building PostgreSQL 13.0 with Prisma 5.10.0..."
	@./test_compatibility.sh 13.0 5.10.0


## PostgreSQL 13.0, Prisma 5.11.0, 
results/13.0/5.11.0/result: results
	@echo "Building PostgreSQL 13.0 with Prisma 5.11.0..."
	@./test_compatibility.sh 13.0 5.11.0


## PostgreSQL 13.0, Prisma 5.12.0, 
results/13.0/5.12.0/result: results
	@echo "Building PostgreSQL 13.0 with Prisma 5.12.0..."
	@./test_compatibility.sh 13.0 5.12.0


## PostgreSQL 13.0, Prisma 5.13.0, 
results/13.0/5.13.0/result: results
	@echo "Building PostgreSQL 13.0 with Prisma 5.13.0..."
	@./test_compatibility.sh 13.0 5.13.0


## PostgreSQL 13.0, Prisma 5.14.0, 
results/13.0/5.14.0/result: results
	@echo "Building PostgreSQL 13.0 with Prisma 5.14.0..."
	@./test_compatibility.sh 13.0 5.14.0


## PostgreSQL 13.0, Prisma 5.15.0, 
results/13.0/5.15.0/result: results
	@echo "Building PostgreSQL 13.0 with Prisma 5.15.0..."
	@./test_compatibility.sh 13.0 5.15.0


## PostgreSQL 13.0, Prisma 5.16.0, 
results/13.0/5.16.0/result: results
	@echo "Building PostgreSQL 13.0 with Prisma 5.16.0..."
	@./test_compatibility.sh 13.0 5.16.0


## PostgreSQL 13.0, Prisma 5.17.0, 
results/13.0/5.17.0/result: results
	@echo "Building PostgreSQL 13.0 with Prisma 5.17.0..."
	@./test_compatibility.sh 13.0 5.17.0


## PostgreSQL 13.0, Prisma 5.18.0, 
results/13.0/5.18.0/result: results
	@echo "Building PostgreSQL 13.0 with Prisma 5.18.0..."
	@./test_compatibility.sh 13.0 5.18.0


## PostgreSQL 13.0, Prisma 5.19.0, 
results/13.0/5.19.0/result: results
	@echo "Building PostgreSQL 13.0 with Prisma 5.19.0..."
	@./test_compatibility.sh 13.0 5.19.0


## PostgreSQL 13.0, Prisma 5.20.0, 
results/13.0/5.20.0/result: results
	@echo "Building PostgreSQL 13.0 with Prisma 5.20.0..."
	@./test_compatibility.sh 13.0 5.20.0


## PostgreSQL 13.0, Prisma 5.21.0, 
results/13.0/5.21.0/result: results
	@echo "Building PostgreSQL 13.0 with Prisma 5.21.0..."
	@./test_compatibility.sh 13.0 5.21.0


## PostgreSQL 13.0, Prisma 5.22.0, 
results/13.0/5.22.0/result: results
	@echo "Building PostgreSQL 13.0 with Prisma 5.22.0..."
	@./test_compatibility.sh 13.0 5.22.0


## PostgreSQL 13.0, Prisma 6.0.0, 
results/13.0/6.0.0/result: results
	@echo "Building PostgreSQL 13.0 with Prisma 6.0.0..."
	@./test_compatibility.sh 13.0 6.0.0


## PostgreSQL 13.0, Prisma 6.1.0, 
results/13.0/6.1.0/result: results
	@echo "Building PostgreSQL 13.0 with Prisma 6.1.0..."
	@./test_compatibility.sh 13.0 6.1.0


## PostgreSQL 13.0, Prisma 6.2.0, 
results/13.0/6.2.0/result: results
	@echo "Building PostgreSQL 13.0 with Prisma 6.2.0..."
	@./test_compatibility.sh 13.0 6.2.0


## PostgreSQL 13.0, Prisma 6.2.1, 
results/13.0/6.2.1/result: results
	@echo "Building PostgreSQL 13.0 with Prisma 6.2.1..."
	@./test_compatibility.sh 13.0 6.2.1


## PostgreSQL 13.0, Prisma 6.3.0, 
results/13.0/6.3.0/result: results
	@echo "Building PostgreSQL 13.0 with Prisma 6.3.0..."
	@./test_compatibility.sh 13.0 6.3.0


## PostgreSQL 13.0, Prisma 6.3.1, 
results/13.0/6.3.1/result: results
	@echo "Building PostgreSQL 13.0 with Prisma 6.3.1..."
	@./test_compatibility.sh 13.0 6.3.1


## PostgreSQL 14.0, Prisma 5.9.0, 
results/14.0/5.9.0/result: results
	@echo "Building PostgreSQL 14.0 with Prisma 5.9.0..."
	@./test_compatibility.sh 14.0 5.9.0


## PostgreSQL 14.0, Prisma 5.10.0, 
results/14.0/5.10.0/result: results
	@echo "Building PostgreSQL 14.0 with Prisma 5.10.0..."
	@./test_compatibility.sh 14.0 5.10.0


## PostgreSQL 14.0, Prisma 5.11.0, 
results/14.0/5.11.0/result: results
	@echo "Building PostgreSQL 14.0 with Prisma 5.11.0..."
	@./test_compatibility.sh 14.0 5.11.0


## PostgreSQL 14.0, Prisma 5.12.0, 
results/14.0/5.12.0/result: results
	@echo "Building PostgreSQL 14.0 with Prisma 5.12.0..."
	@./test_compatibility.sh 14.0 5.12.0


## PostgreSQL 14.0, Prisma 5.13.0, 
results/14.0/5.13.0/result: results
	@echo "Building PostgreSQL 14.0 with Prisma 5.13.0..."
	@./test_compatibility.sh 14.0 5.13.0


## PostgreSQL 14.0, Prisma 5.14.0, 
results/14.0/5.14.0/result: results
	@echo "Building PostgreSQL 14.0 with Prisma 5.14.0..."
	@./test_compatibility.sh 14.0 5.14.0


## PostgreSQL 14.0, Prisma 5.15.0, 
results/14.0/5.15.0/result: results
	@echo "Building PostgreSQL 14.0 with Prisma 5.15.0..."
	@./test_compatibility.sh 14.0 5.15.0


## PostgreSQL 14.0, Prisma 5.16.0, 
results/14.0/5.16.0/result: results
	@echo "Building PostgreSQL 14.0 with Prisma 5.16.0..."
	@./test_compatibility.sh 14.0 5.16.0


## PostgreSQL 14.0, Prisma 5.17.0, 
results/14.0/5.17.0/result: results
	@echo "Building PostgreSQL 14.0 with Prisma 5.17.0..."
	@./test_compatibility.sh 14.0 5.17.0


## PostgreSQL 14.0, Prisma 5.18.0, 
results/14.0/5.18.0/result: results
	@echo "Building PostgreSQL 14.0 with Prisma 5.18.0..."
	@./test_compatibility.sh 14.0 5.18.0


## PostgreSQL 14.0, Prisma 5.19.0, 
results/14.0/5.19.0/result: results
	@echo "Building PostgreSQL 14.0 with Prisma 5.19.0..."
	@./test_compatibility.sh 14.0 5.19.0


## PostgreSQL 14.0, Prisma 5.20.0, 
results/14.0/5.20.0/result: results
	@echo "Building PostgreSQL 14.0 with Prisma 5.20.0..."
	@./test_compatibility.sh 14.0 5.20.0


## PostgreSQL 14.0, Prisma 5.21.0, 
results/14.0/5.21.0/result: results
	@echo "Building PostgreSQL 14.0 with Prisma 5.21.0..."
	@./test_compatibility.sh 14.0 5.21.0


## PostgreSQL 14.0, Prisma 5.22.0, 
results/14.0/5.22.0/result: results
	@echo "Building PostgreSQL 14.0 with Prisma 5.22.0..."
	@./test_compatibility.sh 14.0 5.22.0


## PostgreSQL 14.0, Prisma 6.0.0, 
results/14.0/6.0.0/result: results
	@echo "Building PostgreSQL 14.0 with Prisma 6.0.0..."
	@./test_compatibility.sh 14.0 6.0.0


## PostgreSQL 14.0, Prisma 6.1.0, 
results/14.0/6.1.0/result: results
	@echo "Building PostgreSQL 14.0 with Prisma 6.1.0..."
	@./test_compatibility.sh 14.0 6.1.0


## PostgreSQL 14.0, Prisma 6.2.0, 
results/14.0/6.2.0/result: results
	@echo "Building PostgreSQL 14.0 with Prisma 6.2.0..."
	@./test_compatibility.sh 14.0 6.2.0


## PostgreSQL 14.0, Prisma 6.2.1, 
results/14.0/6.2.1/result: results
	@echo "Building PostgreSQL 14.0 with Prisma 6.2.1..."
	@./test_compatibility.sh 14.0 6.2.1


## PostgreSQL 14.0, Prisma 6.3.0, 
results/14.0/6.3.0/result: results
	@echo "Building PostgreSQL 14.0 with Prisma 6.3.0..."
	@./test_compatibility.sh 14.0 6.3.0


## PostgreSQL 14.0, Prisma 6.3.1, 
results/14.0/6.3.1/result: results
	@echo "Building PostgreSQL 14.0 with Prisma 6.3.1..."
	@./test_compatibility.sh 14.0 6.3.1


## PostgreSQL 15.0, Prisma 5.9.0, 
results/15.0/5.9.0/result: results
	@echo "Building PostgreSQL 15.0 with Prisma 5.9.0..."
	@./test_compatibility.sh 15.0 5.9.0


## PostgreSQL 15.0, Prisma 5.10.0, 
results/15.0/5.10.0/result: results
	@echo "Building PostgreSQL 15.0 with Prisma 5.10.0..."
	@./test_compatibility.sh 15.0 5.10.0


## PostgreSQL 15.0, Prisma 5.11.0, 
results/15.0/5.11.0/result: results
	@echo "Building PostgreSQL 15.0 with Prisma 5.11.0..."
	@./test_compatibility.sh 15.0 5.11.0


## PostgreSQL 15.0, Prisma 5.12.0, 
results/15.0/5.12.0/result: results
	@echo "Building PostgreSQL 15.0 with Prisma 5.12.0..."
	@./test_compatibility.sh 15.0 5.12.0


## PostgreSQL 15.0, Prisma 5.13.0, 
results/15.0/5.13.0/result: results
	@echo "Building PostgreSQL 15.0 with Prisma 5.13.0..."
	@./test_compatibility.sh 15.0 5.13.0


## PostgreSQL 15.0, Prisma 5.14.0, 
results/15.0/5.14.0/result: results
	@echo "Building PostgreSQL 15.0 with Prisma 5.14.0..."
	@./test_compatibility.sh 15.0 5.14.0


## PostgreSQL 15.0, Prisma 5.15.0, 
results/15.0/5.15.0/result: results
	@echo "Building PostgreSQL 15.0 with Prisma 5.15.0..."
	@./test_compatibility.sh 15.0 5.15.0


## PostgreSQL 15.0, Prisma 5.16.0, 
results/15.0/5.16.0/result: results
	@echo "Building PostgreSQL 15.0 with Prisma 5.16.0..."
	@./test_compatibility.sh 15.0 5.16.0


## PostgreSQL 15.0, Prisma 5.17.0, 
results/15.0/5.17.0/result: results
	@echo "Building PostgreSQL 15.0 with Prisma 5.17.0..."
	@./test_compatibility.sh 15.0 5.17.0


## PostgreSQL 15.0, Prisma 5.18.0, 
results/15.0/5.18.0/result: results
	@echo "Building PostgreSQL 15.0 with Prisma 5.18.0..."
	@./test_compatibility.sh 15.0 5.18.0


## PostgreSQL 15.0, Prisma 5.19.0, 
results/15.0/5.19.0/result: results
	@echo "Building PostgreSQL 15.0 with Prisma 5.19.0..."
	@./test_compatibility.sh 15.0 5.19.0


## PostgreSQL 15.0, Prisma 5.20.0, 
results/15.0/5.20.0/result: results
	@echo "Building PostgreSQL 15.0 with Prisma 5.20.0..."
	@./test_compatibility.sh 15.0 5.20.0


## PostgreSQL 15.0, Prisma 5.21.0, 
results/15.0/5.21.0/result: results
	@echo "Building PostgreSQL 15.0 with Prisma 5.21.0..."
	@./test_compatibility.sh 15.0 5.21.0


## PostgreSQL 15.0, Prisma 5.22.0, 
results/15.0/5.22.0/result: results
	@echo "Building PostgreSQL 15.0 with Prisma 5.22.0..."
	@./test_compatibility.sh 15.0 5.22.0


## PostgreSQL 15.0, Prisma 6.0.0, 
results/15.0/6.0.0/result: results
	@echo "Building PostgreSQL 15.0 with Prisma 6.0.0..."
	@./test_compatibility.sh 15.0 6.0.0


## PostgreSQL 15.0, Prisma 6.1.0, 
results/15.0/6.1.0/result: results
	@echo "Building PostgreSQL 15.0 with Prisma 6.1.0..."
	@./test_compatibility.sh 15.0 6.1.0


## PostgreSQL 15.0, Prisma 6.2.0, 
results/15.0/6.2.0/result: results
	@echo "Building PostgreSQL 15.0 with Prisma 6.2.0..."
	@./test_compatibility.sh 15.0 6.2.0


## PostgreSQL 15.0, Prisma 6.2.1, 
results/15.0/6.2.1/result: results
	@echo "Building PostgreSQL 15.0 with Prisma 6.2.1..."
	@./test_compatibility.sh 15.0 6.2.1


## PostgreSQL 15.0, Prisma 6.3.0, 
results/15.0/6.3.0/result: results
	@echo "Building PostgreSQL 15.0 with Prisma 6.3.0..."
	@./test_compatibility.sh 15.0 6.3.0


## PostgreSQL 15.0, Prisma 6.3.1, 
results/15.0/6.3.1/result: results
	@echo "Building PostgreSQL 15.0 with Prisma 6.3.1..."
	@./test_compatibility.sh 15.0 6.3.1


## PostgreSQL 16.0, Prisma 5.9.0, 
results/16.0/5.9.0/result: results
	@echo "Building PostgreSQL 16.0 with Prisma 5.9.0..."
	@./test_compatibility.sh 16.0 5.9.0


## PostgreSQL 16.0, Prisma 5.10.0, 
results/16.0/5.10.0/result: results
	@echo "Building PostgreSQL 16.0 with Prisma 5.10.0..."
	@./test_compatibility.sh 16.0 5.10.0


## PostgreSQL 16.0, Prisma 5.11.0, 
results/16.0/5.11.0/result: results
	@echo "Building PostgreSQL 16.0 with Prisma 5.11.0..."
	@./test_compatibility.sh 16.0 5.11.0


## PostgreSQL 16.0, Prisma 5.12.0, 
results/16.0/5.12.0/result: results
	@echo "Building PostgreSQL 16.0 with Prisma 5.12.0..."
	@./test_compatibility.sh 16.0 5.12.0


## PostgreSQL 16.0, Prisma 5.13.0, 
results/16.0/5.13.0/result: results
	@echo "Building PostgreSQL 16.0 with Prisma 5.13.0..."
	@./test_compatibility.sh 16.0 5.13.0


## PostgreSQL 16.0, Prisma 5.14.0, 
results/16.0/5.14.0/result: results
	@echo "Building PostgreSQL 16.0 with Prisma 5.14.0..."
	@./test_compatibility.sh 16.0 5.14.0


## PostgreSQL 16.0, Prisma 5.15.0, 
results/16.0/5.15.0/result: results
	@echo "Building PostgreSQL 16.0 with Prisma 5.15.0..."
	@./test_compatibility.sh 16.0 5.15.0


## PostgreSQL 16.0, Prisma 5.16.0, 
results/16.0/5.16.0/result: results
	@echo "Building PostgreSQL 16.0 with Prisma 5.16.0..."
	@./test_compatibility.sh 16.0 5.16.0


## PostgreSQL 16.0, Prisma 5.17.0, 
results/16.0/5.17.0/result: results
	@echo "Building PostgreSQL 16.0 with Prisma 5.17.0..."
	@./test_compatibility.sh 16.0 5.17.0


## PostgreSQL 16.0, Prisma 5.18.0, 
results/16.0/5.18.0/result: results
	@echo "Building PostgreSQL 16.0 with Prisma 5.18.0..."
	@./test_compatibility.sh 16.0 5.18.0


## PostgreSQL 16.0, Prisma 5.19.0, 
results/16.0/5.19.0/result: results
	@echo "Building PostgreSQL 16.0 with Prisma 5.19.0..."
	@./test_compatibility.sh 16.0 5.19.0


## PostgreSQL 16.0, Prisma 5.20.0, 
results/16.0/5.20.0/result: results
	@echo "Building PostgreSQL 16.0 with Prisma 5.20.0..."
	@./test_compatibility.sh 16.0 5.20.0


## PostgreSQL 16.0, Prisma 5.21.0, 
results/16.0/5.21.0/result: results
	@echo "Building PostgreSQL 16.0 with Prisma 5.21.0..."
	@./test_compatibility.sh 16.0 5.21.0


## PostgreSQL 16.0, Prisma 5.22.0, 
results/16.0/5.22.0/result: results
	@echo "Building PostgreSQL 16.0 with Prisma 5.22.0..."
	@./test_compatibility.sh 16.0 5.22.0


## PostgreSQL 16.0, Prisma 6.0.0, 
results/16.0/6.0.0/result: results
	@echo "Building PostgreSQL 16.0 with Prisma 6.0.0..."
	@./test_compatibility.sh 16.0 6.0.0


## PostgreSQL 16.0, Prisma 6.1.0, 
results/16.0/6.1.0/result: results
	@echo "Building PostgreSQL 16.0 with Prisma 6.1.0..."
	@./test_compatibility.sh 16.0 6.1.0


## PostgreSQL 16.0, Prisma 6.2.0, 
results/16.0/6.2.0/result: results
	@echo "Building PostgreSQL 16.0 with Prisma 6.2.0..."
	@./test_compatibility.sh 16.0 6.2.0


## PostgreSQL 16.0, Prisma 6.2.1, 
results/16.0/6.2.1/result: results
	@echo "Building PostgreSQL 16.0 with Prisma 6.2.1..."
	@./test_compatibility.sh 16.0 6.2.1


## PostgreSQL 16.0, Prisma 6.3.0, 
results/16.0/6.3.0/result: results
	@echo "Building PostgreSQL 16.0 with Prisma 6.3.0..."
	@./test_compatibility.sh 16.0 6.3.0


## PostgreSQL 16.0, Prisma 6.3.1, 
results/16.0/6.3.1/result: results
	@echo "Building PostgreSQL 16.0 with Prisma 6.3.1..."
	@./test_compatibility.sh 16.0 6.3.1


## PostgreSQL 17.0, Prisma 5.9.0, 
results/17.0/5.9.0/result: results
	@echo "Building PostgreSQL 17.0 with Prisma 5.9.0..."
	@./test_compatibility.sh 17.0 5.9.0


## PostgreSQL 17.0, Prisma 5.10.0, 
results/17.0/5.10.0/result: results
	@echo "Building PostgreSQL 17.0 with Prisma 5.10.0..."
	@./test_compatibility.sh 17.0 5.10.0


## PostgreSQL 17.0, Prisma 5.11.0, 
results/17.0/5.11.0/result: results
	@echo "Building PostgreSQL 17.0 with Prisma 5.11.0..."
	@./test_compatibility.sh 17.0 5.11.0


## PostgreSQL 17.0, Prisma 5.12.0, 
results/17.0/5.12.0/result: results
	@echo "Building PostgreSQL 17.0 with Prisma 5.12.0..."
	@./test_compatibility.sh 17.0 5.12.0


## PostgreSQL 17.0, Prisma 5.13.0, 
results/17.0/5.13.0/result: results
	@echo "Building PostgreSQL 17.0 with Prisma 5.13.0..."
	@./test_compatibility.sh 17.0 5.13.0


## PostgreSQL 17.0, Prisma 5.14.0, 
results/17.0/5.14.0/result: results
	@echo "Building PostgreSQL 17.0 with Prisma 5.14.0..."
	@./test_compatibility.sh 17.0 5.14.0


## PostgreSQL 17.0, Prisma 5.15.0, 
results/17.0/5.15.0/result: results
	@echo "Building PostgreSQL 17.0 with Prisma 5.15.0..."
	@./test_compatibility.sh 17.0 5.15.0


## PostgreSQL 17.0, Prisma 5.16.0, 
results/17.0/5.16.0/result: results
	@echo "Building PostgreSQL 17.0 with Prisma 5.16.0..."
	@./test_compatibility.sh 17.0 5.16.0


## PostgreSQL 17.0, Prisma 5.17.0, 
results/17.0/5.17.0/result: results
	@echo "Building PostgreSQL 17.0 with Prisma 5.17.0..."
	@./test_compatibility.sh 17.0 5.17.0


## PostgreSQL 17.0, Prisma 5.18.0, 
results/17.0/5.18.0/result: results
	@echo "Building PostgreSQL 17.0 with Prisma 5.18.0..."
	@./test_compatibility.sh 17.0 5.18.0


## PostgreSQL 17.0, Prisma 5.19.0, 
results/17.0/5.19.0/result: results
	@echo "Building PostgreSQL 17.0 with Prisma 5.19.0..."
	@./test_compatibility.sh 17.0 5.19.0


## PostgreSQL 17.0, Prisma 5.20.0, 
results/17.0/5.20.0/result: results
	@echo "Building PostgreSQL 17.0 with Prisma 5.20.0..."
	@./test_compatibility.sh 17.0 5.20.0


## PostgreSQL 17.0, Prisma 5.21.0, 
results/17.0/5.21.0/result: results
	@echo "Building PostgreSQL 17.0 with Prisma 5.21.0..."
	@./test_compatibility.sh 17.0 5.21.0


## PostgreSQL 17.0, Prisma 5.22.0, 
results/17.0/5.22.0/result: results
	@echo "Building PostgreSQL 17.0 with Prisma 5.22.0..."
	@./test_compatibility.sh 17.0 5.22.0


## PostgreSQL 17.0, Prisma 6.0.0, 
results/17.0/6.0.0/result: results
	@echo "Building PostgreSQL 17.0 with Prisma 6.0.0..."
	@./test_compatibility.sh 17.0 6.0.0


## PostgreSQL 17.0, Prisma 6.1.0, 
results/17.0/6.1.0/result: results
	@echo "Building PostgreSQL 17.0 with Prisma 6.1.0..."
	@./test_compatibility.sh 17.0 6.1.0


## PostgreSQL 17.0, Prisma 6.2.0, 
results/17.0/6.2.0/result: results
	@echo "Building PostgreSQL 17.0 with Prisma 6.2.0..."
	@./test_compatibility.sh 17.0 6.2.0


## PostgreSQL 17.0, Prisma 6.2.1, 
results/17.0/6.2.1/result: results
	@echo "Building PostgreSQL 17.0 with Prisma 6.2.1..."
	@./test_compatibility.sh 17.0 6.2.1


## PostgreSQL 17.0, Prisma 6.3.0, 
results/17.0/6.3.0/result: results
	@echo "Building PostgreSQL 17.0 with Prisma 6.3.0..."
	@./test_compatibility.sh 17.0 6.3.0


## PostgreSQL 17.0, Prisma 6.3.1, 
results/17.0/6.3.1/result: results
	@echo "Building PostgreSQL 17.0 with Prisma 6.3.1..."
	@./test_compatibility.sh 17.0 6.3.1


.PHONY: all_versions
all_versions: results/10.0/5.9.0/result results/10.0/5.10.0/result results/10.0/5.11.0/result results/10.0/5.12.0/result results/10.0/5.13.0/result results/10.0/5.14.0/result results/10.0/5.15.0/result results/10.0/5.16.0/result results/10.0/5.17.0/result results/10.0/5.18.0/result results/10.0/5.19.0/result results/10.0/5.20.0/result results/10.0/5.21.0/result results/10.0/5.22.0/result results/10.0/6.0.0/result results/10.0/6.1.0/result results/10.0/6.2.0/result results/10.0/6.2.1/result results/10.0/6.3.0/result results/10.0/6.3.1/result results/11.0/5.9.0/result results/11.0/5.10.0/result results/11.0/5.11.0/result results/11.0/5.12.0/result results/11.0/5.13.0/result results/11.0/5.14.0/result results/11.0/5.15.0/result results/11.0/5.16.0/result results/11.0/5.17.0/result results/11.0/5.18.0/result results/11.0/5.19.0/result results/11.0/5.20.0/result results/11.0/5.21.0/result results/11.0/5.22.0/result results/11.0/6.0.0/result results/11.0/6.1.0/result results/11.0/6.2.0/result results/11.0/6.2.1/result results/11.0/6.3.0/result results/11.0/6.3.1/result results/12.0/5.9.0/result results/12.0/5.10.0/result results/12.0/5.11.0/result results/12.0/5.12.0/result results/12.0/5.13.0/result results/12.0/5.14.0/result results/12.0/5.15.0/result results/12.0/5.16.0/result results/12.0/5.17.0/result results/12.0/5.18.0/result results/12.0/5.19.0/result results/12.0/5.20.0/result results/12.0/5.21.0/result results/12.0/5.22.0/result results/12.0/6.0.0/result results/12.0/6.1.0/result results/12.0/6.2.0/result results/12.0/6.2.1/result results/12.0/6.3.0/result results/12.0/6.3.1/result results/13.0/5.9.0/result results/13.0/5.10.0/result results/13.0/5.11.0/result results/13.0/5.12.0/result results/13.0/5.13.0/result results/13.0/5.14.0/result results/13.0/5.15.0/result results/13.0/5.16.0/result results/13.0/5.17.0/result results/13.0/5.18.0/result results/13.0/5.19.0/result results/13.0/5.20.0/result results/13.0/5.21.0/result results/13.0/5.22.0/result results/13.0/6.0.0/result results/13.0/6.1.0/result results/13.0/6.2.0/result results/13.0/6.2.1/result results/13.0/6.3.0/result results/13.0/6.3.1/result results/14.0/5.9.0/result results/14.0/5.10.0/result results/14.0/5.11.0/result results/14.0/5.12.0/result results/14.0/5.13.0/result results/14.0/5.14.0/result results/14.0/5.15.0/result results/14.0/5.16.0/result results/14.0/5.17.0/result results/14.0/5.18.0/result results/14.0/5.19.0/result results/14.0/5.20.0/result results/14.0/5.21.0/result results/14.0/5.22.0/result results/14.0/6.0.0/result results/14.0/6.1.0/result results/14.0/6.2.0/result results/14.0/6.2.1/result results/14.0/6.3.0/result results/14.0/6.3.1/result results/15.0/5.9.0/result results/15.0/5.10.0/result results/15.0/5.11.0/result results/15.0/5.12.0/result results/15.0/5.13.0/result results/15.0/5.14.0/result results/15.0/5.15.0/result results/15.0/5.16.0/result results/15.0/5.17.0/result results/15.0/5.18.0/result results/15.0/5.19.0/result results/15.0/5.20.0/result results/15.0/5.21.0/result results/15.0/5.22.0/result results/15.0/6.0.0/result results/15.0/6.1.0/result results/15.0/6.2.0/result results/15.0/6.2.1/result results/15.0/6.3.0/result results/15.0/6.3.1/result results/16.0/5.9.0/result results/16.0/5.10.0/result results/16.0/5.11.0/result results/16.0/5.12.0/result results/16.0/5.13.0/result results/16.0/5.14.0/result results/16.0/5.15.0/result results/16.0/5.16.0/result results/16.0/5.17.0/result results/16.0/5.18.0/result results/16.0/5.19.0/result results/16.0/5.20.0/result results/16.0/5.21.0/result results/16.0/5.22.0/result results/16.0/6.0.0/result results/16.0/6.1.0/result results/16.0/6.2.0/result results/16.0/6.2.1/result results/16.0/6.3.0/result results/16.0/6.3.1/result results/17.0/5.9.0/result results/17.0/5.10.0/result results/17.0/5.11.0/result results/17.0/5.12.0/result results/17.0/5.13.0/result results/17.0/5.14.0/result results/17.0/5.15.0/result results/17.0/5.16.0/result results/17.0/5.17.0/result results/17.0/5.18.0/result results/17.0/5.19.0/result results/17.0/5.20.0/result results/17.0/5.21.0/result results/17.0/5.22.0/result results/17.0/6.0.0/result results/17.0/6.1.0/result results/17.0/6.2.0/result results/17.0/6.2.1/result results/17.0/6.3.0/result results/17.0/6.3.1/result


