//
//  ViewController.swift
//  map
//
//  Created by Hosam Elnabawy on 4/28/20.
//  Copyright © 2020 Hosam Elnabawy. All rights reserved.
//

import UIKit
import MapKit


class MapVC: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var appMap: MKMapView!
    @IBOutlet weak var pinBtn: RoundedButton!
    @IBOutlet weak var appMapBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imagesView: UIView!
    
    
    
    // MARK: - Controller Properties
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    
    let screenSize = UIScreen.main.bounds
    var spinner: UIActivityIndicatorView?
    var progressLbl: UILabel?
    
    var collectionFlowLayout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView!
    var flickerApi: FlickerApi!
    
    var imagesUrls: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appMap.delegate = self
        locationManager.delegate = self
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 40, width: view.frame.width, height: view.frame.height - 40), collectionViewLayout: collectionFlowLayout)
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: Identifiers.imageCollectionCell.rawValue)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = #colorLiteral(red: 0.9797945749, green: 0.9797945749, blue: 0.9797945749, alpha: 1)
        imagesView.addSubview(collectionView)
        
        configureLocationService()
        
        addSwipeGesture()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.imageViewerIdentifier.rawValue {
            print("Navigate to Image Viewer Page")
            guard let page = segue.destination as? ImageViewer, let image = sender as? UIImage else {return}
            
            page.initData(for: image)
        }
    }
    
//    func addTabGesture() {
//        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(MapVC.dropPin))
//        doubleTap.numberOfTouchesRequired = 2
//        doubleTap.delegate = self
//        print("Add Double Tap")
//        appMap.addGestureRecognizer(doubleTap)
//    }
    
    
    func addSwipeGesture() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(MapVC.onSwipe))
        
        swipe.direction = .down
        imagesView.addGestureRecognizer(swipe)
    }
    
    
    // MARK: - Actions
    @IBAction func centerMapOnPress(_ sender: RoundedButton) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        } else {
            configureLocationService()
        }
    }
    
    @IBAction func onTapOnMap(_ sender: UITapGestureRecognizer) {
        print("Drop Pin..")
        removeAnnotation()
        
        let touchPoint = sender.location(in: appMap)
        let touchCoordinates = appMap.convert(touchPoint, toCoordinateFrom: appMap)
        
        createPin(by: touchCoordinates)
        setRegion(of: touchCoordinates)
    }
    
    
    // MARK: - View Animations
    
    func animateViewUp() {
        print("animating View")
        removeSpinner()
        removeProgressLabel()
        self.appMapBottomConstraint.constant = -300
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }, completion: { finished in
            print("Opening Images View:", finished)
            self.addSpinner()
            self.addProgressLabel()
            self.progressLbl?.text = "0/\(self.flickerApi.numberOfImages) Images Loaded."
        })
    }
    
    func animateViewDown() {
        print("animating View")

        self.appMapBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }, completion: { finished in
            print("Dsimissing Images View: ", finished)
            self.removeSpinner()
            self.removeProgressLabel()
        })
    }
    
    
    // MARK: - Map Helper Functions
    private func createPin(by coordinate: CLLocationCoordinate2D) {
        
        let annotation = DroppablePin(coordinate: coordinate, identifier: Identifiers.droppablePin.rawValue)
        
        appMap.addAnnotation(annotation)
        
        
        // Handle Loading Images From API
        if flickerApi == nil {
            flickerApi = FlickerApi(annotation: annotation, numberOfImages: 40, radiusInKm: 1)
        } else {
            flickerApi.setAnnotation(annotation: annotation)
            flickerApi.images = []
        }

        collectionView.reloadData()
        
        flickerApi.getUrls(handler: { (status) in
            print("urls status", status)
            if status == true  {
                print("Numbers of Images to load \(self.flickerApi.imagesUrls.count)")
                if self.flickerApi.imagesUrls.count > 1 {
                    
                self.flickerApi.loadImages{ s in
                    self.progressLbl?.text = "\(self.flickerApi.imageLoadCount) Images Loaded."
                    if self.flickerApi.images.count == self.flickerApi.imagesUrls.count {
                        self.removeProgressLabel()
                        self.removeSpinner()
                        self.collectionView.reloadData()
                    }
                }
                } else {
                    self.progressLbl?.text = "No Available Images, Try another Location"
                    self.removeSpinner()
                }
            } else {
                print("Error Getting Images Urls")
            }
        })
        
        print(flickerApi.url)
        
        animateViewUp()
        
    }
    
    
    private func setRegion(of coordinate: CLLocationCoordinate2D) {
        let coordinateregion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        appMap.setRegion(coordinateregion, animated: true)
    }
    
    
    func removeAnnotation() -> Void {
        for annotation in appMap.annotations {
            appMap.removeAnnotation(annotation)
        }
    }
    
    
    private func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2 ), y: imagesView.frame.height / 2)
        spinner?.color = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        spinner?.style = .medium
        spinner?.accessibilityLabel = "Loading..."
        spinner?.startAnimating()
        imagesView.addSubview(spinner!)
    }
    
    private func removeSpinner() {
        if spinner != nil && spinner?.isAnimating == true {
            spinner?.stopAnimating()
            spinner?.removeFromSuperview()
        }
    }
    
    
    private func addProgressLabel() {
        progressLbl = UILabel(frame: CGRect(x: 0, y: (imagesView.frame.height / 2) + 20, width: screenSize.width, height: 30))
        progressLbl?.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        progressLbl?.textAlignment = .center
        progressLbl?.font = UIFont(name: "Avenier Next", size: 10)
//        progressLbl?.text = "3/20 Images Loaded."
        imagesView.addSubview(progressLbl!)
        
    }
    private func removeProgressLabel() {
        if progressLbl != nil {
            progressLbl?.removeFromSuperview()
        }
    }
    
    @objc func onSwipe() {
        print("Swipping")
        animateViewDown()
    }
}



// MARK: - Extensions

extension MapVC: MKMapViewDelegate {
    
    func centerMapOnUserLocation() {
        let coordinate = CLLocationCoordinate2D(latitude: 31.2209496, longitude: 29.9589297)
        
        // Uncommit if you use laptop or any device support GPS
//        guard let coordinate = locationManager.location?.coordinate else {
//            print("No Location")
//            return
//        }
        print(coordinate)
        setRegion(of: coordinate)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Identifiers.droppablePin.rawValue)
        pinAnnotation.tintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    
    
}

extension MapVC: CLLocationManagerDelegate {
    
    func configureLocationService() {
        // Check whether or not the app is authorized to use location service
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            // do other stuff
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}


extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flickerApi?.images.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.imageCollectionCell.rawValue, for: indexPath) as? PhotoCollectionViewCell else {
            
            
            return UICollectionViewCell()
        }
        if flickerApi != nil {
            let image = UIImageView(image: flickerApi.images[indexPath.row])
            cell.addSubview(image)
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Select: \(indexPath.row)")
        
        let image = flickerApi.images[indexPath.row]
        
        guard let imageViewVC = storyboard?.instantiateViewController(withIdentifier: Identifiers.ImageViewerId.rawValue) as? ImageViewer
            else {return }
        
        imageViewVC.modalPresentationStyle = .fullScreen
        
        imageViewVC.initData(for: image)
        
        self.present(imageViewVC, animated: true, completion: nil)
        
//        performSegue(withIdentifier: Identifiers.imageViewerIdentifier.rawValue, sender: image)
    }
    
}


