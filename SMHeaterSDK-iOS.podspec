Pod::Spec.new do |spec|
  spec.name         = "SMHeaterSDK-iOS"
  spec.version      = "0.0.1"
  spec.summary      = "A iOS SDK and Demo to Control SIMO Heater via BLE."
  spec.homepage     = "https://github.com/Shenzhen-Simo-Technology-co-LTD/SMHeaterSDK-iOS"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  spec.license      = "MIT"
  spec.author             = { "GrayLand" => "441726442@qq.com" }
  spec.platform     = :ios, "10.0"
  spec.source       = { :git => "https://github.com/Shenzhen-Simo-Technology-co-LTD/SMHeaterSDK-iOS.git", :tag => "#{spec.version}" }
  spec.source_files  = "SMHeaterDemo/SMHeaterSDK/SMHeaterSDK.framework/Headers/*.{h}"
  spec.vendored_frameworks = 'SMHeaterDemo/SMHeaterSDK/SMHeaterSDK.framework'
  spec.public_header_files = 'SMHeaterDemo/SMHeaterSDK/SMHeaterSDK.framework/Headers/*.h'

  # spec.frameworks = "SomeFramework", "AnotherFramework"
  spec.requires_arc = true
  # spec.dependency "JSONKit", "~> 1.4"
end
