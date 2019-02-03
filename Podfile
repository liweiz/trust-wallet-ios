platform :ios, '10.0'
inhibit_all_warnings!
source 'https://github.com/CocoaPods/Specs.git'

target 'Trust' do
  use_frameworks!

  pod 'BigInt', '~> 3.0'
  pod 'R.swift', '~> 4.0.0'
  pod 'JSONRPCKit', :git=> 'https://github.com/bricklife/JSONRPCKit.git'
  pod 'PromiseKit', '~> 6.0'
  pod 'APIKit'
  pod 'Eureka'
  pod 'MBProgressHUD'
  pod 'StatefulViewController'
  pod 'QRCodeReaderViewController', :git=>'https://github.com/yannickl/QRCodeReaderViewController.git', :branch=>'master'
  pod 'KeychainSwift'
  pod 'SwiftLint'
  pod 'SeedStackViewController'
  pod 'RealmSwift'
  pod 'Moya', '~> 10.0.1'
  pod 'CryptoSwift', '~> 0.10.0'
  pod 'Kingfisher', '~> 4.0'
  pod 'TrustCore', :git=>'https://github.com/liweiz/trust-core-moac', :branch=>'commit_f987ee1'
  pod 'TrustKeystore', :git=>'https://github.com/liweiz/trust-keystore', :branch=>'commit_5829d96'
  pod 'TrezorCrypto'
  pod 'Branch'
  pod 'SAMKeychain'
  pod 'TrustWeb3Provider', :git=>'https://github.com/TrustWallet/trust-web3-provider', :commit=>'f4e0ebb1b8fa4812637babe85ef975d116543dfd'
  pod 'URLNavigator'
  pod 'TrustWalletSDK', :git=>'https://github.com/liweiz/TrustSDK-iOS-Moac', :branch=>'commit_99eb145'

  target 'TrustTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'TrustUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if ['JSONRPCKit'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '3.0'
      end
    end
    if ['TrustKeystore'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
      end
    end
    # if target.name != 'Realm'
    #     target.build_configurations.each do |config|
    #         config.build_settings['MACH_O_TYPE'] = 'staticlib'
    #     end
    # end
  end
end
