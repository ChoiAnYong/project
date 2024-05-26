//
//  Services.swift
//  project
//
//  Created by 최안용 on 3/18/24.
//

import Foundation

protocol ServiceType {
    var authService: AuthenticationServiceType { get set }
    var userService: UserServiceType { get set }
    var imageCacheService: ImageCacheServiceType { get set }
    var photoPickerService: PhotoPickerServiceType { get set }
    var uploadService: UploadServiceType { get set }
//    var pushNotificationService: PushNotificationServiceType { get set }
}

final class Services: ServiceType {
    var authService: AuthenticationServiceType
    var userService: UserServiceType
    var imageCacheService: ImageCacheServiceType
    var photoPickerService: PhotoPickerServiceType
    var uploadService: UploadServiceType
//    var pushNotificationService: PushNotificationServiceType
    
    init() {
        self.authService = AuthenticationService()
        self.userService = UserService()
        self.imageCacheService = ImageCacheService(memoryStorage: MemoryStorage(),
                                                   diskStorage: DiskStorage())
        self.photoPickerService = PhotoPickerService()
        self.uploadService = UploadService()
//        self.pushNotificationService = PushNotificationService()
    }
}

final class StubService: ServiceType {
    var authService: AuthenticationServiceType = StubAuthenticationService()
    var userService: UserServiceType = StubUserService()
    var imageCacheService: ImageCacheServiceType = StubImageCacheService()
    var photoPickerService: PhotoPickerServiceType = StubPhotoPickerService()
    var uploadService: UploadServiceType = StubUploadService()
//    var pushNotificationService: PushNotificationServiceType = StubPushNotificationService()
}
