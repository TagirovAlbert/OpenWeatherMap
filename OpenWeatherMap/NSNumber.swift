//
//  NSNumber.swift
//  OpenWeatherMap
//
//  Created by Albert Tagirov on 06.10.16.
//  Copyright © 2016 Albert Tagirov. All rights reserved.
//

import Foundation
extension NSNumber {
    var isBool:Bool {
        get {
            return type(of: self) == type(of: NSNumber(value: true))
        }
    }
}
