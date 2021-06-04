//
//  MainViewModelType.swift
//  GettMobileDelivery
//
//  Created by Roei Baruch on 04/06/2021.
//

import Foundation
import RxSwift
import RxCocoa

protocol MainViewModelType {
    var getNavigations: PublishRelay<Void> { get }
    
    func bindRx(trigger: Observable<Void>) -> Observable<NavigationPayload>
}
