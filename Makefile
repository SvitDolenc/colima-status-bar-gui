.PHONY: build run clean

build:
	swift build -c release
	mkdir -p ColimaGUI.app/Contents/MacOS
	cp .build/release/ColimaGUI ColimaGUI.app/Contents/MacOS/
	cp Info.plist ColimaGUI.app/Contents/Info.plist

run:
	swift run

clean:
	rm -rf .build
	rm -f ColimaGUI
