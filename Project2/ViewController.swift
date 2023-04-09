//
//  ViewController.swift
//  Project2
//
//  Created by Noel Abraham Biju on 2023-04-03.
//

import UIKit
import MapKit
class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var location: CLLocation = CLLocation(latitude: 43.0130, longitude: -81.1994)
    
    private let locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // print(locations.last)
        location = locations.last!
        setupMap(location: locations.last!)
        print("\(locations.last!.coordinate.latitude), \(locations.last!.coordinate.longitude)")
        loadWeatherData(search: "\(locations.last!.coordinate.latitude), \(locations.last!.coordinate.longitude)")
    }
    
    
    private func loadWeatherData(search: String?){
        guard let search = search else{
            return
        }
        guard let url: URL = getURL(query: search) else{
            print("Could not get URL")
            return
        }
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url) { [self]data, response, error in
            print("Networkcall complete")
            
            guard error == nil else{
                print("Received error")
                return
            }
            
            guard let data = data else{
                print("No data found")
                return
            }
            
            if let weatherResponse = self.parseJson(data: data){
                var color: UIColor = UIColor.systemBlue
                
                let annotation = MyAnnotation(coordinate: location.coordinate,
                                              title: "\(weatherResponse.current.condition.text)",
                                              subtitle: "My subtitle", glyphText: "\(weatherResponse.current.temp_c)",
                                              markerTintColor: UIColor.systemYellow)
                
                mapView.addAnnotation(annotation)
                print(weatherResponse.location.name)
                print(weatherResponse.current.temp_c)
            }
        }
        
        dataTask.resume()
    }
    
    
    private func getURL(query: String) -> URL? {
        let baseUrl = "https://api.weatherapi.com/v1"
        let currentEndpoint = "/forecast.json"
        let apiKey = "c142512622db4ee88b1171859232003"
        let days = "3"
        guard let url = "\(baseUrl)\(currentEndpoint)?key=\(apiKey)&q=\(query)&days=\(days)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        return URL(string: url)
    }
    
    
    private func parseJson(data: Data) -> WeatherResponse?{
        let decoder = JSONDecoder()
        var weather: WeatherResponse?
        do{
            weather = try decoder.decode(WeatherResponse.self, from: data)
        } catch {
            print("Error decoding")
        }
        return weather
    }
    
    
    private func setupMap( location: CLLocation){
        
        //set deligate
        mapView.delegate = self
        
        let radiusInMeters: CLLocationDistance = 1000
        
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: radiusInMeters,
                                        longitudinalMeters: radiusInMeters)
        
        mapView.setRegion(region, animated: true)
        
        //camera boundary
        
        let cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: region)
        mapView.setCameraBoundary(cameraBoundary, animated: true)
        
        //zoom Range
        
        let zoonRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 10000)
        mapView.setCameraZoomRange(zoonRange, animated: true)
    }
}

extension ViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let indentifier = "myIdentifier"
        var view: MKMarkerAnnotationView
        
        view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: indentifier)
        view.canShowCallout = true
        
        //set the position of callout
        view.calloutOffset = CGPoint(x: 0, y: 0)
        
        //add a button to right side of callout
        
        let button = UIButton(type: .detailDisclosure)
        view.rightCalloutAccessoryView = button
        
        //add an image to left side of callout
        let image = UIImage(systemName: "graduationcap.circle.fill")
        view.leftCalloutAccessoryView = UIImageView(image: image)
        
        //change colour of pin/marker"
        
        //change colour of accessories
        //view.tintColor = UIColor.systemRed
        
        if let myAnnotaion = annotation as? MyAnnotation{
            view.glyphText = myAnnotaion.glyphText
            view.markerTintColor = myAnnotaion.markerTintColor
        }
        return view
    }
}

class MyAnnotation: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var glyphText: String?
    var markerTintColor: UIColor?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, glyphText: String? = nil, markerTintColor: UIColor? = UIColor.systemCyan) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.glyphText =  glyphText
        self.markerTintColor = markerTintColor
        
        super.init()
    }
}

struct WeatherResponse: Decodable{
    let location: Location
    let current: Weather
}

struct Location: Decodable{
    let name: String
}

struct Weather: Decodable {
    let temp_c: Float
    let temp_f: Float
    let condition: WeatherCondition
}

struct WeatherCondition: Decodable {
    let text: String
    let code: Int
}

