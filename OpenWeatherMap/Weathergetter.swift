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
    func createWeatherModel(json: JSON)
    func failure(error: String)
}

class WeatherGetter{
    
    var delegate: WeatherGetterDeligate?
    
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherApiKey = "c8b562de206b5661b16a81721c73799e"
    
    func getWeather (city: String){
        Alamofire.request("\(openWeatherMapBaseURL)?APPID=\(openWeatherApiKey)&q=\(city)",method: .get).responseJSON { (response) in debugPrint(response)
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                DispatchQueue.main.async {
                    self.delegate?.createWeatherModel(json: json)
                }
                self.delegate?.dataReady()
            
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
