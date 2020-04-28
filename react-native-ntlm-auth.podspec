require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name           = 'react-native-ntlm-auth'
  s.version        = package['version']
  s.summary        = package['description']
  s.description    = package['description']
  s.license        = package['license']
  s.author         = package['author']
  s.homepage       = package['homepage']
  s.platform       = :ios, '10.0'
  s.source         = { git: 'https://github.com/Neurony/react-native-ntlm-auth.git' }
  s.source_files   = '**/*.{h,m}'
  s.preserve_paths = '**/*.{h,m}'
  s.requires_arc   = true

  s.dependency "React"
  s.dependency 'AFNetworking'
end

