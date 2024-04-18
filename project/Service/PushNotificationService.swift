////
////  PushNotificationService.swift
////  project
////
////  Created by 최안용 on 4/14/24.
////
//
//import Foundation
//import Combine
//import FirebaseMessaging
//
//protocol PushNotificationServiceType {
//    var fcmToken: AnyPublisher<String?, Never> { get }
//    func requestAuthorization(completion: @escaping (Bool) -> Void)
//}
//
//final class PushNotificationService: NSObject, PushNotificationServiceType {
//    
//    var fcmToken: AnyPublisher<String?, Never> {
//        _fcmToken.eraseToAnyPublisher()
//    }
//    
//    private let _fcmToken = CurrentValueSubject<String?, Never>(nil)
//    
//    override init() {
//        super.init()
//        
//        Messaging.messaging().delegate = self
//    }
//    
//    // 권한 요청
//    func requestAuthorization(completion: @escaping (Bool) -> Void) {
//        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//        
//        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
//            if error != nil {
//                completion(false)
//            } else {
//                completion(granted)
//            }
//        }
//    }
//}
//
//extension PushNotificationService: MessagingDelegate {
//    // 정상적으로 등록이 되면 fcmToken을 리턴
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        print("messaging:didReceiveRegistrationToken:", fcmToken ?? "")
//
//        guard let fcmToken else { return }
//        _fcmToken.send(fcmToken)
//    }
//}
//
//final class StubPushNotificationService: PushNotificationServiceType {
//    var fcmToken: AnyPublisher<String?, Never> {
//        Empty().eraseToAnyPublisher()
//    }
//    
//    func requestAuthorization(completion: @escaping (Bool) -> Void) {
//        
//    }
//}
