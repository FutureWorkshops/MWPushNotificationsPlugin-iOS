source 'https://cdn.cocoapods.org/'
source 'https://github.com/FutureWorkshops/MWPodspecs.git'

workspace 'MWPushNotifications'
platform :ios, '13.0'

inhibit_all_warnings!
use_frameworks!

project 'MWPushNotifications/MWPushNotifications.xcodeproj'
project 'MWPushNotificationsPlugin/MWPushNotificationsPlugin.xcodeproj'

abstract_target 'MWPushNotifications' do
  pod 'MobileWorkflow'

  target 'MWPushNotifications' do
    project 'MWPushNotifications/MWPushNotifications.xcodeproj'

    target 'MWPushNotificationsTests' do
      inherit! :search_paths
    end
  end

  target 'MWPushNotificationsPlugin' do
    project 'MWPushNotificationsPlugin/MWPushNotificationsPlugin.xcodeproj'

    target 'MWPushNotificationsPluginTests' do
      inherit! :search_paths
    end
  end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ""
    end
  end
end
