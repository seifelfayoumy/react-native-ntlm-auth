
Pod::Spec.new do |s|
  s.name         = "RNNtlm"
  s.version      = "1.0.0"
  s.summary      = "RNNtlm"
  s.description  = <<-DESC
                  RNNtlm
                   DESC
  s.homepage     = "https://github.com/Neurony/react-native-ntlm-auth.git"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "andreiradoi" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/Neurony/react-native-ntlm-auth.git", :tag => "master" }
  s.source_files  = "RNNtlm/**/*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  #s.dependency "others"

end

  
