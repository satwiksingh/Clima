//
//  ViewController.swift
//  WeatherApp
//
//  Created by Satwik Singh on 18/06/18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController,CLLocationManagerDelegate,ChangeCityDelegate {
    
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "bfe9a3a25dac018332d4f13d671e9c82"
    

   
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
   
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    
        
    }
    
    
    
    func getWeatherData(url : String , parameters : [String : String]){
        Alamofire.request(url, method : .get, parameters: parameters).responseJSON{
            response in
            if response.result.isSuccess{
                print("Success")
                
                let weatherJSON: JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
                print(response)
            }
            else{
                self.cityLabel.text = "Error"            }
        }
    }

    
    
    
    
    
   
    
    
    func updateWeatherData(json: JSON){
        if let tempResult = json["main"]["temp"].double{
        
        weatherDataModel.temperature = Int(tempResult - 273.15)
        weatherDataModel.city = json["name"].stringValue
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
        }
        
        else{
            cityLabel.text = "Weather unavailable"
        }
    }

    
    
    
    
    func updateUIWithWeatherData(){
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)º"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
    }
    
    
    @IBAction func degreeToFahrenheit(_ sender: UISwitch) {
        
        if sender.isOn{
             updateUIWithWeatherData()
        }
        else{
            temperatureLabel.text = "\(Int(weatherDataModel.temperature)+273)K"
        }
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude , "lon" : longitude , "appid" : APP_ID]
            getWeatherData(url :WEATHER_URL , parameters :params)
        }
            
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
   
    func userEnteredANewCityName(city: String){
        
        let params : [String: String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
            
        }
    }
    
    
    
    
}


