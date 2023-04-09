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
    var location: CLLocation?
    var weatherRes: WeatherResponse?
    
    private let locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last!
        setupMap(location: locations.last!)
        loadWeatherData(search: "\(locations.last!.coordinate.latitude), \(locations.last!.coordinate.longitude)") { result in
            
        }
    }
    
    
    private func loadWeatherData(search: String?,
                                 completion: @escaping (Result<WeatherResponse, Error>) -> Void){
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
                var annotationColor: UIColor = UIColor.systemBlue
                var weatherImage: UIImage = UIImage(systemName: "wind")!
                let currentTemp = weatherResponse.current.temp_c
                let currentWeatherCondition = weatherResponse.current.condition.text
                
                
                if(currentTemp > 35){
                    annotationColor = UIColor.systemRed
                }else if(currentTemp > 24 && currentTemp < 31){
                    annotationColor = UIColor.orange
                }else if(currentTemp > 16 && currentTemp < 25){
                    annotationColor = UIColor.systemYellow
                }else if(currentTemp > 11 && currentTemp < 17){
                    annotationColor = UIColor.systemCyan
                }else if(currentTemp >= 0 && currentTemp < 12){
                    annotationColor = UIColor.blue
                }else if(currentTemp < 0){
                    annotationColor = UIColor.purple
                }
                
                let config = UIImage.SymbolConfiguration(paletteColors: [ .black, .yellow])
                
                switch(weatherResponse.current.condition.code){
                    
                case 1030 : weatherImage = UIImage(systemName: "wind", withConfiguration: config)!
                    
                case 1000 : weatherImage = UIImage(systemName: "sun.max", withConfiguration: config)!
                    
                case 1003 : weatherImage = UIImage(systemName: "cloud.fill", withConfiguration: config)!
                    
                case 1006 : weatherImage = UIImage(systemName: "cloud.fill", withConfiguration: config)!
                    
                case 1135 : weatherImage = UIImage(systemName: "cloud.fog.fill", withConfiguration: config)!

                case 1114 : weatherImage = UIImage(systemName: "wind.snow", withConfiguration: config)!
                                        
                case 1183 : weatherImage = UIImage(systemName: "cloud.rain", withConfiguration: config)!
                    
                case 1240 : weatherImage = UIImage(systemName: "cloud.rain.fill", withConfiguration: config)!
                    
                case 1163 : weatherImage = UIImage(systemName: "cloud.drizzle", withConfiguration: config)!
                    
                case 1279 : weatherImage = UIImage(systemName: "cloud.bolt.rain", withConfiguration: config)!
                    
                case 1255 : weatherImage = UIImage(systemName: "cloud.snow.fill", withConfiguration: config)!
                    
                case 1072 : weatherImage = UIImage(systemName: "cloud.sleet", withConfiguration: config)!
                    
                case 1066 : weatherImage = UIImage(systemName: "cloud.snow", withConfiguration: config)!
                    
                default: print("Error in switch")
                }
                
                guard let location = location else {
                    return
                }
                
                let annotation = MyAnnotation(coordinate: location.coordinate,
                                              title: "\(currentWeatherCondition)",
                                              subtitle: "Temperature:\(currentTemp) Feels like:\(weatherResponse.current.feelslike_c)", glyphText: "\(Int(currentTemp))°",
                                              markerTintColor: annotationColor, tintColor: annotationColor,image: weatherImage)
                
                mapView.addAnnotation(annotation)
                completion(.success(weatherResponse))
            }
            
           
            
            
        }
        
        dataTask.resume()
    }
    


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var viewControllerForecast = segue.destination as! ForecastViewController
        
        if let location = location {
            loadWeatherData(search: "\(location.coordinate.latitude), \(location.coordinate.longitude)") { result in
            
            switch result {
            case .success(let data):
                viewControllerForecast.weatherResponse = data
                viewControllerForecast.loadWeatherData()
            case .failure(let error):
                print(error)
                
            }
        }}
      
    }
    
    private func getURL(query: String) -> URL? {
        let baseUrl = "https://api.weatherapi.com/v1"
        let currentEndpoint = "/forecast.json"
        let apiKey = "c142512622db4ee88b1171859232003"
        let days = "7"
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.mapView.setRegion(region, animated: true)
        }
        
        
        
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
        //let image = UIImage(systemName: "graduationcap.circle.fill")
        
        
        //change colour of pin/marker"
        
        //change colour of accessories
        //view.tintColor = UIColor.systemRed
        
        if let myAnnotaion = annotation as? MyAnnotation{
            view.glyphText = myAnnotaion.glyphText
            view.markerTintColor = myAnnotaion.markerTintColor
            view.tintColor = myAnnotaion.tintColor
            view.leftCalloutAccessoryView = UIImageView(image: myAnnotaion.image)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "goToWeatherScreen", sender: self)
    }
}

class MyAnnotation: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var glyphText: String?
    var markerTintColor: UIColor?
    var tintColor: UIColor?
    var image : UIImage?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, glyphText: String? = nil, markerTintColor: UIColor? = UIColor.systemCyan, tintColor: UIColor? = UIColor.systemCyan, image: UIImage?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.glyphText =  glyphText
        self.markerTintColor = markerTintColor
        self.tintColor = tintColor
        self.image = image
        
        super.init()
    }
}

struct WeatherResponse: Decodable{
    let location: Location
    let current: Weather
    let forecast: Forecast
}

struct Location: Decodable{
    let name: String
}

struct Weather: Decodable {
    let temp_c: Float
    let temp_f: Float
    let condition: WeatherCondition
    let feelslike_c: Float
    let feelslike_f: Float
    
}

struct WeatherCondition: Decodable {
    let text: String
    let code: Int
}

struct Forecast: Decodable{
    let forecastday: [ForecastDay]
    
}

struct ForecastDay: Decodable{
    let day: Day
    let date: String
}

struct Day: Decodable{
    let maxtemp_c: Float
    let mintemp_c: Float
    let avgtemp_c: Float
    let condition: WeatherCondition
}



