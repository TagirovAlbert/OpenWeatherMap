//
//  DetailWeatherViewController.swift
//  OpenWeatherMap
//
//  Created by Albert Tagirov on 02.10.16.
//  Copyright © 2016 Albert Tagirov. All rights reserved.
//

import UIKit

class DetailWeatherViewController: UIViewController {
    
    @IBOutlet weak var wind: UILabel!
    @IBOutlet weak var pressure: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var descriptionWeather: UILabel!
    @IBOutlet weak var temperature: UILabel!
    
    var selectedWeather: Weather?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let weather = self.selectedWeather{
            self.wind.text = "\(weather.windSpeed!) m/s"
            self.pressure.text = "\(weather.pressure!) mmHg"
            self.humidity.text = "\(weather.humidity!) %"
            self.city.text = "\(weather.city!), \(weather.region!)"
            self.descriptionWeather.text = "\(weather.featuresWeather!)"
            self.temperature.text = "\(weather.temperature!)°С"
            
        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
