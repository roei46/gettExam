//
//  Response.swift
//  GettMobileDelivery
//
//  Created by Roei Baruch on 04/06/2021.
//

import Foundation

struct Response {
    fileprivate var data: Data
    init(data: Data) {
        self.data = data
    }
}


extension Response {
    public func decode<T: Codable>(_ type: T.Type) -> T? {
        let jsonDecoader = JSONDecoder()
        do {
            let response = try jsonDecoader.decode(T.self, from: data)
            return response
            
        } catch {
            print(error)
            return nil
        }
    }
}
