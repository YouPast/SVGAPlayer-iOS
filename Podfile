platform :ios, '12.0'

target 'SVGAPlayerDemo' do
    pod 'SSZipArchive', '~> 2.1.4'
    pod 'Protobuf', '~> 3.4'
end

target 'SVGAPlayer' do
    pod 'SSZipArchive', '~> 2.1.4'
    pod 'Protobuf', '~> 3.4'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "12.0"
      end
    end
  end
