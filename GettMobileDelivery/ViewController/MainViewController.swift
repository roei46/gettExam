//
//  ViewController.swift
//  GettMobileDelivery
//
//  Created by Gett on 5/5/21.
//

import UIKit
import RxSwift
import RxCocoa
import GoogleMaps

class MainViewController: UIViewController {
    @IBOutlet weak var map: UIView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var statusViewTopConstraint: NSLayoutConstraint!
    
    var viewModel: MainViewModelType!
    let disposeBag = DisposeBag()
    
    var mapView: GMSMapView!
    var targetMarker: GMSMarker?
    var path: GMSPath!
    var polyline: GMSPolyline!
    var viewParcels: TableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.locationManager.startUpdatingLocation()
        viewModel.locationManager.delegate = self
        statusViewTopConstraint.constant = (navigationController?.navigationBar.frame.height)!
    }
    
    func setUpMap() {
        // MARK - Create and setup map
        guard let location = viewModel.locationManager.location else { return }
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: viewModel.locationManager.location!.coordinate.latitude, zoom: viewModel.zoomLevel)
        
        
        mapView = GMSMapView.map(withFrame: map.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        targetMarker = GMSMarker()
        
        self.map.addSubview(mapView)
    }
    
    func bindRx() {
        btn.backgroundColor = .gray
        guard let location = viewModel.locationManager.location else { return }
        let navigationPayload = viewModel.bindRx(defaultLocation: location)(btn.rx.tap.asObservable())

        viewModel.titleToshow
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        viewModel.hideView
            .bind(to: statusView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.btnTitle
            .bind(to: btn.rx.title())
            .disposed(by: disposeBag)
        
        navigationPayload
            .payload
            .subscribe(onNext:{ item in
                self.statusLbl.text = item.type.rawValue
                self.addressLbl.text = item.geo.address
                self.changeBtnFunc(item: item)
            })
            .disposed(by: disposeBag)
        
        navigationPayload
            .payload
            .bind(to: viewModel.selectedItem)
            .disposed(by: disposeBag)
        
        navigationPayload
            .routes
            .subscribe(onNext: { route in
                self.mapView.clear()
                guard let steps = route.routes?[0].legs?[0].steps else { return }
                for step in steps {
                    guard let point = step.polyline?.points else { return }
                    self.drawPath(from: point)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func changeBtnFunc(item: NavigationPayload) {
        switch item.type {
        case .pickUp, .drop:
            viewParcels = viewModel.setView(frame: self.view.frame, item: item)
            guard let view = viewParcels else { return }
            self.map.addSubview(view)
        case .navigateToDrop, .navigateToPickUP:
            guard let viewToRemove = viewParcels else { return }
            viewToRemove.removeFromSuperview()
        }
    }
    
    func drewMarker() {
        targetMarker? = viewModel.targetMarker
        targetMarker?.map = mapView
    }
    
    //MARK:- Draw Path line
    
    func drawPath(from polyStr: String) {
        path = GMSPath(fromEncodedPath: polyStr)!
        polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3.0
        polyline.map = mapView 
        
        let currentZoom = mapView.camera.zoom
        mapView.animate(toZoom: currentZoom)
        drewMarker()
    }
}
// Delegates to handle events for the location manager.
extension MainViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = viewModel.locationManager.location else { return }
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.latitude, zoom: viewModel.zoomLevel)

        mapView.camera = camera
        mapView.animate(toLocation: location.coordinate)
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Check accuracy authorization
        let accuracy = manager.accuracyAuthorization
        switch accuracy {
        case .fullAccuracy:
            print("Location accuracy is precise.")
        case .reducedAccuracy:
            print("Location accuracy is not precise.")
        @unknown default:
            fatalError()
        }
        
        // Handle authorization status
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways:
            bindRx()
            setUpMap()
        case .authorizedWhenInUse:
            bindRx()
            setUpMap()
            print("Location status is OK.")
        @unknown default:
            fatalError()
        }
    }
}
