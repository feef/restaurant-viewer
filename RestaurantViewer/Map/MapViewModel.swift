//
//  MapViewModel.swift
//  RestaurantViewer
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import RxRelay
import RxSwift
import CoreLocation
import MapKit

class MapViewModel {
    let alertRelay = BehaviorRelay<AlertConfiguration?>(value: nil)
    let annotationsRelay = PublishRelay<[RestaurantAnnotation]>()
    let regionRelay = PublishRelay<MKCoordinateRegion>()
    var locationManager: LocationManager
    
    private let apiManager: APIManager
    private let disposeBag = DisposeBag()
    
    private lazy var permissionAlertConfiguration: AlertConfiguration = {
        let cancelAction = UIAlertAction(title: "Close", style: .cancel, handler: { _ in self.alertRelay.accept(nil) })
        let openSettingsAction = UIAlertAction(title: "Go to settings", style: .default, handler: { _ in
            self.alertRelay.accept(nil)
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        })
        return AlertConfiguration(title: "Location permission required", message: "This app needs access to your current location to work properly. Please tap \"Go to settings\"and grant the app access to your location.", actions: [cancelAction, openSettingsAction])
    }()
    
    init(apiManager: APIManager, locationManager: LocationManager) {
        self.apiManager = apiManager
        self.locationManager = locationManager
    }
}

// MARK: - Lifecycle handling

extension MapViewModel {
    func handleViewDidLoad() {
        switch locationManager.authorizationStatus {
            case .allowed:
                locationManager.startUpdatingLocation()
            case .unknown:
                locationManager.requestAuthorization()
            case .denied:
                alertRelay.accept(permissionAlertConfiguration)
        }
    }
}

// MARK: - Other

extension MapViewModel {
    func handleUserLocations(_ locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        let centerCoordinate = location.coordinate
        let radius = Constants.defaultFetchRadius
        apiManager.fetchRestaurants(aroundCoordinate: centerCoordinate, withRadius: radius)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] restaurantLocations in
                let annotations = restaurantLocations.compactMap { RestaurantAnnotation(restaurantLocation: $0) }
                self?.annotationsRelay.accept(annotations)
                self?.regionRelay.accept(MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: radius * 2, longitudinalMeters: radius * 2))
            })
            .disposed(by: disposeBag)
    }
    
    func viewForAnnotation(_ annotation: MKAnnotation, inMap map: MKMapView) -> MKAnnotationView {
        return map.dequeueReusableAnnotationView(withIdentifier: RestaurantAnnotationView.reuseIdentifier, for: annotation)
    }
}

// MARK: - Internal types

extension MapViewModel {
    private struct Constants {
        static let defaultFetchRadius: Double = 250
    }
}
