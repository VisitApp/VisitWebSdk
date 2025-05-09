#
# Be sure to run `pod lib lint VisitWebSdk.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'VisitWebSdk'
  s.version          = '0.1.2'
  s.summary          = 'An SDK to inject the health kit data in Visit PWA'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  An iOS SDK to inject the health kit data in Visit PWA
                       DESC

  s.homepage         = 'https://github.com/VisitApp/VisitWebSdk'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '81799742' => 'yash-vardhan@hotmail.com' }
  s.source           = { :git => 'https://github.com/VisitApp/VisitWebSdk.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

  s.source_files = 'VisitWebSdk/Classes/**/*'
  s.public_header_files = 'VisitWebSdk/Classes/**/*.h'
  
  s.resource_bundles = {
    'VisitWebSdk' => ['VisitWebSdk/Assets/*.png','VisitWebSdk/Assets/*.storyboard']
  }
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

end
