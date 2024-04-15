//
//  AppDelegate.swift
//  project
//
//  Created by 최안용 on 3/30/24.
//

import UIKit
import FirebaseCore
import FirebaseMessaging


class AppDelegate: NSObject, UIApplicationDelegate {
    // 앱 시작시 호출
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // apns에 앱 등록 요청
        application.registerForRemoteNotifications()
        
        // 알림 관련 작업을 하는 UNUserNotificationCenter에 delegate 연결
        UNUserNotificationCenter.current().delegate = self
        
        // FirebaseApp 초기화
        FirebaseApp.configure()

        return true
    }
    
    // 정상적으로 요청이 되면 이 메서드로 디바이스 토큰이 나옴, apnsToken을 명시적으로 매핑해줘야함
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Foreground(앱 켜진 상태)에서도 알림 오는 설정
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .banner])
    }
    
    // Notification의 응답 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
      }
}
