.PHONY: build run clean

build:
	swift build -c release
	mkdir -p ColimaGUI.app/Contents/MacOS
	cp .build/release/ColimaGUI ColimaGUI.app/Contents/MacOS/

run:
	swift run

clean:
	rm -rf .build
	rm -f ColimaGUI
