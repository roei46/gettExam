//
//  MainViewModel.swift
//  GettMobileDelivery
//
//  Created by Roei Baruch on 04/06/2021.
//

import Foundation
import RxSwift
import RxCocoa
import GoogleMaps


enum Action {
        case reset([NavigationPayload])
        case next
    }
    struct State {
        var all: [NavigationPayload] = []
        var current: Int = 0
    }

struct Output {
    let payload: Observable<NavigationPayload>
    let routes: Observable<Routs>
}

final class MainVIewModel: MainViewModelType {
//    var mapView: GMSMapView
    
    var locationManager: CLLocationManager
    var currentLocation: CLLocation?
    var targetLocation: CLLocation?
    let disposeBag = DisposeBag()

    var networking: NetworkType

    var getNavigations = PublishRelay<Void>()
    var selectedItem = PublishRelay<NavigationPayload>()

    let currentLocationMarker = GMSMarker()
    var targetMarker = GMSMarker()
    
    
    
    init(networking: Networking = Networking()) {
        self.networking = networking
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        
        
        selectedItem.subscribe { item in
            if let clllocation = item.element {
                self.targetMarker.position = CLLocationCoordinate2D(latitude: clllocation.geo.latitue, longitude: clllocation.geo.longitude)
            }
        }.disposed(by: disposeBag)

    }

    func bindRx(defaultLocation: CLLocation) -> (_ trigger: Observable<Void>) -> Output {
        { trigger in

            let items = self.networking.loadJSON(type: [NavigationPayload].self).debug("🚘 items")
            let currentItem = Observable.merge(
                trigger.debug("🚘 trigger").map { Action.next },
                items.map { Action.reset($0) }
            ).debug("🚘 merge")
            .scan(into: State()) { state, action in
                switch action {
                case .reset(let items):
                    state.all = items
                    state.current = 0
                case .next:
                    state.current = (state.current + 1) % state.all.count
                }
            }.debug("🚘 scan")
            .compactMap { $0.all.isEmpty ? nil : $0.all[$0.current] }.debug("🚘 compact")
            .share(replay: 1)

            let routes = currentItem.debug("🚘 currentItem flat")
                .flatMap { item in
                    self.networking.getRoute(endPoint: Api.getRoute(current: defaultLocation, target: CLLocation(latitude: item.geo.latitue, longitude: item.geo.longitude)), type: Routs.self)
                }.debug("🚘 routes flat")
            
            return Output(
                payload: currentItem,
                routes: routes
            )
        }
    }

//    func bindRx(trigger: Observable<Void>) -> Observable<NavigationPayload> {
//
//        let items = networking.loadJSON(type: [NavigationPayload].self).debug("🚘 items")
//            return Observable.merge(
//                trigger.debug("🚘 trigger").map { Action.next },
//                items.map { Action.reset($0) }
//            ).debug("🚘 merge")
//            .scan(into: State()) { state, action in
//                switch action {
//                case .reset(let items):
//                    state.all = items
//                    state.current = 0
//                    print("🚘 reset")
//                case .next:
//                    state.current = (state.current + 1) % state.all.count
//                    print("🚘 nextroei\(state.current)")
//
//                }
//            }.debug("🚘 scan")
//            .compactMap { $0.all.isEmpty ? nil : $0.all[$0.current] }.debug("🚘 compact")
//            .share()
//
//
//        }
//}
}
