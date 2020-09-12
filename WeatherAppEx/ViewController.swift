//
//  ViewController.swift
//  WeatherAppEx
//
//  Created by Pratik on 12/09/20.
//  Copyright © 2020 prk. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import GooglePlaces
import GoogleMaps
import MapKit


class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    let APIKEY = "5a364d387a984a75481eaedde610fb1f"
    let BASEURL = "https://api.openweathermap.org/data/2.5/"
    let WEATHER = "weather?"
    var lat = 0.0
    var lng = 0.0
    var units = "metric"
    var unit = "C"
    var locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        requestLocationPermision()
        let gestureZ = UILongPressGestureRecognizer(target: self, action: #selector(self.revealRegionDetailsWithLongPressOnMap(sender:)))
        mapView.addGestureRecognizer(gestureZ)
    }
    @IBAction func revealRegionDetailsWithLongPressOnMap(sender: UILongPressGestureRecognizer) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ViewController1") as! ViewController1
        if sender.state != UIGestureRecognizer.State.began { return }
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
        vc.Lat = "\(locationCoordinate.latitude)"
        vc.Long = "\(locationCoordinate.longitude)"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func requestLocationPermision() {
        
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            lat = location.coordinate.latitude
            lng = location.coordinate.longitude
            StartloadCurrentWeather()
            let span = MKCoordinateSpan(latitudeDelta: lat, longitudeDelta: lng)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            //            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                showAlert("Please Allow the Location Permision to get weather of your city")
            case .authorizedAlways, .authorizedWhenInUse:
                print("locationEnabled")
            @unknown default:
                fatalError()
            }
        } else {
            showAlert("Please Turn ON the location services on your device")
            print("locationDisabled")
        }
        manager.stopUpdatingLocation()
    }
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        print("You have lat and long")
    }
    class func isLocationEnabled() -> (status: Bool, message: String) {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                return (false,"No access")
            case .authorizedAlways, .authorizedWhenInUse:
                return(true,"Access")
            @unknown default:
                fatalError()
            }
        } else {
            return(false,"Turn On Location Services to Allow App to Determine Your Location")
        }
    }
    
    
    func StartloadCurrentWeather() {
        let url = "\(BASEURL)\(WEATHER)lat=\(lat)&lon=\(lng)&appid=\(APIKEY)"
        
        AF.request(url,method: .get).responseJSON { (response) in
            
            switch response.result {
            case .success:
                guard let json = response.data else {return}
                do {
                    let decoder = JSONDecoder()
                    let data = try decoder.decode(WEATHERS.self, from: json)
                    print(data)
                    
                    
                }
                catch let error {
                    print(error)
                }
            case .failure(_):
                print("Error : ")
                
            }
            
            DispatchQueue.main.async {
                //self.cvRef.reloadData()
            }
            
        }
        
        
        
    }
    
    
    
    
    func showAlert(_ message:String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

struct WEATHERS : Codable {
    var weather:[DATA]?
    var main: MainData?
    var name: String?
}
struct DATA : Codable {
    var main: String?
    var description: String?
}
struct MainData : Codable {
    var temp_min: Double?
    var temp_max: Double?
}
