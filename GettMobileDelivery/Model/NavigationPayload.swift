//
//  NavigationPayload.swift
//  GettMobileDelivery
//
//  Created by Roei Baruch on 04/06/2021.
//

import Foundation

struct NavigationPayload: Codable {
    var type: String
    var state: String
    var geo: Geo
    var parcels: [Parcel]?
}

struct Geo: Codable {
    var address: String
    var latitue: Double
    var longitude: Double
}

struct Parcel: Codable {
    var barcode: String
    var display_identifier: String
}
