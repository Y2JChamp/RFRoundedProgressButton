Pod::Spec.new do |spec|
  spec.name          = "RFRoundedProgressButton"
  spec.version       = "0.0.1"
  spec.summary       = "A customizable rounded corner progress button for iOS written in Swift 5.0"
  spec.homepage      = "https://github.com/Y2JChamp/RFRoundedProgressButton"
  spec.license          = { :type => "MIT" }
  spec.author        = { "Raffaele Forgione" => "r.forgione@wakala.it" }
  spec.source        = { :git => "https://github.com/Y2JChamp/RFRoundedProgressButton.git", :tag => "#{spec.version}" }
  spec.source_files  = "Source/**/*.swift"
  spec.ios.deployment_target = "9.0"
  spec.ios.frameworks = "UIKit", "Foundation"
  spec.swift_version = "5.0"
end
