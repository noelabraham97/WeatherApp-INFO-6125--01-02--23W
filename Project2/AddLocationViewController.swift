//
//  AddLocationViewController.swift
//  Project2
//
//  Created by Noel Abraham Biju on 2023-04-09.
//

import UIKit

import MapKit
import CoreLocation


class AddLocationViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    
    
    @IBOutlet weak var weatherLocationLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    weak var delegate: LocationDelegate?
    
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        displayWeatherImage()
        searchTextField.delegate = self
        
        let currentLocationManager = self
        currentLocationManager.getCurrentLocation()
        
    }
    
    private func getCurrentLocation(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager.startUpdatingLocation()
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        loadWeatherData(search: "\(locValue.latitude),\(locValue.longitude)") { result in
            
        }
        
        locationManager.stopUpdatingLocation()
        
    }
    
    private func displayWeatherImage(){
        let config = UIImage.SymbolConfiguration(paletteColors: [ .systemYellow, .systemYellow, .systemYellow])
        weatherImage.preferredSymbolConfiguration = config
        weatherImage.image = UIImage(systemName: "sun.max.circle")
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        
        return true
    }
    
    
    

    @IBAction func onSearchButtonTapped(_ sender: UIButton) {
        loadWeatherData(search: searchTextField.text) { result in
            
        }
    }
        
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true)
        
      
    }
    
    func loadWeatherData(search: String?,
                             completion: @escaping (Result<WeatherResponse, Error>) -> Void){
        guard let search = search else {
            return
        }
        
        
        //Step 1: Get URL
        guard let url = getURL(query: search) else{
            print("Could not get URL")
            return
        }
        
        //Step 2: Create URLSession
        let session = URLSession.shared
        
        //step 3:
        let dataTask = session.dataTask(with: url) { data, response, error in
            // network call finished
            print("Network call complete")
            
            guard error == nil else{
                print("Recived Error")
                return
            }
            
            guard let data = data else{
                print("No data found")
                return
            }
            
            if let weatherResponse = self.parseJson(data: data){
                completion(.success(weatherResponse))
                print(weatherResponse.location.name)
                print(weatherResponse.current.temp_c)
                DispatchQueue.main.async {
                    self.weatherLocationLabel.text = weatherResponse.location.name
                    self.currentTemperatureLabel.text = "\(Int(weatherResponse.current.temp_c))"
                    self.weatherConditionLabel.text = weatherResponse.current.condition.text
                    
                    
                    let configuration = UIImage.SymbolConfiguration(paletteColors: [.blue])
                    
                    self.weatherImage.preferredSymbolConfiguration = configuration
                    print(weatherResponse.current.condition.code)
                    switch(weatherResponse.current.condition.code){
                        
                    case 1030 : self.weatherImage.image = UIImage(systemName: "wind")
                        self.weatherConditionLabel.text = weatherResponse.current.condition.text
                        
                    case 1000 : self.weatherImage.image = UIImage(systemName: "sun.max")
                        self.weatherConditionLabel.text = weatherResponse.current.condition.text
                        
                    case 1003 : self.weatherImage.image = UIImage(systemName: "cloud.fill")
                        self.weatherConditionLabel.text = weatherResponse.current.condition.text
                        
                    case 1006 : self.weatherImage.image = UIImage(systemName: "cloud.fill")
                        self.weatherConditionLabel.text = weatherResponse.current.condition.text
                        
                    case 1135 : self.weatherImage.image = UIImage(systemName: "cloud.fog.fill")
                        self.weatherConditionLabel.text = weatherResponse.current.condition.text
                        
                    case 1114 : self.weatherImage.image = UIImage(systemName: "wind.snow")
                        self.weatherConditionLabel.text = weatherResponse.current.condition.text
                        
                    case 1183 : self.weatherImage.image = UIImage(systemName: "cloud.rain")
                        self.weatherConditionLabel.text = weatherResponse.current.condition.text
                        
                    case 1240 : self.weatherImage.image = UIImage(systemName: "cloud.rain.fill")
                        self.weatherConditionLabel.text = weatherResponse.current.condition.text
                        
                    case 1163 : self.weatherImage.image = UIImage(systemName: "cloud.drizzle")
                        self.weatherConditionLabel.text = weatherResponse.current.condition.text
                        
                    case 1279 : self.weatherImage.image = UIImage(systemName: "cloud.bolt.rain")
                        self.weatherConditionLabel.text = weatherResponse.current.condition.text
                        
                    case 1255 : self.weatherImage.image = UIImage(systemName: "cloud.snow.fill")
                        self.weatherConditionLabel.text = weatherResponse.current.condition.text
                        
                    case 1072 : self.weatherImage.image = UIImage(systemName: "cloud.sleet")
                        self.weatherConditionLabel.text = weatherResponse.current.condition.text
                        
                    case 1066 : self.weatherImage.image = UIImage(systemName: "cloud.snow")
                        self.weatherConditionLabel.text = weatherResponse.current.condition.text
                    
                    default: print("Error in switch")
                    }
                }
            }
        }
        
        
        //Step 4:
        dataTask.resume()
    }
    
    private func getURL(query: String)-> URL? {
        let baseUrl = "https://api.weatherapi.com/v1"
        let currentEndpoint = "/forecast.json"
        let apiKey = "c142512622db4ee88b1171859232003"
        let days = "7"
        guard let url = "\(baseUrl)\(currentEndpoint)?key=\(apiKey)&q=\(query)&days=\(days)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        return URL(string: url)
    }
    
    private func parseJson (data: Data) -> WeatherResponse? {
        let decoder = JSONDecoder()
        var weather: WeatherResponse?
        
        do{
            weather = try decoder.decode(WeatherResponse.self, from: data)
        } catch{
            print("Error decoding!")
        }
        
        return weather
    }
    
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        loadWeatherData(search: searchTextField.text) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    let weatherinfo = WeatherInformation(location: data.location.name, image: self.weatherImage.image!, temp: "\(Int(data.forecast.forecastday[0].day.maxtemp_c))", temp_h: "\(Int(data.forecast.forecastday[0].day.maxtemp_c))", temp_l: "\(Int(data.forecast.forecastday[0].day.mintemp_c))")
                    //print(weatherinfo)
                    self.delegate?.locationDelegateDidFinish(with: weatherinfo)
                    self.dismiss(animated: true,completion: nil)
                }
                
            case .failure(let error):
                print(error)
                
            }
        }
        
//
    }
    
}



struct WeatherInformation{
    let location: String
    let image: UIImage
    let temp: String
    let temp_h: String
    let temp_l:String
}

protocol LocationDelegate: AnyObject{
    func locationDelegateDidFinish(with data: WeatherInformation)
}
