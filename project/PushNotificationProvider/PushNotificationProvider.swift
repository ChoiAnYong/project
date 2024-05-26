//
//  PushNotificationProvider.swift
//  project
//
//  Created by 최안용 on 4/11/24.
//

import Foundation
import Combine

//protocol PushNotificationProviderType {
//    func sendPushNotification(object: PushObject) -> AnyPublisher<Bool, Never>
//}
//
//class PushNotificationProvider: PushNotificationProviderType {
//    
//    private let serverURL: URL = URL(string: "https://emgapp.shop/fcm")!
//    private let serverKey = ""
//    
//    func sendPushNotification(object: PushObject) -> AnyPublisher<Bool, Never> {
//        var request = URLRequest(url: serverURL)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")
//        request.httpBody = try? JSONEncoder().encode(object)
//        
//        return URLSession.shared.dataTaskPublisher(for: request)
//            .map { _ in true }
//            .replaceError(with: false)
//            .eraseToAnyPublisher()
//    }
//}
