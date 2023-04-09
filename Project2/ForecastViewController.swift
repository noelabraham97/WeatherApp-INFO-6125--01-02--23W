//
//  ForecastViewController.swift
//  Project2
//
//  Created by Noel Abraham Biju on 2023-04-08.
//

import UIKit
import MapKit
import CoreLocation

class ForecastViewController: UIViewController {
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherCondition: UILabel!
    
    @IBOutlet weak var lowTemperature: UILabel!
    @IBOutlet weak var highTemperature: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var forecastItems: [ForecastWeather]?
    
    var weatherResponse: WeatherResponse?
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        loadWeatherData()
        
        
    }
    
    
    
    
    private func loadWeatherData(){
        
        guard let weatherResponse = weatherResponse else{
            return
        }
        temperatureLabel.text = "\(Int(weatherResponse.current.temp_c))°"
        locationLabel.text = String(weatherResponse.location.name)
        weatherCondition.text = String(weatherResponse.current.condition.text)
        highTemperature.text = "\(Int(weatherResponse.forecast.forecastday[0].day.maxtemp_c))°"
        lowTemperature.text = "\(Int(weatherResponse.forecast.forecastday[0].day.mintemp_c))°"
        
        weatherForecast(weatherResponse: weatherResponse)
        
    }
    
    private func weatherForecast(weatherResponse: WeatherResponse){
        
        forecastItems = []
        var weatherImage: UIImage?
        var config = UIImage.SymbolConfiguration(paletteColors: [.systemYellow, .systemGray])
        
        
        for i in 0...6 {
            print(weatherResponse.forecast.forecastday[i].date)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-mm-dd"
            let date = dateFormatter.date(from: weatherResponse.forecast.forecastday[i].date)
            dateFormatter.dateFormat = "EEEE"
            


            switch(weatherResponse.forecast.forecastday[i].day.condition.code){

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

            default: weatherImage = UIImage(systemName: "cloud", withConfiguration: config)!
            }
            
            guard let weatherImage = weatherImage else {
                return
            }
            
            guard let date = date else {
                return
            }
            
           
            forecastItems?.append(ForecastWeather(day: dateFormatter.string(from: date), uiImage: weatherImage, temp: "\(Int(weatherResponse.forecast.forecastday[i].day.avgtemp_c))"))
        }
        
        
    }
    

}
extension ForecastViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forecastIdentifier", for: indexPath)
        let items = forecastItems![indexPath.row]
        var content = cell.defaultContentConfiguration()
        
        content.text = items.day
        content.secondaryText = items.temp
        content.image = items.uiImage
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("sadsada\(forecastItems!.count)")
        return forecastItems!.count
    }
}

struct ForecastWeather{
    let day: String
    let uiImage: UIImage
    let temp: String
}

