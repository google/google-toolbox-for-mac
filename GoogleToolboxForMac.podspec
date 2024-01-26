Pod::Spec.new do |s|
  s.name             = 'GoogleToolboxForMac'
  s.version          = '4.2.1'
  s.author           = 'Google Inc.'
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.homepage         = 'https://github.com/google/google-toolbox-for-mac'
  s.source           = { :git => 'https://github.com/google/google-toolbox-for-mac.git',
                         :tag => "v#{s.version}" }
  s.summary          = 'Google utilities for iOS and OSX development.'
  s.description      = <<-DESC
      A collection of source from different Google projects that may be of use
      to developers working on iOS or OS X projects.
                       DESC

  # Ensure developers won't hit CocoaPods/CocoaPods#11402 with the resource
  # bundle for the privacy manifest.
  s.cocoapods_version = '>= 1.12.0'

  osx_deployment_target = '10.12'
  ios_deployment_target = '10.0'
  tvos_deployment_target = '10.0'

  s.osx.deployment_target = osx_deployment_target
  s.ios.deployment_target = ios_deployment_target
  s.tvos.deployment_target = tvos_deployment_target

  s.requires_arc = false

  # Generally developers should use specific subspecs themselves to get the things they
  # want; but set the default to ensure the testing only code doesn't bundle
  # into a shipping app. This has come up a few times issues 130, 138. The current
  # list here is everything that doesn't have a platform requirement and isn't
  # testing only.
  s.default_subspecs = 'Defines', 'Core', 'GeometryUtils', 'KVO', 'Logger',
                       'StringEncoding', 'NSData+zlib',
                       'NSFileHandle+UniqueName', 'NSString+HTML',
                       'NSString+XML', 'NSThread+Blocks'

  s.subspec 'Defines' do |sp|
    sp.public_header_files = 'GTMDefines.h'
    sp.source_files = 'GTMDefines.h'
    sp.resource_bundle = {
      "GoogleToolboxForMac_Privacy" => "Resources/Base/PrivacyInfo.xcprivacy"
    }
  end

  s.subspec 'Core' do |sp|
    sp.source_files =
        'DebugUtils/GTMTypeCasting.h',
        'Foundation/GTMLocalizedString.h',
        'Foundation/GTMLogger.h'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'DebugUtils' do |sp|
    sp.source_files =
        'DebugUtils/GTMDebugSelectorValidation.{h,m}',
        'DebugUtils/GTMDebugThreadValidation.h',
        'DebugUtils/GTMMethodCheck.h'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'GeometryUtils' do |sp|
    sp.source_files = 'Foundation/GTMGeometryUtils.{h,m}'
    sp.frameworks = 'CoreGraphics'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'KVO' do |sp|
    sp.source_files =
        'Foundation/GTMNSObject+KeyValueObserving.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Core', "#{s.version}"
    sp.dependency 'GoogleToolboxForMac/DebugUtils', "#{s.version}"
  end

  s.subspec 'Logger' do |sp|
    sp.source_files = 'Foundation/GTMLogger.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
    sp.resource_bundle = {
      "GoogleToolboxForMac_Logger_Privacy" => "Resources/Logger/PrivacyInfo.xcprivacy"
    }
  end

  # We cannot add a target for Foundation/GTMLogger+ASL.{h,m}.
  # asl.h is not a modular header, and so cannot be imported
  # in a modulemap, which CocoaPods does by default when it
  # creates frameworks.

  # We cannot add a target for Foundation/GTMSQLite.{h,m}.
  # sqlite3.h is not a modular header, and so cannot be imported
  # in a modulemap, which CocoaPods does by default when it
  # creates frameworks.

  s.subspec 'StackTrace' do |sp|
    sp.source_files = 'Foundation/GTMStackTrace.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'StringEncoding' do |sp|
    sp.source_files = 'Foundation/GTMStringEncoding.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'NSData+zlib' do |sp|
    sp.source_files = 'Foundation/GTMNSData+zlib.{h,m}'
    sp.requires_arc = 'Foundation/GTMNSData+zlib.{h,m}'
    sp.libraries = 'z'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'NSFileHandle+UniqueName' do |sp|
    sp.source_files = 'Foundation/GTMNSFileHandle+UniqueName.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'NSString+HTML' do |sp|
    sp.source_files = 'Foundation/GTMNSString+HTML.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Core', "#{s.version}"
  end

  s.subspec 'NSString+XML' do |sp|
    sp.source_files = 'Foundation/GTMNSString+XML.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'NSThread+Blocks' do |sp|
    sp.source_files = 'Foundation/GTMNSThread+Blocks.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'TimeUtils' do |sp|
    sp.source_files = 'Foundation/GTMTimeUtils.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'iPhone' do |sp|
    sp.platform = :ios, ios_deployment_target
    sp.source_files =
        'iPhone/GTMFadeTruncatingLabel.{h,m}',
        'iPhone/GTMUIImage+Resize.{h,m}',
        'iPhone/GTMUILocalizer.{h,m}',
    sp.requires_arc = 'iPhone/GTMUIImage+Resize.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'RoundedRectPath' do |sp|
    sp.platform = :ios, ios_deployment_target
    sp.source_files = 'iPhone/GTMRoundedRectPath.{h,m}'
    sp.requires_arc = 'iPhone/GTMRoundedRectPath.{h,m}'
    sp.frameworks = 'CoreGraphics'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'UIFont+LineHeight' do |sp|
    sp.platform = :ios, ios_deployment_target
    sp.source_files = 'iPhone/GTMUIFont+LineHeight.{h,m}'
    sp.requires_arc = 'iPhone/GTMUIFont+LineHeight.{h,m}'
  end

  s.subspec 'UnitTesting' do |sp|
    sp.source_files = 'UnitTesting/GTMSenTestCase.{h,m}'
    sp.frameworks = 'XCTest'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
    # Enable GTMSenTestCase.h to find <XCTest/XCTest.h>
    sp.pod_target_xcconfig = {
      'ENABLE_TESTING_SEARCH_PATHS'=>'YES',
    }
    sp.user_target_xcconfig = {
      'ENABLE_TESTING_SEARCH_PATHS'=>'YES',
    }
  end

end
