//
//  MapViewController.swift
//  RestaurantViewer
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RxSwift

class MapViewController: UIViewController {
    private let mapView = MKMapView()
    private let viewModel: MapViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.locationManager.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Lifecycle

extension MapViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.frame = view.bounds
        view.addSubview(mapView)
        mapView.delegate = self
        mapView.register(RestaurantAnnotationView.self, forAnnotationViewWithReuseIdentifier: RestaurantAnnotationView.reuseIdentifier)
        viewModel.regionRelay.observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] mapRegion in
                self.mapView.setRegion(mapRegion, animated: true)
            })
            .disposed(by: disposeBag)
        viewModel.annotationsRelay.distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] annotations in
                let existingAnnotations = Set(self.mapView.annotations.compactMap({ $0 as? RestaurantAnnotation }))
                let updatedAnnotations = Set(annotations)
                let removedAnnotations = existingAnnotations.subtracting(updatedAnnotations)
                self.mapView.removeAnnotations(Array(removedAnnotations))
                let addedAnnotations = updatedAnnotations.subtracting(existingAnnotations)
                self.mapView.addAnnotations(Array(addedAnnotations))
            })
            .disposed(by: disposeBag)
        viewModel.alertRelay.distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] alertConfiguration in
                let showAlert = {
                    guard let alertConfiguration = alertConfiguration else {
                        return
                    }
                    let alertController = UIAlertController(title: alertConfiguration.title, message: alertConfiguration.message, preferredStyle: .alert)
                    alertConfiguration.actions.forEach { alertController.addAction($0) }
                    self.present(alertController, animated: true)
                }
                guard self.presentedViewController == nil else {
                    self.dismiss(animated: true, completion: showAlert)
                    return
                }
                showAlert()
            })
            .disposed(by: disposeBag)
        viewModel.handleViewDidLoad()
    }
}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        viewModel.handleUserLocations(locations)
    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return viewModel.viewForAnnotation(annotation, inMap: mapView)
    }
}
