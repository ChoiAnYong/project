//
//  ImageCacheService.swift
//  project
//
//  Created by 최안용 on 5/5/24.
//

import Combine
import UIKit
import Alamofire

protocol ImageCacheServiceType {
    func image(for key: String) -> AnyPublisher<UIImage?, Never>
}

final class ImageCacheService: ImageCacheServiceType {
    let memoryStorage: MemoryStorageType
    let diskStorage: DiskStorageType
    
    init(memoryStorage: MemoryStorageType, diskStorage: DiskStorageType) {
        self.memoryStorage = memoryStorage
        self.diskStorage = diskStorage
    }
    
    func image(for key: String) -> AnyPublisher<UIImage?, Never> {
        /*
         1. memory storage 확인
         2. disk storage 확인
         3. 위 둘 다 없으면 url session을 통해 이미지를 가져와서 memory storage disk storage에 각각 저장
         */
        imageWithMemoryCache(for: key)
            .flatMap { image -> AnyPublisher<UIImage?,Never> in
                if let image {
                    return Just(image).eraseToAnyPublisher()
                } else {
                    return self.imageWithDiskCache(for: key)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func imageWithMemoryCache(for key: String) -> AnyPublisher<UIImage?, Never> {
        Future { [weak self] promise in
            let image = self?.memoryStorage.value(for: key)
            promise(.success(image))
        }.eraseToAnyPublisher()
    }
    
    func imageWithDiskCache(for key: String) -> AnyPublisher<UIImage?, Never> {
        Future<UIImage?, Never> { [weak self] promise in
            do {
                let image = try self?.diskStorage.value(for: key)
                promise(.success(image))
            } catch {
                promise(.success(nil))
            }
        }
        .flatMap { image -> AnyPublisher<UIImage?, Never> in
            if let image {
                return Just(image)
                    .handleEvents(receiveOutput: { [weak self] image in
                        guard let image else { return }
                        self?.store(for: key, image: image, toDisk: false)
                    })
                    .eraseToAnyPublisher()
            } else {
                return self.remoteImage(for: key)
            }
        }
        .eraseToAnyPublisher()
    }
    
    func remoteImage(for urlString: String) -> AnyPublisher<UIImage?, Never> {
        guard let url = URL(string: urlString) else {
            return Just(nil)
                .eraseToAnyPublisher()
        }
        
        return Future<UIImage?, Never> { promise in
            AF.request(url)
                .validate(statusCode: 200..<300)
                .responseDecodable { (response: AFDataResponse<Data>) in
                    
                    switch response.result {
                    case let .success(data):
                        guard let image = UIImage(data: data) else { return }
                        promise(.success(image))
                    case .failure:
                        promise(.success(nil))
                    }
                    
                }
        }
        .handleEvents(receiveOutput: { [weak self] image in
            guard let image = image else { return }
            self?.store(for: urlString, image: image, toDisk: true)
        })
        .eraseToAnyPublisher()
    }
    
    func store(for key: String, image: UIImage, toDisk: Bool) {
        memoryStorage.store(for: key, image: image)
        
        if toDisk {
            try? diskStorage.store(for: key, image: image)
        }
    }
}

final class StubImageCacheService: ImageCacheServiceType {
    func image(for key: String) -> AnyPublisher<UIImage?, Never> {
        Empty().eraseToAnyPublisher()
    }
}
