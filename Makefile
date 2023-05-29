VERSION := $(shell grep -o 'const.*=*' version.go  | cut -d '"' -f2)
MACOS := gotest-report-darwin-v$(VERSION)
LINUX := gotest-report-linux-v$(VERSION)
WINDOWS := gotest-report-windows-v$(VERSION)

LIN_DIR := release_builds/linux-amd64/
MAC_DIR := release_builds/darwin-amd64/
WIN_DIR := release_builds/windows-amd64/

genbuild: gencode
	go build

gencode:
	(cd embed_assets/;set -e;go build;./embed_assets)

buildall: genbuild
	echo "Building..."

	mkdir -p $(LIN_DIR)
	mkdir -p $(MAC_DIR)
	mkdir -p $(WIN_DIR)

	go mod verify

	echo "Linux 64bit"
	GOOS=linux GOARCH=amd64 go build -o release_builds/linux-amd64/
	(cd $(LIN_DIR); shasum -a 256 gotest-report |  cut -d ' ' -f 1 > $(LINUX).sha256)
	(cd $(LIN_DIR); tar -czf $(LINUX).tgz gotest-report $(LINUX).sha256)

	echo "Darwin (MacOS) 64bit"
	GOOS=darwin GOARCH=amd64 go build -o release_builds/darwin-amd64/
	(cd $(MAC_DIR); shasum -a 256 gotest-report |  cut -d ' ' -f 1 > $(MACOS).sha256)
	(cd $(MAC_DIR); tar -czf $(MACOS).tgz gotest-report $(MACOS).sha256)

	echo "Windows 64bit"
	GOOS=windows GOARCH=amd64 go build -o release_builds/windows-amd64/
	(cd $(WIN_DIR); shasum -a 256 gotest-report.exe |  cut -d ' ' -f 1 > $(WINDOWS).sha256)
	(cd $(WIN_DIR); zip -r $(WINDOWS).zip gotest-report.exe $(WINDOWS).sha256)

	echo "...Done!"

dockertest: genbuild
	docker build . -t gotest-report-test-runner:$(VERSION)
