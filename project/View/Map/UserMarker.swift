//
//  UserMarker.swift
//  project
//
//  Created by 최안용 on 4/16/24.
//

import UIKit
import NMapsMap

final class UserMarker: NMFMarker {
    
    let userInfoWindow = NMFInfoWindow()
    
    override init() {
        super.init()
        setUI()
    }
}

extension UserMarker {
    private func setUI() {
        let originalImage = UIImage(resource: .lee)
        let resizedImage = resizeImage(originalImage)
        if let circularImage = resizedImage.circularImage() {
            self.iconImage = createOverlayImageFromImage(circularImage)
        }
        
        self.width = CGFloat(NMF_MARKER_SIZE_AUTO)
        self.height = CGFloat(NMF_MARKER_SIZE_AUTO)
        
        self.anchor = CGPoint(x: 0.5, y: 0.5)
    }
    
    func showInfoWindow() {
        userInfoWindow.open(with: self)
    }
    
    func hideInfoWindow() {
        userInfoWindow.close()
    }
}

extension UserMarker {
    func resizeImage(_ image: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 50, height: 50))
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))
        }
    }

    func createOverlayImageFromImage(_ image: UIImage) -> NMFOverlayImage {
        return NMFOverlayImage(image: image)
    }
}

extension UIImage {
    func circularImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 50, height: 50))
        return renderer.image { context in
            let roundedRect = CGRect(origin: .zero, size: size).insetBy(dx: 0.5, dy: 0.5)
            let path = UIBezierPath(roundedRect: roundedRect, cornerRadius: size.width / 2.0)
            path.addClip()
            draw(in: roundedRect)
        }
    }
}


