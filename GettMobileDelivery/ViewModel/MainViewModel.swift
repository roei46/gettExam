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
    var btnTitle = PublishRelay<String>()
        
    var locationManager: CLLocationManager
    var currentLocation: CLLocation?
    var targetLocation: CLLocation?
    let disposeBag = DisposeBag()

    var networking: NetworkType

    var getNavigations = PublishRelay<Void>()
    var selectedItem = PublishRelay<NavigationPayload>()

    let currentLocationMarker = GMSMarker()
    var targetMarker = GMSMarker()
    
    var preciseLocationZoomLevel: Float = 15.0
    var approximateLocationZoomLevel: Float = 10.0
    lazy var zoomLevel: Float = {
        return locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
    }()
    
    let onTappedShowParcels = PublishRelay<NavigationPayload>()

    lazy var showParcels = onTappedShowParcels.asDriver(onErrorDriveWith: .never())

    init(networking: Networking = Networking()) {
        self.networking = networking
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        
        
        selectedItem.subscribe { item in
            if let payload = item.element {
                self.targetMarker.position = CLLocationCoordinate2D(latitude: payload.geo.latitue, longitude: payload.geo.longitude)
                
                switch payload.type {
                case .navigateToPickUP, .navigateToDrop:
                    self.btnTitle.accept("Arrived")
                case .pickUp, .drop:
                    self.btnTitle.accept("Done")
                }
            }
        }.disposed(by: disposeBag)

    }
    
    func isLastItem(state: State) -> Bool {
        return (state.all.last != nil) ? true : false
    }

    func bindRx(defaultLocation: CLLocation) -> (_ trigger: Observable<Void>) -> Output {
        { trigger in

            let items = self.networking.loadJSON(type: [NavigationPayload].self).debug("🚘 items")
            let currentItem = Observable.merge(
                trigger.debug("🚘 merge trigger").map { Action.next },
                items.debug("🚘 merge item").map { Action.reset($0) }
            ).debug("🚘 merge all")
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
}
