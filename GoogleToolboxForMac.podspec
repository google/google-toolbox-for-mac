Pod::Spec.new do |s|
  s.name             = 'GoogleToolboxForMac'
  s.version          = '2.0.0'
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

  s.osx.deployment_target = '10.6'
  s.ios.deployment_target = '5.0'
  s.requires_arc = false

  s.subspec 'Defines' do |sp|
    sp.public_header_files = 'GTMDefines.h'
    sp.source_files = 'GTMDefines.h'
  end

  s.subspec 'Core' do |sp|
    sp.source_files =
        'DebugUtils/GTMTypeCasting.h',
        'Foundation/GTMLocalizedString.h',
        'Foundation/GTMLogger.h'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end


  s.subspec 'AddressBook' do |sp|
    sp.source_files = 'AddressBook/GTMABAddressBook.{h,m}'
    sp.frameworks = 'AddressBook'
    sp.dependency 'GoogleToolboxForMac/Core', "#{s.version}"
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'DebugUtils' do |sp|
    sp.source_files =
        'DebugUtils/GTMDebugSelectorValidation.{h,m}',
        'DebugUtils/GTMDebugThreadValidation.h',
        'DebugUtils/GTMMethodCheck.{h,m}'
    sp.requires_arc = 'DebugUtils/GTMMethodCheck.m'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
    sp.dependency 'GoogleToolboxForMac/Runtime', "#{s.version}"
  end

  s.subspec 'GeometryUtils' do |sp|
    sp.source_files = 'Foundation/GTMGeometryUtils.{h,m}'
    sp.frameworks = 'CoreGraphics'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'KVO' do |sp|
    sp.source_files =
        'Foundation/GTMNSObject+KeyValueObserving.{h,m}',
        # The symbol in this file is hidden by default, and so
        # must be directly included here where it's needed,
        # even though it's already included in DebugUtils
        'DebugUtils/GTMMethodCheck.m'
    sp.dependency 'GoogleToolboxForMac/Core', "#{s.version}"
    sp.dependency 'GoogleToolboxForMac/DebugUtils', "#{s.version}"
    sp.dependency 'GoogleToolboxForMac/Runtime', "#{s.version}"
  end

  s.subspec 'Logger' do |sp|
    sp.source_files = 'Foundation/GTMLogger.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  # We cannot add a target for Foundaat/GTMLogger+ASL.{h,m}.
  # asl.h is not a modular header, and so cannot be imported
  # in a modulemap, which CocoaPods does by default when it
  # creates frameworks.

  s.subspec 'Regex' do |sp|
    sp.source_files = 'Foundation/GTMRegex.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'Runtime' do |sp|
    sp.source_files = 'Foundation/GTMObjC2Runtime.{h,m}'
    sp.requires_arc = 'Foundation/GTMObjC2Runtime.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  # We cannot add a target for Foundation/GTMSQLite.{h,m}.
  # sqlite3.h is not a modular header, and so cannot be imported
  # in a modulemap, which CocoaPods does by default when it
  # creates frameworks.

  s.subspec 'StackTrace' do |sp|
    sp.source_files = 'Foundation/GTMStackTrace.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
    sp.dependency 'GoogleToolboxForMac/Runtime', "#{s.version}"
  end

  s.subspec 'StringEncoding' do |sp|
    sp.source_files = 'Foundation/GTMStringEncoding.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'SystemVersion' do |sp|
    sp.source_files = 'Foundation/GTMSystemVersion.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
    sp.dependency 'GoogleToolboxForMac/Runtime', "#{s.version}"
  end

  s.subspec 'URLBuilder' do |sp|
    sp.source_files = 'Foundation/GTMURLBuilder.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Core', "#{s.version}"
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
    sp.dependency 'GoogleToolboxForMac/NSDictionary+URLArguments', "#{s.version}"
    sp.dependency 'GoogleToolboxForMac/NSString+URLArguments', "#{s.version}"
  end


  s.subspec 'NSData+zlib' do |sp|
    sp.source_files = 'Foundation/GTMNSData+zlib.{h,m}'
    sp.requires_arc = 'Foundation/GTMNSData+zlib.{h,m}'
    sp.libraries = 'z'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'NSDictionary+URLArguments' do |sp|
    sp.source_files = 'Foundation/GTMNSDictionary+URLArguments.{h,m}'
    sp.requires_arc = 'Foundation/GTMNSDictionary+URLArguments.{h,m}'
    sp.dependency 'GoogleToolboxForMac/DebugUtils', "#{s.version}"
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
    sp.dependency 'GoogleToolboxForMac/NSString+URLArguments', "#{s.version}"
  end

  s.subspec 'NSFileHandle+UniqueName' do |sp|
    sp.source_files = 'Foundation/GTMNSFileHandle+UniqueName.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'NSScanner+JSON' do |sp|
    sp.source_files = 'Foundation/GTMNSScanner+JSON.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'NSString+HTML' do |sp|
    sp.source_files = 'Foundation/GTMNSString+HTML.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Core', "#{s.version}"
  end

  s.subspec 'NSString+URLArguments' do |sp|
    sp.source_files = 'Foundation/GTMNSString+URLArguments.{h,m}'
  end

  s.subspec 'NSString+XML' do |sp|
    sp.source_files = 'Foundation/GTMNSString+XML.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'NSThread+Blocks' do |sp|
    sp.source_files = 'Foundation/GTMNSThread+Blocks.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end


  s.subspec 'iPhone' do |sp|
    sp.platform = :ios, '5.0'
    sp.source_files =
        'iPhone/GTMFadeTruncatingLabel.{h,m}',
        'iPhone/GTMUIImage+Resize.{h,m}',
        'iPhone/GTMUILocalizer.{h,m}',
        'iPhone/GTMUIView+SubtreeDescription.{h,m}'
    sp.requires_arc = 'iPhone/GTMUIImage+Resize.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'RoundedRectPath' do |sp|
    sp.platform = :ios, '5.0'
    sp.source_files = 'iPhone/GTMRoundedRectPath.{h,m}'
    sp.requires_arc = 'iPhone/GTMRoundedRectPath.{h,m}'
    sp.frameworks = 'CoreGraphics'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
  end

  s.subspec 'UIFont+LineHeight' do |sp|
    sp.platform = :ios, '5.0'
    sp.source_files = 'iPhone/GTMUIFont+LineHeight.{h,m}'
    sp.requires_arc = 'iPhone/GTMUIFont+LineHeight.{h,m}'
  end


  s.subspec 'UnitTesting' do |sp|
    sp.platform = :ios, '5.0'
    sp.requires_arc = 'UnitTesting/GTMDevLogUnitTestingBridge.m'
    sp.source_files =
        'UnitTesting/GTMCALayer+UnitTesting.{h,m}',
        'UnitTesting/GTMDevLogUnitTestingBridge.m',
        'UnitTesting/GTMFoundationUnitTestingUtilities.{h,m}',
        'UnitTesting/GTMNSObject+UnitTesting.{h,m}',
        'UnitTesting/GTMSenTestCase.{h,m}',
        'UnitTesting/GTMTestTimer.h',
        'UnitTesting/GTMUIKit+UnitTesting.{h,m}',
        'UnitTesting/GTMUnitTestDevLog.{h,m}'
    sp.requires_arc = 'UnitTesting/GTMDevLogUnitTestingBridge.m'
    sp.frameworks = 'CoreGraphics', 'QuartzCore'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
    sp.dependency 'GoogleToolboxForMac/Regex', "#{s.version}"
    sp.dependency 'GoogleToolboxForMac/Runtime', "#{s.version}"
    sp.dependency 'GoogleToolboxForMac/SystemVersion', "#{s.version}"
  end

  s.subspec 'UnitTestingAppLib' do |sp|
    sp.platform = :ios, '5.0'
    sp.source_files =
        'UnitTesting/GTMCodeCoverageApp.h',
        'UnitTesting/GTMIPhoneUnitTestDelegate.{h,m}'
    sp.dependency 'GoogleToolboxForMac/Defines', "#{s.version}"
    sp.dependency 'GoogleToolboxForMac/UnitTesting', "#{s.version}"
  end

end
