rm -rf build

#For iOS Device
xcodebuild clean archive \
-workspace "SVGAPlayer.xcworkspace" \
-scheme SVGA \
-sdk iphoneos \
-configuration Release \
-destination 'generic/platform=iOS' \
-archivePath './build/SVGAPlayer.framework-iphoneos.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES 


xcodebuild clean archive \
-workspace "SVGAPlayer.xcworkspace" \
-scheme SVGA \
-sdk iphoneos \
-configuration Release \
-destination 'generic/platform=iOS Simulator' \
-archivePath './build/SVGAPlayer.framework-iphonesimulator.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES 


xcodebuild -create-xcframework \
-framework './build/SVGAPlayer.framework-iphonesimulator.xcarchive/Products/Library/Frameworks/SVGA.framework' \
-framework './build/SVGAPlayer.framework-iphoneos.xcarchive/Products/Library/Frameworks/SVGA.framework' \
-output './build/SVGAPlayer.xcframework'
