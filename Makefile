SOURCES := ShowMyIP ShowMyIPTests

.PHONY: lint format test hooks

lint:
	swiftlint lint --strict --quiet
	xcrun swift-format lint --strict --recursive $(SOURCES)

format:
	xcrun swift-format format --in-place --recursive $(SOURCES)
	swiftlint lint --fix --quiet

test:
	xcodebuild test -project ShowMyIP.xcodeproj -scheme ShowMyIP -destination 'platform=macOS,arch=arm64' -quiet

hooks:
	git config core.hooksPath scripts/git-hooks
