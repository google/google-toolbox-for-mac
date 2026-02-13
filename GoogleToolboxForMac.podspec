Pod::Spec.new do |s|
  s.name             = 'GoogleToolboxForMac'
  s.version          = '6.0.0'
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

  osx_deployment_target = '10.15'
  ios_deployment_target = '13.0'
  tvos_deployment_target = '13.0'

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
    sp.public_header_files = 'Sources/Defines/Public/GTMDefines.h'
    sp.source_files = 'Sources/Defines/Public/GTMDefines.h'
    sp.resource_bundle = {
      "GoogleToolboxForMac_Privacy" => "Resources/Base/PrivacyInfo.xcprivacy"
    }
  end

  s.subspec 'Core' do |sp|
    sp.source_files =
        'DebugUtils/GTMTypeCasting.h',
        'Sources/LocalizedString/Public/Foundation/GTMLocalizedString.h',
        'Sources/Logger/Public/Foundation/GTMLogger.h'
    sp.public_header_files = 'Sources/LocalizedString/Public/Foundation/GTMLocalizedString.h', 'Sources/Logger/Public/Foundation/GTMLogger.h'
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
    sp.source_files = 'Sources/GeometryUtils/GTMGeometryUtils.m', 'Sources/GeometryUtils/Public/Foundation/GTMGeometryUtils.h'
    sp.public_header_files = 'Sources/GeometryUtils/Public/Foundation/GTMGeometryUtils.h'
    sp.frameworks = 'CoreGraphics'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'KVO' do |sp|
    sp.source_files =
        'Sources/KVO/GTMNSObject+KeyValueObserving.m', 'Sources/KVO/Public/Foundation/GTMNSObject+KeyValueObserving.h'
    sp.public_header_files = 'Sources/KVO/Public/Foundation/GTMNSObject+KeyValueObserving.h'
    sp.requires_arc =
        'Sources/KVO/GTMNSObject+KeyValueObserving.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Core', "#{s.version}"
    sp.dependency 'GoogleToolboxForMac/DebugUtils', "#{s.version}"
  end

  s.subspec 'Logger' do |sp|
    sp.source_files = 'Sources/Logger/GTMLogger.m', 'Sources/Logger/Public/Foundation/GTMLogger.h'
    sp.public_header_files = 'Sources/Logger/Public/Foundation/GTMLogger.h'
    sp.requires_arc = 'Sources/Logger/GTMLogger.m', 'Sources/Logger/Public/Foundation/GTMLogger.h'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
    sp.resource_bundle = {
      "GoogleToolboxForMac_Logger_Privacy" => "Sources/Logger/Resources/PrivacyInfo.xcprivacy"
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
    sp.source_files = 'Sources/StackTrace/GTMStackTrace.m', 'Sources/StackTrace/Public/Foundation/GTMStackTrace.h'
    sp.public_header_files = 'Sources/StackTrace/Public/Foundation/GTMStackTrace.h'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'StringEncoding' do |sp|
    sp.source_files = 'Sources/StringEncoding/GTMStringEncoding.m', 'Sources/StringEncoding/Public/Foundation/GTMStringEncoding.h'
    sp.public_header_files = 'Sources/StringEncoding/Public/Foundation/GTMStringEncoding.h'
    sp.requires_arc = 'Sources/StringEncoding/GTMStringEncoding.m', 'Sources/StringEncoding/Public/Foundation/GTMStringEncoding.h'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'NSData+zlib' do |sp|
    sp.source_files = 'Sources/NSData_zlib/GTMNSData+zlib.m', 'Sources/NSData_zlib/Public/Foundation/GTMNSData+zlib.h'
    sp.public_header_files = 'Sources/NSData_zlib/Public/Foundation/GTMNSData+zlib.h'
    sp.requires_arc = 'Sources/NSData_zlib/GTMNSData+zlib.m', 'Sources/NSData_zlib/Public/Foundation/GTMNSData+zlib.h'
    sp.libraries = 'z'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'NSFileHandle+UniqueName' do |sp|
    sp.source_files = 'Sources/NSFileHandle_UniqueName/GTMNSFileHandle+UniqueName.m', 'Sources/NSFileHandle_UniqueName/Public/Foundation/GTMNSFileHandle+UniqueName.h'
    sp.public_header_files = 'Sources/NSFileHandle_UniqueName/Public/Foundation/GTMNSFileHandle+UniqueName.h'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'NSString+HTML' do |sp|
    sp.source_files = 'Sources/NSString_HTML/GTMNSString+HTML.m', 'Sources/NSString_HTML/Public/Foundation/GTMNSString+HTML.h'
    sp.public_header_files = 'Sources/NSString_HTML/Public/Foundation/GTMNSString+HTML.h'
    sp.dependency 'GoogleToolboxForMac/Core', "#{s.version}"
  end

  s.subspec 'NSString+XML' do |sp|
    sp.source_files = 'Sources/NSString_XML/GTMNSString+XML.m', 'Sources/NSString_XML/Public/Foundation/GTMNSString+XML.h'
    sp.public_header_files = 'Sources/NSString_XML/Public/Foundation/GTMNSString+XML.h'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'NSThread+Blocks' do |sp|
    sp.source_files = 'Sources/NSThread_Blocks/GTMNSThread+Blocks.m', 'Sources/NSThread_Blocks/Public/Foundation/GTMNSThread+Blocks.h'
    sp.public_header_files = 'Sources/NSThread_Blocks/Public/Foundation/GTMNSThread+Blocks.h'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'TimeUtils' do |sp|
    sp.source_files = 'Sources/TimeUtils/GTMTimeUtils.m', 'Sources/TimeUtils/Public/Foundation/GTMTimeUtils.h'
    sp.public_header_files = 'Sources/TimeUtils/Public/Foundation/GTMTimeUtils.h'
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
    sp.source_files = 'UnitTesting/SenTestCase/include/GTMSenTestCase.h', 'UnitTesting/SenTestCase/GTMSenTestCase.m'
    sp.public_header_files = 'UnitTesting/SenTestCase/include/GTMSenTestCase.h'
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
