//
//  convertLocationObject.swift
//  project
//
//  Created by 최안용 on 5/25/24.
//

import Foundation
import CoreLocation

import NMapsMap

extension CLLocationCoordinate2D? {
    func toNMGLatLng() -> NMGLatLng {
        return NMGLatLng(lat: self?.latitude ?? 37.52901832956373,
                         lng: self?.longitude ?? 126.9136196847032)
    }
}
