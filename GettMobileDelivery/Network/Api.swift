//
//  Api.swift
//  GettMobileDelivery
//
//  Created by Roei Baruch on 04/06/2021.
//

import Foundation
import GoogleMaps

enum Api {
    case getRoute(current: CLLocation, target: CLLocation)
}

extension Api: EndpointType {
    // NT - APIKEY
    var baseURL: URL {
        return URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=")!
    }
        
    var path: String {
        switch self {
        case .getRoute(current: let current, target: let target):
        let currentLat = String(current.coordinate.latitude)
        let currentLong = String(current.coordinate.longitude)
        let targettLat = String(target.coordinate.latitude)
        let targetLong = String(target.coordinate.longitude)
        return "\(currentLat),\(currentLong)&destination=\(targettLat),\(targetLong)&sensor=false&mode=driving&key=AIzaSyBq2Z7qOER7IH0dtzYyzE4NCV8BNUTuUa8"
        }
    }
}
