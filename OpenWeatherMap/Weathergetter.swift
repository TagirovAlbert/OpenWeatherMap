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

class WeatherGetter {
    
    
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherApiKey = "c8b562de206b5661b16a81721c73799e"
    var weather = Weather()
    
    
    
    func getWeather (city: String) -> Weather{
        Alamofire.request( "\(openWeatherMapBaseURL)?APPID=\(openWeatherApiKey)&q=\(city)",method: .get).validate().responseJSON { (response) in
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
                
                let iconCode = json["weather"][0]["icon"].stringValue
                let iconURL = "http://openweathermap.org/img/w/\(iconCode).png"
                self.getCloudIcon(iconUrl: iconURL, weather: weatherTemp)
                self.weather = weatherTemp
                
            
            case .failure(let error):
                print(error)
            }
          
        }
     
 
    
    return weather
    }
    
    func getCloudIcon(iconUrl: String, weather: Weather){
        Alamofire.download(iconUrl).responseData { (response) in
            if let data = response.result.value{
                weather.iconClouds = data as NSData!
            }
        }
    }
}
    
    
    
        
        
        
        
        
        
        
        

    
    
