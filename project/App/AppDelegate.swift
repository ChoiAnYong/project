//
//  AppDelegate.swift
//  project
//
//  Created by 최안용 on 3/30/24.
//

import UIKit
import UserNotifications

import FirebaseCore
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    private let keychainManager = KeychainManager.shared
    // 앱 시작시 호출
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // FirebaseApp 초기화
        FirebaseApp.configure()
        
        // 파이어베이스 Meesaging 설정
        Messaging.messaging().delegate = self
        
        // 필요한 알림 권한을 요청
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        // apns에 앱 등록 요청
        application.registerForRemoteNotifications()
        
        
        
        // 알림 관련 작업을 하는 UNUserNotificationCenter에 delegate 연결
        UNUserNotificationCenter.current().delegate = self
        
        removeKeychainAtFirstLaunch()
        
        return true
    }
    
    private func removeKeychainAtFirstLaunch() {
        guard UserDefaults.isFirstLaunch() else { return }
        
        _ = keychainManager.delete(account: SaveToken.access.rawValue)
        _ = keychainManager.delete(account: SaveToken.refresh.rawValue)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Foreground(앱 켜진 상태)에서도 알림 오는 설정
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("willPresent: userInfo: ", userInfo)
        completionHandler([.list, .banner])
    }
    
    // Notification의 응답 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    // APN 토큰을 FCM 등록 토큰에 매핑
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs 등록 및 디바이스 토큰 받기 실패:" + error.localizedDescription)
    }
}

extension AppDelegate: MessagingDelegate {    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        UserDefaults.standard.set(fcmToken, forKey: "deviceToken")
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"),
                                        object: nil,
                                        userInfo: dataDict)
    }
}
