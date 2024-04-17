//
//  UserMarker.swift
//  project
//
//  Created by 최안용 on 4/16/24.
//

import UIKit

enum MarkerType {
    case _static
    case human
    case information
}

/*
 Marker의 기본이 되는 데이터
 */
protocol MarKerProtocol {
    var type : MarkerType { get set }
    var id : Int { get set }
    var lat : Double { get set }
    var lng : Double { get set }
}

/*
 사용자를 표현하는 마커 데이터
 */
struct HumanMarker : MarKerProtocol {
    var type: MarkerType
    var id: Int
    var lat: Double
    var lng: Double
    let imgUrl : String
    let decorateColor : String
}

class HumanMarkerView: UIView {
    lazy var imageView = UIImageView(frame: .init(x: 0, y: 0, width: 50, height: 50))
    lazy var decorateView = UIView(frame: .init(x: 50 / 2 - 10, y: 50 + 8, width: 10, height: 10))
    
    override var intrinsicContentSize: CGSize {
        let imgSize = 50
        let decorationHeight = 10 + 8
        return CGSize(width: imgSize, height: imgSize + decorationHeight)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.layer.borderWidth = 3
        decorateView.backgroundColor = .clear
        decorateView.layer.cornerRadius = 5
        
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ data: HumanMarker, completion: @escaping (UIImage?) -> Void) {
        imageView.layer.borderColor = UIColor(.appOrange).cgColor
        decorateView.backgroundColor = UIColor(.grayLight)
        
        self.imageView.image = UIImage(resource: .lee)
        let img = self.toImage()
        completion(img)
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
