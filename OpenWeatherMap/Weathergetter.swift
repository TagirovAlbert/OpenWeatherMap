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
    func createWeatherModel(json: JSON) -> Weather
    func failure(error: String)
}

class WeatherGetter{
    
    var delegate: WeatherGetterDeligate?
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherApiKey = "c8b562de206b5661b16a81721c73799e"
    var weather:Weather!
    
    func getRequestWeather (city: String, controller: ViewController){
        Alamofire.request("\(openWeatherMapBaseURL)?APPID=\(openWeatherApiKey)&q=\(city)",method: .get).responseJSON(queue: DispatchQueue.global(qos: .default), options: JSONSerialization.ReadingOptions.allowFragments) { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                self.weather = self.delegate?.createWeatherModel(json: json)
                controller.headerNewWeather(weather: self.weather!, cityName: city)
                
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
    
    
    
}
