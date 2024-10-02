default: build sign compress

build:
	swift build --configuration release --arch arm64 --arch x86_64
	mv .build/apple/Products/Release/pbcopy-chromium .

sign:
	codesign --sign "${CODESIGN_IDENTITY}" --options runtime  --timestamp pbcopy-chromium

compress:
	gzip -f pbcopy-chromium
