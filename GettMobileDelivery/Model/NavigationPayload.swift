//
//  NavigationPayload.swift
//  GettMobileDelivery
//
//  Created by Roei Baruch on 04/06/2021.
//

import Foundation

enum DeliveryStatus: String, Codable  {
    case navigateToPickUP = "navigate_to_pickup"
    case pickUp = "pickup"
    case navigateToDrop = "navigate_to_drop_off"
    case drop = "drop_off"
}

struct NavigationPayload: Codable {
    var type: DeliveryStatus
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


struct Routs: Codable {
    var routes: [Rout]?
}

struct Rout: Codable {
    var legs: [Leg]?
}

struct Leg: Codable {
    var steps: [Step]?
}

struct Step: Codable {
    var polyline: Polyline?
}

struct Polyline: Codable {
    var points: String?
}
