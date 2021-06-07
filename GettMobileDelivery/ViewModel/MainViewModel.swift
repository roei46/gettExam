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

    let disposeBag = DisposeBag()
    var networking: NetworkType
    
    
    //Inputs
    let myStateObservable = BehaviorRelay<Bool>(value: false)

    //Outputs
    var locationManager: CLLocationManager
    var targetMarker = GMSMarker()
    var preciseLocationZoomLevel: Float = 15.0
    var approximateLocationZoomLevel: Float = 10.0
    lazy var zoomLevel: Float = {
        return locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
    }()
    
    var btnTitle = PublishRelay<String>()
    var selectedItem = PublishRelay<NavigationPayload>()
    var titleToshow = PublishRelay<String>()
    var hideView = PublishRelay<Bool>()
    lazy var showEndOfDeliviry = myStateObservable.asDriver(onErrorDriveWith: .never())

    init(networking: Networking = Networking()) {
        self.networking = networking
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        
        // MARK - Subscribing to selected items in order to manipulate the vc views
        selectedItem.subscribe { item in
            if let payload = item.element {
                self.targetMarker.position = CLLocationCoordinate2D(latitude: payload.geo.latitue, longitude: payload.geo.longitude)
                switch payload.type {
                case .navigateToPickUP, .navigateToDrop:
                    self.btnTitle.accept("Arrived")
                    self.hideView.accept(false)
                    self.titleToshow.accept("")
                case .pickUp:
                    self.btnTitle.accept("Done")
                    self.hideView.accept(true)
                    self.titleToshow.accept("Pickup")
                case .drop:
                    self.btnTitle.accept("Done")
                    self.hideView.accept(true)
                    self.titleToshow.accept("Drop")
                }
            }
        }.disposed(by: disposeBag)
    }
    
    func setView(frame: CGRect, item: NavigationPayload) -> TableView {
        let viewModel = ParcelsViewModel(items: item)
        return TableView(frame: frame, viewModel: viewModel)
    }
    
    func isLastItem(state: State) -> Bool {
        return state.all.count - 1 == state.current
    }
            
    func scan( state: inout State, action: Action) -> Void {
        self.myStateObservable.accept(self.isLastItem(state: state))
        
        switch action {
        case .reset(let items):
            state.all = items
            state.current = 0
        case .next:
            state.current = (state.current + 1) % state.all.count
            // MARK - Reset when arriving to last point
        }
    }
    
    func bindRx(defaultLocation: CLLocation) -> (_ trigger: Observable<Void>) -> Output {
        { trigger in
            
            // MARK - trigger represents the button tap action
            // MARK - items creates an observable that will make a networking request every time it's subscribed to.
           // items subscrive one time thus for it will make one network call
            let items = self.networking.loadJSON(type: [NavigationPayload].self)
            // MARK - .merge creates an Observable<Action> that will emit all the values that either of its source observables emit.
            let currentItem = Observable.merge(
                //MARK - items.map { Action.reset($0) } creates an Observable<Action> that, when subscribed to, will make the network request, wait for the response, then wrap the response in an Action
                trigger.map { Action.next },
                items.map { Action.reset($0) }
            )
            .scan(into: State(),accumulator: self.scan(state:action:))
            .compactMap { $0.all.isEmpty ? nil : $0.all[$0.current] }
            .share(replay: 1)
            //MARK - The replay: 1 will store the last emitted value and replay it to any new subscribers
            let routes = currentItem
                .flatMap { item in
                    self.networking.getRoute(endPoint: Api.getRoute(current: defaultLocation, target: CLLocation(latitude: item.geo.latitue, longitude: item.geo.longitude)), type: Routs.self)
                }
            
            // MARK - The first tap will cause trigger to emit a Void, which will cause map { Action.next } to emit an Action.next which will cause merge to emit an Action.next which will cause scan to emit a State object
            
            return Output(
                payload: currentItem,
                routes: routes
            )
        }
    }
}
