.PHONY: init run scan bridge buildx buildx-init buildx-run buildx-scan buildx-bridge

init:
	docker compose --env-file common.env -f init/docker-compose.yml -p builderism-init up

run:
	docker compose --env-file common.env -f run/docker-compose.yml -p builderism-run up

scan:
	docker compose --env-file common.env -f scan/docker-compose.yml -p builderism-scan up

bridge:
	docker compose --env-file common.env -f bridge/docker-compose.yml -p builderism-bridge up

# buildx command
buildx: buildx-init buildx-run buildx-scan buildx-bridge

buildx-init:
	docker buildx build \
	--platform linux/amd64,linux/arm64 \
	-t dreamcacao/builderism_init:1.9.1 \
	-t dreamcacao/builderism_init:latest \
	--push ./init

buildx-run:
	docker buildx build \
	--platform linux/amd64,linux/arm64 \
	-t dreamcacao/builderism_run:1.9.4 \
	-t dreamcacao/builderism_run:latest \
	--push ./run

buildx-scan:
	docker buildx build \
	--platform linux/amd64,linux/arm64 \
	-t dreamcacao/builderism_scan:0.0.0 \
	-t dreamcacao/builderism_scan:latest \
	--push ./scan

buildx-bridge:
	docker buildx build \
	--platform linux/amd64,linux/arm64 \
	-t dreamcacao/builderism_bridge:0.0.0 \
	-t dreamcacao/builderism_bridge:latest \
	--push ./bridge
