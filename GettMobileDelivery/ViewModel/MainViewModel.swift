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

final class MainVIewModel: MainViewModelType {
//    var mapView: GMSMapView
    
    var locationManager: CLLocationManager
    var currentLocation: CLLocation?
    var targetLocation: CLLocation?
    let disposeBag = DisposeBag()

    var networking: NetworkType

    var getNavigations = PublishRelay<Void>()
//    var itemsDriver: Driver<[NavigationPayload]>
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
            //
            print("shit")
            if let clllocation = item.element {
                self.targetMarker.position = CLLocationCoordinate2D(latitude: clllocation.geo.latitue, longitude: clllocation.geo.longitude)
            }
        }.disposed(by: disposeBag)
    }
    
    
    
//    func getLocation(item: NavigationPayload) -> NavigationPayload {
//
//    }
    
    func bindRx(trigger: Observable<Void>) -> Observable<NavigationPayload> {
        
        
        let items = networking.loadJSON(endPoint: Api.get, type: [NavigationPayload].self).debug("🚘 items")
        
            return Observable.merge(
                trigger.map { Action.next },
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
        }
}
