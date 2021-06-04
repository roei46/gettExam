//
//  MainViewModelType.swift
//  GettMobileDelivery
//
//  Created by Roei Baruch on 04/06/2021.
//

import Foundation
import RxSwift
import RxCocoa
import GoogleMaps

protocol MainViewModelType {
    var getNavigations: PublishRelay<Void> { get }
    var locationManager: CLLocationManager { get }
//    var mapView: GMSMapView { get }
    var selectedItem: PublishRelay<NavigationPayload> { get }
    var targetMarker: GMSMarker { get }

    func bindRx(trigger: Observable<Void>) -> Observable<NavigationPayload>
}
