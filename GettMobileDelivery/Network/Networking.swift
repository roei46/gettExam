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
    
    
    func preformTest<T: Codable>(endPoint: EndpointType, type: T.Type, success: @escaping ((_ response: T) -> Void), failure: @escaping () -> Void) {
        
        if let url = Bundle.main.url(forResource: "journey", withExtension: "json") {
            do {
                let jsonData = try Data(contentsOf: url)
                
                    let response = Response.init(data: jsonData)
                    if let decode = response.decode(type) {
                        success(decode)
                    } else {
                        print("error")
                }
            }
            catch {
                print(error)
            }
        }
    }
    
    func loadJSON<T: Codable>(endPoint: EndpointType, type: T.Type) -> Observable<T> {
        
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
            
            //            if let url = endPoint.baseURL.appendingPathComponent(endPoint.path).absoluteString.removingPercentEncoding {
            //                Alamofire.request(url).responseJSON { (response) in
            //                    if response.result.isFailure {
            //                        observer.onError(response.result.error!)
            //                    }
            //
            //                    if let data = response.data {
            //                        let response = Response.init(data: data)
            //                        if let decode = response.decode(type) {
            //                            observer.onNext(decode)
            //                        } else {
            //                            observer.onError(NSError())
            //                        }
            //                    }
            //                }
            //            }
            return Disposables.create()
        }
    }
    func preformNetworkTask(endPoint: EndpointType, methodType: MethodsType, param: [String : Any]?) -> Observable<Void> {
        return Observable<Void>.create { (observer) -> Disposable in
            if let url = endPoint.baseURL.appendingPathComponent(endPoint.path).absoluteString.removingPercentEncoding {
                Alamofire.request(url, method: methodType.method, parameters: param, encoding: URLEncoding.default).responseJSON { response in
                    print(response)
                    if response.result.isFailure {
                        observer.onError(response.error!)
                    } else {
                        observer.onNext(())
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    
    func preformNetworkTaskGet<T: Codable>(endPoint: EndpointType, type: T.Type) -> Observable<T> {
        
        return Observable<T>.create { (observer) -> Disposable in
            if let url = endPoint.baseURL.appendingPathComponent(endPoint.path).absoluteString.removingPercentEncoding {
                Alamofire.request(url).responseJSON { (response) in
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
            }
            return Disposables.create()
        }
    }
}
