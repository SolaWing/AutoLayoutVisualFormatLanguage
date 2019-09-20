#
# Be sure to run `pod lib lint MyVFL.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'VFL'
  s.version          = '3.0.0'
  s.summary          = 'Powerful and Easy to use AutoLayout Visual Format Language'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Powerful and Easy to use AutoLayout Visual Format Language. it is:

    * Compatible with Apple's AutoLayout Visual Format Language.
    * Super easy to use.
    * Can create all needed constraints in one API call.
    * Support create each view's constraints individually.
    * Syntax is readable and intuitive.
    * Support using array index, not limited to dictionary.
    * Swift support string interpolation in format string.
                       DESC

  s.homepage         = 'https://github.com/SolaWing/AutoLayoutVisualFormatLanguage'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'SolaWing' => '316786359@qq.com' }
  s.source           = { :git => 'https://github.com/SolaWing/AutoLayoutVisualFormatLanguage.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '6.0'
  s.swift_versions = ['5.0']

  s.default_subspecs = 'Swift'
  s.module_name = 'VFL'
  s.subspec 'Core' do |ss|
    ss.source_files = 'AutoLayoutVisualFormat/*.{h,m}'
    ss.public_header_files = 'AutoLayoutVisualFormat/*.h'
  end
  s.subspec 'Swift' do |ss|
    ss.ios.deployment_target = '8.0'
    ss.dependency 'VFL/Core'
    ss.source_files = 'VFL/*.swift'
  end
end
