//
//  ForecastViewController.swift
//  Project2
//
//  Created by Noel Abraham Biju on 2023-04-08.
//

import UIKit
import MapKit
import CoreLocation

class ForecastViewController: UIViewController, UITextViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var weatherConditionImage: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherCondition: UILabel!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        displayWeatherImage()
      //  searchTextField.delegate = self
        
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
        loadWeatherData(search: "\(locValue.latitude) \(locValue.longitude)")
        
        locationManager.stopUpdatingLocation()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        
        return true
    }
    
    @IBAction func OnLocationTapped(_ sender: UIButton) {
        getCurrentLocation()
        print("Inside button tap")
        
    }
    
    
    private func displayWeatherImage(){
        let config = UIImage.SymbolConfiguration(paletteColors: [ .systemYellow, .systemYellow, .systemYellow])
        weatherConditionImage.preferredSymbolConfiguration = config
        weatherConditionImage.image = UIImage(systemName: "sun.max.circle")
    }
    
    
    @IBAction func onSearchTapped(_ sender: UIButton) {
        // loadWeatherData(search: "\(locValue.latitude) \(locValue.longitude)")
        loadWeatherData(search: searchTextField.text)
    }
    
    
    private func loadWeatherData(search: String?){
        guard let search = search else {
            return
        }
        
        //
        //        //Step 1: Get URL
        //        guard let url = getURL(query: search) else{
        //            print("Could not get URL")
        //            return
        //        }
        //
        //        //Step 2: Create URLSession
        //        let session = URLSession.shared
        //
        //        //step 3:
        //        let dataTask = session.dataTask(with: url) { data, response, error in
        //            // network call finished
        //            print("Network call complete")
        //
        //            guard error == nil else{
        //                print("Recived Error")
        //                return
        //            }
        //
        //            guard let data = data else{
        //                print("No data found")
        //                return
        //            }
        //
        //            if let weatherResponse = self.parseJson(data: data){
        //                print(weatherResponse.location.name)
        //                print(weatherResponse.current.temp_c)
        //                DispatchQueue.main.async {
        //                    self.locationLabel.text = weatherResponse.location.name
        //
        //                    if self.segmentedTempControl.selectedSegmentIndex == 0{
        //                        self.temperatureLabel.text = "\(weatherResponse.current.temp_c)C"
        //                    }
        //                    else{
        //                        self.temperatureLabel.text = "\(weatherResponse.current.temp_f)F"
        //                    }
        //
        //
        //                    let configuration = UIImage.SymbolConfiguration(paletteColors: [.blue])
        //
        //                    self.weatherConditionImage.preferredSymbolConfiguration = configuration
        //                    print(weatherResponse.current.condition.code)
        //                    switch(weatherResponse.current.condition.code){
        //
        //                    case 1030 : self.weatherConditionImage.image = UIImage(systemName: "wind")
        //                        self.weatherCondition.text = weatherResponse.current.condition.text
        //
        //                    case 1000 : self.weatherConditionImage.image = UIImage(systemName: "sun.max")
        //                        self.weatherCondition.text = weatherResponse.current.condition.text
        //
        //                    case 1003 : self.weatherConditionImage.image = UIImage(systemName: "cloud.fill")
        //                        self.weatherCondition.text = weatherResponse.current.condition.text
        //
        //                    case 1006 : self.weatherConditionImage.image = UIImage(systemName: "cloud.fill")
        //                        self.weatherCondition.text = weatherResponse.current.condition.text
        //
        //                    case 1135 : self.weatherConditionImage.image = UIImage(systemName: "cloud.fog.fill")
        //                        self.weatherCondition.text = weatherResponse.current.condition.text
        //
        //                    case 1114 : self.weatherConditionImage.image = UIImage(systemName: "wind.snow")
        //                        self.weatherCondition.text = weatherResponse.current.condition.text
        //
        //                    case 1183 : self.weatherConditionImage.image = UIImage(systemName: "cloud.rain")
        //                        self.weatherCondition.text = weatherResponse.current.condition.text
        //
        //                    case 1240 : self.weatherConditionImage.image = UIImage(systemName: "cloud.rain.fill")
        //                        self.weatherCondition.text = weatherResponse.current.condition.text
        //
        //                    case 1163 : self.weatherConditionImage.image = UIImage(systemName: "cloud.drizzle")
        //                        self.weatherCondition.text = weatherResponse.current.condition.text
        //
        //                    case 1279 : self.weatherConditionImage.image = UIImage(systemName: "cloud.bolt.rain")
        //                        self.weatherCondition.text = weatherResponse.current.condition.text
        //
        //                    case 1255 : self.weatherConditionImage.image = UIImage(systemName: "cloud.snow.fill")
        //                        self.weatherCondition.text = weatherResponse.current.condition.text
        //
        //                    case 1072 : self.weatherConditionImage.image = UIImage(systemName: "cloud.sleet")
        //                        self.weatherCondition.text = weatherResponse.current.condition.text
        //
        //                    case 1066 : self.weatherConditionImage.image = UIImage(systemName: "cloud.snow")
        //                        self.weatherCondition.text = weatherResponse.current.condition.text
        //
        //                    default: print("Error in switch")
        //                    }
        //                }
        //            }
        //        }
        //
        //
        //        //Step 4:
        //        dataTask.resume()
        //    }
        
    }
    
    
}

