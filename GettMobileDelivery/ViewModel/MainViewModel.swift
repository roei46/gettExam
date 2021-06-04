//
//  MainViewModel.swift
//  GettMobileDelivery
//
//  Created by Roei Baruch on 04/06/2021.
//

import Foundation
import RxSwift
import RxCocoa

enum Action {
        case reset([NavigationPayload])
        case next
    }
    struct State {
        var all: [NavigationPayload] = []
        var current: Int = 0
    }

final class MainVIewModel: MainViewModelType {
    var networking: NetworkType
    
    var getNavigations = PublishRelay<Void>()
//    var itemsDriver: Driver<[NavigationPayload]>

    
    
    init(networking: Networking = Networking()) {
        self.networking = networking
        
//        let items = getNavigations.bind { items in
//            networking.loadJSON(
//                endPoint: Api.get,
//                type: [NavigationPayload].self)
//                .debug("🚘 network call")
//
//        }
//
//        itemsDriver = items
//            .map { $0 }
//            .asDriver(onErrorJustReturn: []).debug("🚘 drive")
    }
    
    func bindRx(trigger: Observable<Void>) -> Observable<NavigationPayload> {
        
            let items = networking.loadJSON(endPoint: Api.get, type: [NavigationPayload].self)
            return Observable.merge(
                trigger.map { Action.next },
                items.map { Action.reset($0) }
            )
            .scan(into: State()) { state, action in
                switch action {
                case .reset(let items):
                    state.all = items
                    state.current = 0
                case .next:
                    state.current = (state.current + 1) % state.all.count
                }
            }
            .compactMap { $0.all.isEmpty ? nil : $0.all[$0.current] }
        }
}
