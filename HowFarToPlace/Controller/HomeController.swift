//
//  HomeController.swift
//  HowFarToPlace
//
//  Created by Vũ Tựu on 9/7/20.
//  Copyright © 2020 Vũ Tựu. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation
import GeoFire// vicinity area


private let reuseIdentifier = "LocationCell"
private let annotationIndentifier = "DriverAnnotation"

private enum ActionButtonConfiguration {
    case showMenu
    case dismissActionView
    
    init() {
        self = .showMenu
    }
}
class HomeController: UIViewController, CLLocationManagerDelegate  {
    
    
    
    let an = MKPointAnnotation()
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    private let inputActivationView = LocationInputActivationView ()
    private let locationInputView = LocationInputView ()
    private let tableView = UITableView()
    
    private var searchResults = [MKPlacemark]()
    private var route: MKRoute?
    private var actionButtonConfig = ActionButtonConfiguration()
    private var rideActionView = RideActionView()
    private let rideActionViewHeight: CGFloat = 200
    private let locationInputViewHeight: CGFloat =  200
    //MARK: - Lifecycle
    
    
    override func viewWillAppear(_ animated: Bool)  {
        // Start get the location on viewWillAppear
        locationManager!.startUpdatingLocation()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        mapView.delegate = self
        
        
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        
        checkIfUserIsLogIn()
        //        signOut()
        enableLocationServices()
        
        configureTableView()
        
        configRideActionView()
        
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 16, width: 30, height: 30)
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 60)
        inputActivationView.alpha = 1
        inputActivationView.delegate = self
        
    }
    //MARK: - Properties
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(actionBtnPressed), for: .touchUpInside)
        return button
    }()
    private let loginButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("sign out", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        button.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        return button
    }()
    
    public var user: User?{
        didSet {
            locationInputView.user = user
            if user?.accountType == .passenger {
            }
            
        }
    }
    //MARK: - selected
    @objc func actionBtnPressed(){
        switch actionButtonConfig {
        case .showMenu:
            print("DEBUG: is show menu")
        case .dismissActionView:
            print("DEBUG: dismiss")
            removeAnnotationsAndOverlays()
            self.rideActionView.distanceLabel.text = "press button below to get a distance"
            mapView.showAnnotations(mapView.annotations, animated: true)
            
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
                self.configureActionButton(config: .showMenu)
                self.presentRideActionView(shouldShow: false)
                self.rideActionView.alpha = 0
            }
        }
    }
    
    //MARK: - API
    func fetchUserIsData(){
        guard let currentUid = Auth.auth().currentUser?.uid else {return }
        Service.shared.fetchUserData(uid: currentUid) { (user) in
            print("DEBUG: handle fetchUserIsData driver ")
            self.user = user
        }
        
    }
    
    
    
    
    
    func checkIfUserIsLogIn(){
        if Auth.auth().currentUser?.uid == nil{
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
            print("user not logged in...")
        }else{
            configure()
            print("user id is \(String(describing: Auth.auth().currentUser?.uid))")
        }
    }
    @objc func signOut(){
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
            checkIfUserIsLogIn()
        }
        catch {
            print("Error Sign Out")
        }
    }
    //MARK: - helper
    
    func configRideActionView(){
        view.addSubview(rideActionView)
        rideActionView.alpha = 0
        rideActionView.delegate = self
        rideActionView.anchor( left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 6, paddingBottom: 8, paddingRight: 6, height: 150)
    }
    
    fileprivate func configureActionButton(config: ActionButtonConfiguration) {
        switch config {
        case .showMenu:
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .showMenu
        case .dismissActionView:
            actionButton.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            actionButtonConfig = .dismissActionView
            
        }
    }
    func configure(){
        fetchUserIsData()
    }
    
    func configureInputField(){
        locationInputView.delegate = self
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: locationInputViewHeight)
        locationInputView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.locationInputView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.tableView.frame.origin.y = self.locationInputViewHeight
            }
            
        }
        
    }
    func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier )
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0 , y: view.frame.height , width: view.frame.width, height: height)
        view.addSubview(tableView)
    }
    func dismissLocationView(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.inputActivationView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview()
        }, completion: completion)
    }
    func removeAnnotationsAndOverlays() {
        mapView.annotations.forEach { (annotation) in
            if let anno = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(anno)
            }
        }
        
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
    func generatePolyline(toDestination destination: MKMapItem) {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { (response, error) in
            guard let response = response else { return }
            self.route = response.routes[0]
            guard let polyline = self.route?.polyline else { return }
            self.mapView.addOverlay(polyline)
        }
    }
    
    func presentRideActionView(shouldShow: Bool){
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y =  self.view.frame.height - self.rideActionViewHeight
        }
    }
}
// MARK: - CLLocationManagerDelegate

