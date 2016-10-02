//
//  Weather.swift
//  OpenWeatherMap
//
//  Created by Albert Tagirov on 02.10.16.
//  Copyright © 2016 Albert Tagirov. All rights reserved.
//

import Foundation
import RealmSwift

class Weather: Object{
    dynamic var city = ""
    dynamic var region = ""
    
    private var _temp: Int = 0
    dynamic var temperature: Int{
        get{ return _temp }
        set{ _temp = newValue - 273 }
    }
    private var _pres: Int = 0
    dynamic var pressure:Int{
        get{ return _pres }
        
        set{ _pres = Int(Double(newValue) * 0.75) }
    }
    dynamic var windSpeed = 0
    dynamic var featuresWeather: String = ""
    dynamic var humidity = 0
    dynamic var iconClouds: NSData!
    
    
    
    
    
    
    
}
