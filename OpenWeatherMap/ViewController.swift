//
//  ViewController.swift
//  OpenWeatherMap
//
//  Created by Albert Tagirov on 29.09.16.
//  Copyright © 2016 Albert Tagirov. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData

class ViewController: UIViewController,NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, WeatherGetterDeligate{
    
    var fetchResultController: NSFetchedResultsController<Weather>!
    @IBOutlet weak var tableView: UITableView!
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    var weatherCollection: [Weather] = []
    var weatherSave: Weather!
    var weatherGetter = WeatherGetter()
    
    
    var selectedWeather: Weather!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        weatherGetter.delegate = self
        updateWeatherInDB()
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
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") {_,_ in 
           let restaurantToRemove = self.fetchResultController.object(at: indexPath) 
           self.managedContext.delete(restaurantToRemove)
            if self.managedContext.hasChanges{
                do{
                   try self.managedContext.save()
                }catch let error as NSError{
                    NSLog("Ошибка: \(error), \(error.localizedDescription)")
                    abort()
                }
            }
        }
        deleteAction.backgroundColor = UIColor.red
        return[deleteAction]
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch  type {
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        default:
            tableView.reloadData()
        }
        weatherCollection = controller.fetchedObjects as! [Weather]
        
    }
    
    @IBAction func addCity(_ sender: AnyObject) {
        var weatherToSave = Weather()
        let alertController = UIAlertController(title: "Add New City", message: "Add a new city to see weather there", preferredStyle: .alert)
        alertController.addTextField { (textField: UITextField) in
            textField.placeholder = "Enter City"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let addWeatherAction = UIAlertAction(title: "Add City", style: .default) { (alert) in
            let textField = (alertController.textFields?[0])! as UITextField
            let cityName = textField.text?.lowercased()
            if cityName == ""{
                self.alertErrorMessages(message: "Empty field, enter city")
            }else if (cityName?.characters.count)! > 15{
                self.alertErrorMessages(message: "Name of city is so long( maximun 15 symbols)")
            }else{
            var flag = true
            self.weatherGetter.getRequestWeather(city: cityName!)
            print(self.weatherGetter.getWeather())
                if (self.weatherGetter.getWeather().entity != nil){
            weatherToSave = self.weatherGetter.getWeather()
            print(cityName! + "!!!!!!!")
            for elemWeather in self.weatherCollection{
                if (elemWeather.city?.lowercased() == cityName) || (weatherToSave.city == cityName){
                    flag = false
                }
            }
            
                if flag{
                    if   (weatherToSave.enabled?.boolValue)! {
                        self.saveToDatabase(weather: weatherToSave)
                    }else if !(weatherToSave.featuresWeather == ""){
                        self.alertErrorMessages(message: (weatherToSave.featuresWeather)!)
                    }
                    
                }else{
                    self.alertCityExist()
                
                }}
            
            //   if (weatherToSave?.enable == true) || (weatherToSave?.featuresWeather == ""){
            //self.saveToDatabase(weather: self.tempSlv!)
            //   }else{
            //      self.alertErrorMessages(message: (weatherToSave?.featuresWeather)!)
            // }
            
            //}else{
            //   self.alertCityExist()
            
            }
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addWeatherAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func saveToDatabase(weather: Weather) {
        weatherSave = NSEntityDescription.insertNewObject(forEntityName: "Weather", into: managedContext) as! Weather
        weatherSave = weather
        if managedContext.hasChanges{
            do{
                try managedContext.save()
            }catch{
                let nsError = error as NSError
                NSLog("произошла ошибка \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func updateWeatherInDB(){
        let fetchRequest: NSFetchRequest<Weather>  = Weather.fetchRequest()
        do{
            let fetchResults = try managedContext.fetch(fetchRequest) as! [Weather]
            if !(fetchResults.isEmpty){
                for entity in fetchResults{
                   self.weatherGetter.getRequestWeather(city: entity.city!)
                   let newWeather = weatherGetter.getWeather()
                   updateParams(saveWeather: newWeather, oldWeather: entity)
                }
            }
        }catch let error as NSError{
            NSLog("ошибка: \(error)")
        }
        
        do{
           try self.managedContext.save()
        }catch let error as NSError{
            NSLog("ошибка: \(error.localizedDescription)")
        }
     }
    
    
    
    @IBAction func updateWeathers(_ sender: AnyObject) {
       updateWeatherInDB()
    }
    
    
    
    
    
    /*func reloadData(indexPath: IndexPath){
     getListOfWeathers()
     self.tableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.left )
     
     }*/
    
    // MARK: - Secondary functions
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
        let fetchRequest: NSFetchRequest<Weather> = Weather.fetchRequest()
        let sortDescription = NSSortDescriptor(key: "city", ascending: true)
        fetchRequest.sortDescriptors = [sortDescription]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchResultController.delegate = self
        var error: NSError?
        var result: Bool
        do{
            try fetchResultController.performFetch()
            result = true
        }catch let error1 as NSError{
            error = error1
            result = false
        }
        weatherCollection = fetchResultController.fetchedObjects! as [Weather]
        
        if result == false{
            print("описание ошибки \(error?.localizedDescription)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        
    }
    
    func updateParams(saveWeather: Weather, oldWeather: Weather){
            oldWeather.featuresWeather = saveWeather.featuresWeather
            oldWeather.humidity = saveWeather.humidity
            oldWeather.windSpeed = saveWeather.windSpeed
            oldWeather.temperature = saveWeather.temperature
            oldWeather.pressure = saveWeather.pressure
    }
    
    // MARK: - WeatherGetter delegate
    func failure(error: String){
        let failController = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        failController.addAction(cancelAction)
        self.present(failController, animated: true, completion: nil)
    }
    
    func dataReady() {
        getListOfWeathers()
        self.tableView.reloadData()
    }
    
    
    
    // MARK: - prepare segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailWeatherViewController = segue.destination as! DetailWeatherViewController
        detailWeatherViewController.selectedWeather = self.selectedWeather
    }
    
    
    
    
}