extension HomeController{
    func enableLocationServices() {
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("DEBUG: Not determined..")
            locationManager!.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("DEBUG: Auth always..")
            locationManager!.startUpdatingLocation()
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: Auth when in use..")
            locationManager!.requestAlwaysAuthorization()
            
        @unknown default:
            break
        }
    }
    
}
extension HomeController: LocationInputActivationViewDelegate{
    func presentLocationInputView() {
        inputActivationView.alpha = 1
        configureInputField()
    }
    
    
    
}

//MARK: - LocationInputViewDelegate
extension HomeController: LocationInputViewDelegate{
    func executeSearch(query: String) {
        searchBy(naturalLanguageQuery: query) { (results) in
            
            self.searchResults = results
            self.tableView.reloadData()
        }
    }
    
    
    func dismissLocationInputView() {
        dismissLocationView { _ in
            UIView.animate(withDuration: 0.5, animations: {
                self.inputActivationView.alpha = 1
            })
        }
    }
    
    
}
// MARK: - TableViewSetDelegate
extension HomeController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Place"
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        cell.placemark = searchResults[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlacemark = searchResults[indexPath.row]
        configureActionButton(config: .dismissActionView)
        let destination = MKMapItem(placemark: selectedPlacemark)
        generatePolyline(toDestination: destination)
        dismissLocationView{_ in
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedPlacemark.coordinate
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
            self.rideActionView.alpha = 1
            self.presentRideActionView(shouldShow: true)
            self.rideActionView.destination = selectedPlacemark
        }
    }
    
}
// MARK: - mapDelegate
extension HomeController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .mainBlueTint
            lineRenderer.lineWidth = 4
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
}

//  MARK: - map helper function
private extension HomeController {
    func searchBy(naturalLanguageQuery: String, completion: @escaping([MKPlacemark]) -> Void) {
        var results = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else { return }
            
            response.mapItems.forEach({ item in
                results.append(item.placemark)
            })
            
            completion(results)
        }
    }}

//  MARK: - RideActionViewDelegate

extension HomeController: RideActionViewDelegate {
    func uploadTrip(_ view: RideActionView) {
        guard let pickupCoordinates = locationManager?.location?.coordinate else { return }
        guard let destinationCoordinates = view.destination?.coordinate else { return }
        let coordinateA = CLLocation(latitude: pickupCoordinates.latitude, longitude: pickupCoordinates.longitude)
        let coordinateB = CLLocation(latitude: destinationCoordinates.latitude, longitude: destinationCoordinates.longitude)
        let distanceInMeters = coordinateA.distance(from: coordinateB) // result is in meters
       Distance.distance = "Distance is:    " + String(format: "%.2f", distanceInMeters/1000) + "         Kilometers"
        print("DEBUG: abcd \(distanceInMeters)")
        
        Service.shared.uploadTrip(pickupCoordinates, destinationCoordinates) { (error, ref) in
            if let error = error{
                print("DEBUG: Failed to upload trip with error \(error)")
                return
            }
            
            print("DEBUG: Did load trip successfully..")
        }
    }
    
}
