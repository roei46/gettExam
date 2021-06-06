//
//  ParcelsViewModel.swift
//  GettMobileDelivery
//
//  Created by Roei Baruch on 05/06/2021.
//

import Foundation
import RxSwift
import RxCocoa

final class ParcelsViewModel {
    
    let items = BehaviorRelay<[Parcel]>(value: [])

    var title: String!
    
    init(items: NavigationPayload) {
        if let parcels = items.parcels {
            self.items.accept(parcels)
        }
        
        switch items.type {
        case .pickUp:
            title = "Pickup"
        case.drop:
            title = "Drop-Off"
        case .navigateToDrop, .navigateToPickUP: break
        }
    }
}
