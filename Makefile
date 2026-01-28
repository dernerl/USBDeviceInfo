.PHONY: build pkg clean

build:
	xcodebuild -project USBDeviceInfo.xcodeproj -scheme USBDeviceInfo -configuration Release build

pkg:
	./scripts/build-pkg.sh

clean:
	rm -rf build DerivedData
	xcodebuild clean
