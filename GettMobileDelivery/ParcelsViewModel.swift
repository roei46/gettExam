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

    init(items: NavigationPayload) {
        if let parcels = items.parcels {
            self.items.accept(parcels)
        }
    }
}
