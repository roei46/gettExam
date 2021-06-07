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
            var new = [Parcel]()
            new.append(Parcel(barcode: "", display_identifier: "header"))
            new.append(contentsOf: parcels)
            self.items.accept(new)
        }
        
        switch items.type {
        case .pickUp:
            title = "Parcels to collect:"
        case.drop:
            title = "Parcels to deliver:"
        case .navigateToDrop, .navigateToPickUP: break
        }
    }
}
