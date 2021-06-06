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
    
    @IBOutlet weak var btn: UIButton!
    var viewModel: MainViewModelType!
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var map: UIView!
    
    var locationManager: CLLocationManager!
    var mapView: GMSMapView!
    @IBOutlet weak var statusView: UIView!
    
    var targetMarker: GMSMarker?
    var path: GMSPath!
    var polyline: GMSPolyline!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    var viewTest: TableView?

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = viewModel.locationManager
        locationManager.startUpdatingLocation()
        locationManager.delegate = self

    }
    
    func setUpMap() {
        // MARK - Create and setup map
        let camera = GMSCameraPosition.camera(withLatitude: locationManager.location!.coordinate.latitude, longitude: locationManager.location!.coordinate.latitude, zoom: viewModel.zoomLevel)
        
        
        mapView = GMSMapView.map(withFrame: map.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        targetMarker = GMSMarker()
                
        self.map.addSubview(mapView)
    }
    
    func bindRx() {
        btn.backgroundColor = .gray
        let myLocation = locationManager.location
        let navigationPayload = viewModel.bindRx(defaultLocation: myLocation!)(btn.rx.tap.asObservable())

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
                for step in route.routes[0].legs[0].steps {
                    self.drawPath(from: step.polyline.points)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func changeBtnFunc(item: NavigationPayload) {
        switch item.type {
        case .pickUp, .drop:
            let viewModel = ParcelsViewModel(items: item)
            viewTest = TableView(frame: self.view.frame, viewModel: viewModel)
            if let addView = viewTest {
                self.map.addSubview(addView)
            }
        case .navigateToDrop, .navigateToPickUP:
            if viewTest != nil {
                self.viewTest?.removeFromSuperview()
            }
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
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: locationManager.location!.coordinate.latitude, longitude: locationManager.location!.coordinate.latitude, zoom: viewModel.zoomLevel)
        
        mapView.camera = camera
        mapView.animate(toLocation: locationManager.location!.coordinate)
        
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
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
