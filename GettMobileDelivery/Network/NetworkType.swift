//
//  NetworkType.swift
//  GettMobileDelivery
//
//  Created by Roei Baruch on 04/06/2021.
//

import Foundation
import RxCocoa
import RxSwift

protocol NetworkType {
    func getRoute<T: Codable>(endPoint: EndpointType, type: T.Type) -> Observable<T>
    func loadJSON<T: Codable>(type: T.Type) -> Observable<T>
    func preformNetwokTask<T: Codable>(endPoint: EndpointType, type: T.Type, success: @escaping ((_ response: T) -> Void), failure: @escaping () -> Void)
}
