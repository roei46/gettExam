//
//  Networking.swift
//  GettMobileDelivery
//
//  Created by Roei Baruch on 04/06/2021.
//

import Foundation
import Alamofire
import RxCocoa
import RxSwift

enum MethodsType: String {
    case get
    case add
    case delete
    case update
}

extension MethodsType {
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .get:
            return .get
        case .add:
            return .post
        case .delete:
            return .delete
        case .update:
            return .patch
            
        }
    }
}

struct Networking: NetworkType {
    
    func getRoute<T: Codable>(endPoint: EndpointType, type: T.Type) -> Observable<T> {
        
        return Observable<T>.create { (observer) -> Disposable in
            let url = ("\(endPoint.baseURL)\(endPoint.path)")
                Alamofire.request(url).responseJSON { response in
                    print(response)
                    if response.result.isFailure {
                        observer.onError(response.result.error!)
                    }
                    
                    if let data = response.data {
                        let response = Response.init(data: data)
                        if let decode = response.decode(type) {
                            observer.onNext(decode)
                        } else {
                            observer.onError(NSError())
                    }
                }
            }
            return Disposables.create()
        }
    
    }
    
    
    
    func loadJSON<T: Codable>(type: T.Type) -> Observable<T> {
        
        return Observable<T>.create { (observer) -> Disposable in
            
            if let url = Bundle.main.url(forResource: "journey", withExtension: "json") {
                do {
                    let jsonData = try Data(contentsOf: url)
                    
                        let response = Response.init(data: jsonData)
                        if let decode = response.decode(type) {
                            observer.onNext(decode)

                        } else {
                            observer.onError(NSError())
                    }
                }
                catch {
                    observer.onError(NSError())
                }
            }
            return Disposables.create()
        }
    }

}
