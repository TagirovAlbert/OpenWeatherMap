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
import CoreData

protocol  WeatherGetterDeligate {
    func failure(error: String)
}

class WeatherGetter{
    
    var delegate: WeatherGetterDeligate?
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherApiKey = "c8b562de206b5661b16a81721c73799e"
    var weather = NSEntityDescription.insertNewObject(forEntityName: "Weather", into: managedContext)
    
    
    func getRequestWeather (city: String){
        Alamofire.request("\(openWeatherMapBaseURL)?APPID=\(openWeatherApiKey)&q=\(city)",method: .get).responseJSON { (response) in debugPrint(response)
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                self.weather = self.createWeatherModel(json: json)
               
            case .failure(let error):
                print("\(error)!!!!!!!!!")
                let errorString = error.localizedDescription
                if errorString.hasPrefix("URL is not valid"){
                    self.delegate?.failure(error: "Invalid parameter")
                }else{
                self.delegate?.failure(error: errorString)
                }
        }
    }
        
        
    }
    
    func getWeather() -> Weather{
       return weather
    }
    
    
    private func createWeatherModel(json: JSON) -> Weather{
        
        let weatherTemp = NSEntityDescription.insertNewObject(forEntityName: "Weather", into: managedContext) as! Weather
        if json["cod"].intValue == 200{
            print(weatherTemp.classForCoder)
            print(weatherTemp.city)
            weatherTemp.city = json["name"].stringValue
            weatherTemp.enabled = NSNumber.init(booleanLiteral: true)
            weatherTemp.humidity = (json["main"]["humidity"].int! as NSNumber?)!
            weatherTemp.pressure = json["main"]["pressure"].int!
            weatherTemp.featuresWeather = json["weather"][0]["description"].stringValue
            weatherTemp.region = json["sys"]["country"].stringValue
            weatherTemp.windSpeed = json["wind"]["speed"].int! as NSNumber?
            weatherTemp.temperature = json["main"]["temp"].int!
        }else{
            weatherTemp.featuresWeather = json["message"].stringValue
        }
        return weatherTemp
        
    }
    

    
}
