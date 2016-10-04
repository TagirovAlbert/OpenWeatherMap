//
//  ViewController.swift
//  OpenWeatherMap
//
//  Created by Albert Tagirov on 29.09.16.
//  Copyright © 2016 Albert Tagirov. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,  WeatherGetterDeligate{
    
    let realm = try! Realm()
    @IBOutlet weak var tableView: UITableView!
    var weatherCollection: Results<Weather>!
    var tempWet = Weather()
    var weatherGetter = WeatherGetter()
    
    
    var selectedWeather: Weather!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        weatherGetter.delegate = self
        dataReady()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell")
        let degrees = cell?.viewWithTag(2) as! UILabel
        let location = cell?.viewWithTag(3) as! UILabel
        let weatherOne = weatherCollection[indexPath.row]
        degrees.text = "\(weatherOne.temperature)°C"
        location.text = "\(weatherOne.city), \(weatherOne.region)"
        return cell!
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedWeather = weatherCollection[indexPath.row]
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherCollection.count
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (UITableViewRowAction, indexPath:IndexPath) in
            try! self.realm.write {
                self.realm.delete(self.weatherCollection[indexPath.row])
            }
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            
            
        }
        deleteAction.backgroundColor = UIColor.red
        return[deleteAction]
    }
    
    @IBAction func addCity(_ sender: AnyObject) {
        var weatherToSave = Weather()
        var oldWeatherInfo: Weather?
        let alertController = UIAlertController(title: "Add New City", message: "Add a new city to see weather there", preferredStyle: .alert)
        alertController.addTextField { (textField: UITextField) in
            textField.placeholder = "Enter City"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let addWeatherAction = UIAlertAction(title: "Add City", style: .default) { (alert) in
            let textField = (alertController.textFields?[0])! as UITextField
            let cityName = textField.text?.lowercased()
            print(cityName! + "!!!!!!!")
            for elemWeather in self.weatherCollection{
                if elemWeather.city.lowercased() == cityName{
                    oldWeatherInfo = elemWeather
                }
            }
            DispatchQueue.global().sync {
                self.weatherGetter.getWeather(city: cityName!)
                weatherToSave = self.tempWet
                
            }
            if ((oldWeatherInfo) == nil){
                if   (weatherToSave.enable) {
                    self.saveToDatabase(weather: weatherToSave)
                }else if !(weatherToSave.featuresWeather == ""){
                    self.alertErrorMessages(message: (weatherToSave.featuresWeather))
                }
                
            }else{
                self.alertCityExist()
            }
            //   if (weatherToSave?.enable == true) || (weatherToSave?.featuresWeather == ""){
            //self.saveToDatabase(weather: self.tempSlv!)
            //   }else{
            //      self.alertErrorMessages(message: (weatherToSave?.featuresWeather)!)
            // }
            
            //}else{
            //   self.alertCityExist()
            
            
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addWeatherAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func saveToDatabase(weather: Weather) {
        //let collect = { self.realm.objects(Weather.self)}
        //for elem in collect(){
        //  if !(elem.city == weather.city){
        try! self.realm.write {
            self.realm.add(weather)
            //}
            //}
            
        }
    }
    
    
    
    @IBAction func updateWeathers(_ sender: AnyObject) {
        var tempWeather: Weather?
        var weatherFromDB: Weather?
        for weather in weatherCollection {
            DispatchQueue.global().sync {
                self.weatherGetter.getWeather(city: weather.city)
                tempWeather = tempWet
            }
            weatherFromDB = { realm.object(ofType: Weather.self, forPrimaryKey: weather.id)}()
            updateParams(saveWeather: tempWeather!, oldWeather: weatherFromDB!)
            try! realm.write {
                realm.add(weatherFromDB!)
            }
        }
    }
    
    
    
    /*func reloadData(indexPath: IndexPath){
     getListOfWeathers()
     self.tableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.left )
     
     }*/
    
    // MARK: Ыecondary functions
    func alertCityExist(){
        let alertController1 = UIAlertController(title: "Error", message: "The city has already been added", preferredStyle: .alert)
        let cancelAction1 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController1.addAction(cancelAction1)
        self.present(alertController1, animated: true, completion: nil)
    }
    
    func alertErrorMessages(message: String){
        let alertController1 = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .alert)
        let cancelAction1 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController1.addAction(cancelAction1)
        self.present(alertController1, animated: true, completion: nil)
    }
    
    func getListOfWeathers(){
        self.weatherCollection = {realm.objects(Weather.self)}()
    }
    
    override func didReceiveMemoryWarning() {
        
    }
    
    func updateParams(saveWeather: Weather, oldWeather: Weather){
        try! realm.write {
            oldWeather.featuresWeather = saveWeather.featuresWeather
            oldWeather.humidity = saveWeather.humidity
            oldWeather.windSpeed = saveWeather.windSpeed
            oldWeather.temperature = saveWeather.temperature
            oldWeather.pressure = saveWeather.pressure
        }
        
    }
    // MARK: WeatherGetter delegate
    func failure(){
        let failController = UIAlertController(title: "Error", message: "Lose connection with internet", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        failController.addAction(cancelAction)
        self.present(failController, animated: true, completion: nil)
    }
    
    func dataReady() {
        getListOfWeathers()
        self.tableView.reloadData()
    }
    
    func createWeatherModel(json: JSON){
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
        self.tempWet = weatherTemp

    }
    func incrementID() -> Int {
        var elem = 0
        DispatchQueue.main.async {
            let realm = try! Realm()
            elem = (realm.objects(Weather.self).max(ofProperty: "id") as Int? ?? 0) + 1
        }
        return elem
    }
        
    
    // MARK: prepare segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailWeatherViewController = segue.destination as! DetailWeatherViewController
        detailWeatherViewController.selectedWeather = self.selectedWeather
    }
    
    
    
    
}
