Pod::Spec.new do |s|

  s.name         = "IMSCircleProgress"
  s.version      = "0.0.1"
  s.summary      = "A short description of IMSCircleProgress."

  s.homepage     = "https://github.com/InMotionSoft/IMSCircleProgresss"
  s.license      = "MIT"

  s.author       = { "Denis Romashov" => "denisromashow@gmail.com" }
  s.source       = { :git => "https://github.com/InMotionSoft/IMSCircleProgress.git", :tag => "0.0.1" }

  s.source_files  = 'IMSCircleProgresss/Code/**/*.{swift}'
  s.requires_arc = true
  
end
