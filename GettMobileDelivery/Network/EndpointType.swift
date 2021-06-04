//
//  EndpointType.swift
//  GettMobileDelivery
//
//  Created by Roei Baruch on 04/06/2021.
//

import Foundation
protocol EndpointType {
    
    var baseURL: URL { get }
    
    var path: String { get }
    
}
