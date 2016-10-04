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

class WeatherGetter{
    
    var delegate: WeatherGetterDeligate?
    
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherApiKey = "c8b562de206b5661b16a81721c73799e"
    private var weather = Weather()
    
    func getWeather (city: String) -> Weather{
        Alamofire.request("\(openWeatherMapBaseURL)?APPID=\(openWeatherApiKey)&q=\(city)",method: .get).responseJSON { (response) in debugPrint(response)
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                let weatherTemp = Weather(key: self.incrementID())
                
                if json["cod"].intValue == 200{
                    weatherTemp.city = json["name"].stringValue
                    weatherTemp.enable = true
                    weatherTemp.humidity = json["main"]["humidity"].int!
                    weatherTemp.pressure = json["main"]["pressure"].int!
                    weatherTemp.featuresWeather = json["weather"][0]["description"].stringValue
                    weatherTemp.region = json["sys"]["country"].stringValue
                    weatherTemp.windSpeed = json["wind"]["speed"].int!
                    weatherTemp.temperature = json["main"]["temp"].int!
                }else{
                    weatherTemp.featuresWeather = json["message"].stringValue
                }
                self.weather = weatherTemp
                if self.delegate != nil{
                    self.delegate?.dataReady()
                }
                
                
            case .failure( _):
                let weatherFail = Weather(key: self.incrementID())
                weatherFail.featuresWeather = "Invalid Parametrs, try again"
            }
            
        }
        return weather
    }
    
    func incrementID() -> Int {
        let realm = try! Realm()
        return (realm.objects(Weather.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
}
    
