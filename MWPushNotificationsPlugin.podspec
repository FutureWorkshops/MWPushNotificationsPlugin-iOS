Pod::Spec.new do |s|
    s.name                  = 'MWPushNotificationsPlugin'
    s.version               = '0.2.7'
    s.summary               = 'Push Notifications plugin for MobileWorkflow on iOS.'
    s.description           = <<-DESC
    Push Notifications plugin for MobileWorkflow on iOS, to obtain user permission and then APNS token.
    DESC
    s.homepage              = 'https://www.mobileworkflow.io'
    s.license               = { :type => 'Copyright', :file => 'LICENSE' }
    s.author                = { 'Future Workshops' => 'info@futureworkshops.com' }
    s.source                = { :git => 'https://github.com/FutureWorkshops/MWPushNotificationsPlugin-iOS.git', :tag => "#{s.version}" }
    s.platform              = :ios
    s.swift_version         = '5'
    s.ios.deployment_target = '17.1'
    s.default_subspecs      = 'Core'
	
    s.subspec 'Core' do |cs|
        cs.dependency            'MobileWorkflow', '~> 2.1.29'
        cs.source_files          = 'MWPushNotificationsPlugin/MWPushNotificationsPlugin/**/*.swift'
    end
end
