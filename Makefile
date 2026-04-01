.PHONY: build run clean

build:
	swift build -c release

run:
	swift run

clean:
	rm -rf .build
	rm -f ColimaGUI
