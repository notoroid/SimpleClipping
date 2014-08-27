Pod::Spec.new do |s|
  s.name         = "SimpleClipping"
  s.version      = "0.0.1"
  s.summary      = "SimpleClipping create a path based on the drag behavior of the user."

  s.description  = <<-DESC
                   SimpleClipping are suitable to create a scrap to yourself. impleClipping create a path based on the drag behavior of the user. It also has a utility to create to create a mask of View on the screen using the path that you have created, the clipPath applying the mask.
                   DESC

  s.homepage     = "https://github.com/notoroid/SimpleClipping"
  s.screenshots  = "https://raw.githubusercontent.com/notoroid/SimpleClipping/master/Screenshots/ss01.png"


  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "notoroid" => "noto@irimasu.com" }
  s.social_media_url   = "http://twitter.com/notoroid"
  s.platform     = :ios, "7.0"
  
  s.source       = { :git => "https://github.com/notoroid/SimpleClipping.git", :tag => "v0.0.1" }

  s.source_files  = "Classes", "Lib/**/*.{h,m}"
  s.public_header_files = "Lib/**/*.h"
  s.requires_arc = true

end
