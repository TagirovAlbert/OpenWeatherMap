//
//  Weather.swift
//  OpenWeatherMap
//
//  Created by Albert Tagirov on 02.10.16.
//  Copyright © 2016 Albert Tagirov. All rights reserved.
//

import Foundation
import CoreData

class Weather: NSManagedObject{
    @NSManaged var city: String?
    @NSManaged var region: String?
    
    @NSManaged var enabled: NSNumber?
    private var _temp: Int = 0
    var temperature: Int?{
        get{ return _temp }
        set{ _temp = (newValue! - 273) }
    }
    private var _pres: Int = 0
    var pressure:Int?{
        get{ return _pres }
        
        set{ _pres = Int(Double(newValue!) * 0.75) }
    }
    @NSManaged var windSpeed: NSNumber?
    @NSManaged var featuresWeather: String?
    @NSManaged var humidity: NSNumber?
    
    
    
    
    
    
    
    
    
}
