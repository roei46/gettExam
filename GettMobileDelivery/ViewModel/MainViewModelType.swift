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
    var locationManager: CLLocationManager { get }
    var zoomLevel: Float { get }
    var selectedItem: PublishRelay<NavigationPayload> { get }
    var targetMarker: GMSMarker { get }
    var hideView: PublishRelay<Bool> { get }
    var btnTitle: PublishRelay<String> { get }
    var titleToshow: PublishRelay<String> { get }

    func bindRx(defaultLocation: CLLocation) -> (_ trigger: Observable<Void>) -> Output
    func setView(frame: CGRect, item: NavigationPayload) -> TableView
}
