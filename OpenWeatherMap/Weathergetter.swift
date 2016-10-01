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
    private let openWeatherApiKey = "4623d6547730c1162a17a7e3333564f6"
    
    
    
    func getWeather (city: String){
        Alamofire.request( "\(openWeatherMapBaseURL)?APPID=\(openWeatherApiKey)&q=\(city)",method: .get).responseJSON { (response) in
            
            let file = response.result.value
            let json = JSON(file)
            
            print(json)
        }
        
        
        
        
        
        
        
    }
    
    
}
