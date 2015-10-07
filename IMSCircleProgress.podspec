Pod::Spec.new do |s|

  s.name         = "IMSCircleProgress"
  s.version      = "0.0.1"
  s.platform     = :ios, "8" 
  s.summary      = "A short description of IMSCircleProgress."

  s.homepage     = "https://github.com/InMotionSoft/IMSCircleProgresss"
  s.license      = "MIT"

  s.author       = { "InMotion Soft" => "hello@inmotionsoft.com" }
  s.source       = { :git => "https://github.com/InMotionSoft/IMSCircleProgress.git", :tag => s.version.to_s }

  s.source_files  = 'CircleProgress/Code/**/*.{swift}'
  s.requires_arc = true
  
end
