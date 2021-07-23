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

  s.ios.deployment_target = '10.0'
  s.swift_version          = '5.0'
  
#  s.source_files = 'LHTools/Classes/**/*.swift'
  s.source_files  = "LHTools", "Classes/**/*.swift"
  
#   s.resource_bundles = {
##       'LHTools' => ['LHTools/Assets/*.xcassets','LHTools/Assets/*.sqlite']
#       'LHTools' => ['LHTools/Assets/**/*']
#   }
   s.resources    = "LHTools/Classes/resource/**/*"
   s.static_framework = true
   
   
  #Global
  s.subspec 'Global' do |ss|
      ss.source_files = 'LHTools/Classes/GlobalImport.swift','LHTools/Classes/BMConst.swift','LHTools/Classes/LHTools.swift'
  end
  #View
  s.subspec 'View' do |ss|
      ss.source_files = 'LHTools/Classes/View/**/*.swift'
  end
  #自定义视图
  s.subspec '自定义视图' do |ss|
      ss.subspec '提示框' do |sss|
          sss.source_files = 'LHTools/Classes/自定义视图/提示框/**/*.swift'
      end
      ss.subspec 'PopView' do |sss|
          sss.source_files = 'LHTools/Classes/自定义视图/PopView/**/*.swift'
      end
      ss.subspec '选择器' do |sss|
          sss.source_files = 'LHTools/Classes/自定义视图/选择器/BMPicker.swift','LHTools/Classes/自定义视图/选择器/BMSelectView.swift'
          sss.subspec 'CustomPicker' do |ssss|
              ssss.source_files = 'LHTools/Classes/自定义视图/选择器/CustomPicker/BM{City,Base,Date,Single}Picker.swift'
              ssss.subspec 'CityDataBase' do |sssss|
                  sssss.source_files = 'LHTools/Classes/自定义视图/选择器/CustomPicker/CityDataBase/CityDBManager.swift'
              end
          end
      end
      ss.subspec '图片上传' do |sss|
          sss.subspec '快速上传' do |ssss|
              ssss.source_files = 'LHTools/Classes/自定义视图/图片上传/快速上传/**/*.swift'
          end
          sss.subspec '多图选择控件' do |ssss|
              ssss.source_files = 'LHTools/Classes/自定义视图/图片上传/多图选择控件/**/*.swift'
          end
      end
      ss.subspec '加载等待' do |sss|
          sss.source_files = 'LHTools/Classes/自定义视图/加载等待/**/*.swift'
      end
      ss.subspec '点赞动画' do |sss|
          sss.source_files = 'LHTools/Classes/自定义视图/点赞动画/**/*.swift'
      end
      ss.subspec '时间段选择器' do |sss|
          sss.source_files = 'LHTools/Classes/自定义视图/时间段选择器/**/*.swift'
      end
      ss.subspec '测试服切换工具' do |sss|
          sss.source_files = 'LHTools/Classes/自定义视图/测试服切换工具/**/*.swift'
      end
      ss.subspec '轮播' do |sss|
          sss.source_files = 'LHTools/Classes/自定义视图/轮播/**/*.swift'
      end
      ss.subspec '图片缩放预览' do |sss|
          sss.source_files = 'LHTools/Classes/自定义视图/图片缩放预览/**/*.swift'
      end
      ss.subspec 'PhotoBrowser' do |sss|
          sss.source_files = 'LHTools/Classes/自定义视图/PhotoBrowser/**/*.swift'
      end
  end
  #扩展
  s.subspec '扩展' do |ss|
      ss.subspec 'Xib' do |sss|
          sss.source_files = 'LHTools/Classes/扩展/Xib/**/*.swift'
      end
      ss.subspec 'Color' do |sss|
          sss.source_files = 'LHTools/Classes/扩展/Color/**/*.swift'
      end
      ss.subspec 'SnapKit' do |sss|
          sss.source_files = 'LHTools/Classes/扩展/SnapKit/**/*.swift'
      end
      ss.subspec 'Date' do |sss|
          sss.source_files = 'LHTools/Classes/扩展/Date/**/*.swift'
      end
      ss.subspec 'Number' do |sss|
          sss.source_files = 'LHTools/Classes/扩展/Number/**/*.swift'
      end
      ss.subspec 'View' do |sss|
          sss.source_files = 'LHTools/Classes/扩展/View/**/*.swift'
      end
      ss.subspec 'Kingfisher' do |sss|
          sss.source_files = 'LHTools/Classes/扩展/Kingfisher/**/*.swift'
      end
      ss.subspec 'String' do |sss|
          sss.source_files = 'LHTools/Classes/扩展/String/**/*.swift'
      end
      ss.subspec 'Nav' do |sss|
          sss.source_files = 'LHTools/Classes/扩展/Nav/**/*.swift'
      end
      ss.subspec 'Set' do |sss|
          sss.source_files = 'LHTools/Classes/扩展/Set/**/*.swift'
      end
      ss.subspec 'SegmentedControl' do |sss|
          sss.source_files = 'LHTools/Classes/扩展/SegmentedControl/**/*.swift'
      end
  end
  #基类
  s.subspec '基类' do |ss|
      ss.source_files = 'LHTools/Classes/基类/**/*.swift'
  end
  #工具类
  s.subspec '工具类' do |ss|
      ss.subspec 'Utils' do |sss|
          sss.source_files = 'LHTools/Classes/工具类/Utils/**/*.swift'
      end
      ss.subspec '获取文件' do |sss|
          sss.source_files = 'LHTools/Classes/工具类/获取文件/**/*.swift'
      end
      ss.subspec '请求' do |sss|
          sss.source_files = 'LHTools/Classes/工具类/请求/**/*.swift'
      end
      ss.subspec '约束' do |sss|
          sss.source_files = 'LHTools/Classes/工具类/约束/**/*.swift'
      end
      ss.subspec '缓存' do |sss|
          sss.source_files = 'LHTools/Classes/工具类/缓存/**/*.swift'
      end
      ss.subspec '二维码' do |sss|
          sss.source_files = 'LHTools/Classes/工具类/二维码/**/*.swift'
      end
  end
  
  # s.public_header_files = 'Pod/Classes/**/*.h'
    s.frameworks = 'UIKit', "Foundation"#, 'MapKit'
    s.dependency 'Alamofire'
    s.dependency 'Kingfisher'
    s.dependency 'HandyJSON', '5.0.3-beta'
    s.dependency 'MJRefresh'
    s.dependency 'SwiftyUserDefaults'
    s.dependency 'IQKeyboardManagerSwift'
    s.dependency 'SQLite.swift'
    s.dependency 'Hero'

    s.dependency 'NVActivityIndicatorView'
#    s.dependency 'CLImagePickerTool'
    s.dependency 'ZLPhotoBrowser'
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
