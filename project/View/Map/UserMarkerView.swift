//
//  UserMarkerView.swift
//  project
//
//  Created by 최안용 on 4/16/24.
//

import UIKit
import Combine

class UserMarkerView: UIView {
    lazy var imageView = UIImageView(frame: .init(x: 0, y: 0, width: 55, height: 55))
    lazy var decorateView = UIView(frame: .init(x: 55 / 2 - 10 / 2 , y: 55 + 8, width: 10, height: 10))
    private var container: DIContainer
    private var subscriptions = Set<AnyCancellable>()
    
    override var intrinsicContentSize: CGSize {
        let imgSize = 55
        let decorationHeight = 10 + 8
        return CGSize(width: imgSize, height: imgSize + decorationHeight)
    }
    
    init(container: DIContainer, frame: CGRect = .zero) {
        self.container = container
        super.init(frame: frame)
        
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.layer.borderWidth = 3
        decorateView.backgroundColor = .clear
        decorateView.layer.cornerRadius = 5
        
        layout()
        self.frame = .init(x: 0, y: 0, width: 55, height: 75)
        layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ data: UserMarker, completion: @escaping (UIImage?) -> Void) {
        container.services.imageCacheService.image(for: data.imgUrl)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { result in
                print("completion: \(result)")
            } receiveValue: { [weak self] image in
                self?.imageView.layer.borderColor = UIColor(.appOrange).cgColor
                self?.decorateView.backgroundColor = UIColor(.appOrange)
                
                self?.imageView.image = image ?? UIImage()
                
                let img = self?.toImage()
                
                completion(img)
            }
            .store(in: &subscriptions)
    }
    
    private func layout() {
        [imageView, decorateView].forEach {
            addSubview($0)
        }
    }
}


extension UIView {
    func toImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
