//
//  Api.swift
//  GettMobileDelivery
//
//  Created by Roei Baruch on 04/06/2021.
//

import Foundation

enum Api {
    case get
    case add
    case update(String)
    case delete(String)

}

extension Api: EndpointType {

    var baseURL: URL {
        return URL(string: "https://todolisthomeassignment.herokuapp.com")!
    }
        
    var path: String {
        switch self {
        case .get:
            return ""
        case .add:
            return ""
        case .update(let id):
            return "\(id)"
        case .delete(let id):
            return "\(id)"
        }
    }
}
