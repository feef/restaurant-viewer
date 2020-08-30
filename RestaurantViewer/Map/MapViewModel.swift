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

protocol MapViewModelDelegate: class {
    func completeIfUnused()
    func showDetailsForRestaurant(withId id: String)
}

class MapViewModel {
    let alertRelay = BehaviorRelay<AlertConfiguration?>(value: nil)
    let annotationsRelay = PublishRelay<[RestaurantAnnotation]>()
    let regionRelay = BehaviorRelay<MKCoordinateRegion?>(value: nil)
    let titleRelay = BehaviorRelay<String?>(value: nil)
    
    private let fetchRegionRelay = BehaviorRelay<MKCoordinateRegion?>(value: nil)
    
    private let apiManager: APIManager
    private let disposeBag = DisposeBag()
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 8
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    private lazy var permissionAlertConfiguration: AlertConfiguration = {
        let cancelAction = UIAlertAction(title: "Close", style: .cancel, handler: { _ in self.alertRelay.accept(nil) })
        let openSettingsAction = UIAlertAction(title: "Go to settings", style: .default, handler: { _ in
            self.alertRelay.accept(nil)
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        })
        return AlertConfiguration(title: "Location permission required", message: "This app needs access to your current location to work properly. Please tap \"Go to settings\"and grant the app access to your location.", actions: [cancelAction, openSettingsAction])
    }()
    
    weak var delegate: MapViewModelDelegate?
    var locationManager: LocationManager
    
    init(delegate: MapViewModelDelegate?, apiManager: APIManager, locationManager: LocationManager) {
        self.delegate = delegate
        self.apiManager = apiManager
        self.locationManager = locationManager
        fetchRegionRelay.distinctUntilChanged()
            .debounce(Constants.regionChangeDebounceTime, scheduler: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] mapRegion in
                    guard
                        self?.regionRelay.value != mapRegion,
                        let mapRegion = mapRegion
                    else {
                        return
                    }
                    let center = mapRegion.center
                    let radius = CLLocation(latitude: center.latitude, longitude: center.longitude).distance(from: CLLocation(latitude: center.latitude, longitude: center.longitude - mapRegion.span.longitudeDelta / 2))
                    self?.fetchRestaurants(withCenterCoordinate: center, radius: radius, updateMapRegionOnSuccess: false)
                }
            )
            .disposed(by: disposeBag)
    }
}

// MARK: - Lifecycle handling

extension MapViewModel {
    func handleViewDidLoad() {
        locationManager.startUpdatingLocation()
        switch locationManager.authorizationStatus {
            case .allowed:()
            case .unknown:
                locationManager.requestAuthorization()
            case .denied:
                alertRelay.accept(permissionAlertConfiguration)
        }
    }
    
    func handleViewDidDisappear() {
        delegate?.completeIfUnused()
    }
}

// MARK: - Other

extension MapViewModel {
    func handleUserLocations(_ locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        fetchRestaurants(withCenterCoordinate: location.coordinate)
    }
    
    func handleAnnotationViewSelection(_ annotationView: MKAnnotationView, inMap map: MKMapView) {
        guard let restaurantId = (annotationView.annotation as? RestaurantAnnotation)?.restaurantID else {
            return
        }
        map.deselectAnnotation(annotationView.annotation, animated: true)
        delegate?.showDetailsForRestaurant(withId: restaurantId)
    }
    
    func handleMapRegionChange(_ region: MKCoordinateRegion) {
        fetchRegionRelay.accept(region)
    }
    
    func viewForAnnotation(_ annotation: MKAnnotation, inMap map: MKMapView) -> MKAnnotationView? {
        guard let restaurantAnnotation = annotation as? RestaurantAnnotation else {
            return nil
        }
        return map.dequeueReusableAnnotationView(withIdentifier: RestaurantAnnotationView.reuseIdentifier, for: restaurantAnnotation)
    }
}

// MARK: - Private

extension MapViewModel {
    private func fetchRestaurants(withCenterCoordinate centerCoordinate: CLLocationCoordinate2D, radius: Double = Constants.defaultFetchRadius, updateMapRegionOnSuccess: Bool = true) {
        titleRelay.accept(Constants.loadingText)
        apiManager.fetchRestaurants(aroundCoordinate: centerCoordinate, withRadius: radius)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] restaurantLocations in
                    let annotations = restaurantLocations.compactMap { RestaurantAnnotation(restaurantLocation: $0) }
                    self?.annotationsRelay.accept(annotations)
                    if updateMapRegionOnSuccess {
                        self?.regionRelay.accept(MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: radius * 2, longitudinalMeters: radius * 2))
                    }
                    let latitudeString = self?.numberFormatter.string(from: centerCoordinate.latitude as NSNumber) ?? ""
                    let longitudeString = self?.numberFormatter.string(from: centerCoordinate.longitude as NSNumber) ?? ""
                    let populatedText = String(format: Constants.populatedTextFormat, latitudeString, longitudeString)
                    self?.titleRelay.accept(populatedText)
                },
                onError: { [weak self] _ in
                    self?.titleRelay.accept(Constants.failedToLoadText)
                }
            )
            .disposed(by: disposeBag)
    }
}

// MARK: - Internal types

extension MapViewModel {
    private struct Constants {
        static let defaultFetchRadius: Double = 250
        static let regionChangeDebounceTime = DispatchTimeInterval.milliseconds(300)
        static let failedToLoadText = "Failed to load"
        static let loadingText = "Loading..."
        static let populatedTextFormat = "Loaded (%@, %@)"
    }
}
