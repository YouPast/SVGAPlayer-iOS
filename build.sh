rm -rf build

#For iOS Device
xcodebuild clean archive \
-workspace "SVGAPlayer.xcworkspace" \
-scheme SVGAPlayer \
-sdk iphoneos \
-configuration Release \
-destination 'generic/platform=iOS' \
-archivePath './build/SVGAPlayer.framework-iphoneos.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES 


xcodebuild clean archive \
-workspace "SVGAPlayer.xcworkspace" \
-scheme SVGAPlayer \
-sdk iphoneos \
-configuration Release \
-destination 'generic/platform=iOS Simulator' \
-archivePath './build/SVGAPlayer.framework-iphonesimulator.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES 


xcodebuild -create-xcframework \
-framework './build/SVGAPlayer.framework-iphonesimulator.xcarchive/Products/Library/Frameworks/SVGAPlayer.framework' \
-framework './build/SVGAPlayer.framework-iphoneos.xcarchive/Products/Library/Frameworks/SVGAPlayer.framework' \
-output './build/SVGAPlayer.xcframework'
