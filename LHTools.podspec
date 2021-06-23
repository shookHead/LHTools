#
# Be sure to run `pod lib lint LHTools.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LHTools'
  s.version          = '0.0.1'
  s.summary          = 'A base tool for swift develop'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/shookHead/LHTools'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'shookHead' => 'lin.hai2020@foxmail.com' }
  s.source           = { :git => 'https://github.com/shookHead/LHTools.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.swift_version          = '5.0'
  
  s.source_files = 'LHTools/Classes/**/*'
  
   s.resource_bundles = {
#       'LHTools' => ['LHTools/Assets/*.xcassets','LHTools/Assets/*.sqlite']
       'LHTools' => ['LHTools/Assets/**/*']
   }
#   s.resources    = "LHTools/Assets/*.sqlite"
   s.static_framework = true
  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'UIKit', "Foundation"#, 'MapKit'
   s.dependency 'Alamofire'
   s.dependency 'Kingfisher'
   s.dependency 'HandyJSON'
   s.dependency 'MJRefresh'
   s.dependency 'SwiftyUserDefaults'
   s.dependency 'IQKeyboardManagerSwift'
   s.dependency 'SQLite.swift'
   s.dependency 'Hero'

   s.dependency 'NVActivityIndicatorView'
   s.dependency 'CLImagePickerTool'
   s.dependency 'JXPhotoBrowser'
   s.dependency 'SnapKit'
#
#   s.dependency 'Charts'
#   s.dependency 'JXSegmentedView'
#   s.dependency 'JXPagingView/Paging'
#   s.dependency 'AttributedString'
#   s.dependency 'LTMorphingLabel'
#   s.dependency 'CollectionKit'
#   s.dependency 'RxSwift',    '~> 4.0'
#   s.dependency 'RxCocoa',    '~> 4.0'
#   s.dependency 'RxDataSources', '~> 3.0'
   
end
