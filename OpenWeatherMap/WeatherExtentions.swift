//
//  WeatherExtentions.swift
//  OpenWeatherMap
//
//  Created by Albert Tagirov on 06.10.16.
//  Copyright © 2016 Albert Tagirov. All rights reserved.
//

import Foundation
import CoreData

extension Weather{
    @nonobjc class func fetchRequest() -> NSFetchRequest<Weather> {
        return NSFetchRequest<Weather>(entityName: "Weather")
    }
}
