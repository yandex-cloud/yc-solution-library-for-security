all: clean dependencies package

clean:
	rm -rf dist/

dirs:
	mkdir -p dist/

dependencies: dirs
	docker run --rm \
		-v $(shell pwd)/dist:/dist -v $(shell pwd):/app \
		-w /app \
		python:3.7-stretch \
		pip3 install -r /app/requirements.txt --target /dist/

install-code: dirs
	cp main.py dist/main.py
	cp s3.py   dist/s3.py

package: dirs install-code
	rm -f dist.zip
	cd dist && zip --exclude '*.pyc' -r ../dist.zip ./*

.PHONY: clean dirs dependencies install-code package all
