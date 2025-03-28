#
# Be sure to run `pod lib lint LHTools.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  # 项目名
  s.name             = 'LHTools'
  # 版本号
  s.version          = '0.0.4'
  # 简单描述
  s.summary          = 'A base tool for swift develop'
  # 详细介绍
  s.description      = '这是Swift版本的基础类'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  # 项目的gitub地址，只支持HTTP和HTTPS地址，不支持ssh的地址
  s.homepage         = 'https://github.com/shookHead/LHTools'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  # listen文件的类型
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  # 作者和邮箱
  s.author           = { 'shookHead' => 'lin.hai2020@foxmail.com' }
  # git仓库的https地址
  s.source           = { :git => 'https://github.com/shookHead/LHTools.git', :tag => s.version.to_s }
  # 多媒体介绍地址
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  # 最低要求的系统版本
  s.ios.deployment_target = '12.0'
  # s.tvos.deployment_target = "12.0"
  # s.osx.deployment_target = "10.14"
  # s.watchos.deployment_target = "2.0"
  # Wait for CocoaPods 1.13.0 (visionOS support)
  # s.visionos.deployment_target = "1.0"
  # swift 支持的版本
  s.swift_version          = '5.0'
  
#  s.source_files = 'LHTools/Classes/**/*.swift'
  s.source_files  = "LHTools", "Classes/**/*.swift"
  
#   s.resource_bundles = {
##       'LHTools' => ['LHTools/Assets/*.xcassets','LHTools/Assets/*.sqlite']
#       'LHTools' => ['LHTools/Assets/**/*']
#   }
   s.resources    = "LHTools/Classes/resource/**/*"
   s.static_framework = true
   
   
   #Source
   s.subspec 'Source' do |ss|
       ss.source_files = 'LHTools/Classes/Source/**/*.swift'
   end
  #Global
  s.subspec 'Global' do |ss|
      ss.source_files = 'LHTools/Classes/GlobalImport.swift','LHTools/Classes/BMConst.swift','LHTools/Classes/LHTools.swift','LHTools/Classes/LHInternationalization.swift'
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
              ssss.source_files = 'LHTools/Classes/自定义视图/选择器/CustomPicker/{BM,LH,MY}{City,Base,Date,Single}Picker.swift'
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
      ss.subspec 'VideoPlayer' do |sss|
          sss.source_files = 'LHTools/Classes/工具类/VideoPlayer/**/*.swift'
      end
      ss.subspec 'AuthorizationManager' do |sss|
          sss.source_files = 'LHTools/Classes/工具类/AuthorizationManager/**/*.swift'
      end
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
  #其他第三方
  s.subspec 'Other' do |ss|
      ss.subspec 'Distrib' do |sss|
          sss.source_files = 'LHTools/Classes/Other/Distrib/*.swift'
      end
  end
  
    s.public_header_files = 'Pod/Classes/**/*.h'
    s.frameworks = 'UIKit', "Foundation"#, 'MapKit'
    s.dependency 'Alamofire'
    s.dependency 'Kingfisher'
   # s.dependency 'HandyJSON'
    s.dependency 'MJRefresh'
    s.dependency 'MBProgressHUD'
    s.dependency 'SwiftyUserDefaults'
    s.dependency 'IQKeyboardManagerSwift'
    s.dependency 'SQLite.swift'
    s.dependency 'Hero'

    s.dependency 'NVActivityIndicatorView'
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
