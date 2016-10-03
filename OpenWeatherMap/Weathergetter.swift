//
//  Weathergetter.swift
//  OpenWeatherMap
//
//  Created by Albert Tagirov on 02.10.16.
//  Copyright © 2016 Albert Tagirov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift

protocol  WeatherGetterDeligate {
    func dataReady()
}

class WeatherGetter: NSObject {
    
    var delegate: WeatherGetterDeligate?
    
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherApiKey = "c8b562de206b5661b16a81721c73799e"
    private var weather = Weather()
    
    func setWeather (city: String){
        Alamofire.request("\(openWeatherMapBaseURL)?APPID=\(openWeatherApiKey)&q=\(city)",method: .get).validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                let weatherTemp = Weather()
                weatherTemp.city = json["name"].stringValue
                weatherTemp.humidity = json["main"]["humidity"].int!
                weatherTemp.pressure = json["main"]["pressure"].int!
                weatherTemp.featuresWeather = json["weather"][0]["description"].stringValue
                weatherTemp.region = json["sys"]["country"].stringValue
                weatherTemp.windSpeed = json["wind"]["speed"].int!
                weatherTemp.temperature = json["main"]["temp"].int!
                
                self.weather = weatherTemp
                if self.delegate != nil{
                    self.delegate?.dataReady()
                }
            
            case .failure(let error):
                print(error)
            }
          
        }
    }
    
    
    func getWeather() -> Weather{
        return weather
    }
    
    
    
    
    func setWeatherLocally(weather: Weather){
        
    }
}
    
    
    
        
        
        
        
        
        
        
        

    
    
