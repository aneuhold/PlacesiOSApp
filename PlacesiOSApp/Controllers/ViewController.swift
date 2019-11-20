import UIKit
import CoreData

/**
 * Copyright 2019 Anton G Neuhold Jr,
 *
 * This software is the intellectual property of the author, and can not be
 * distributed, used, copied, or reproduced, in whole or in part, for any
 * purpose, commercial or otherwise. The author grants the ASU Software
 * Engineering program the right to copy, execute, and evaluate this work for
 * the purpose of determining performance of the author in coursework, and for
 * Software Engineering program evaluation, so long as this copyright and
 * right-to-use statement is kept in-tact in such use. All other uses are
 * prohibited and reserved to the author.<br>
 * <br>
 *
 * Purpose: Provides the main functionality for the iOS places app. The main
 * view controller provides the data source for most of the application.
 *
 * SER 423
 * see http://quay.poly.asu.edu/Mobile/
 * @author Anton Neuhold mailto:aneuhold@asu.edu
 *         Software Engineering
 * @version November 17, 2019
 */
class ViewController: UITabBarController, UITableViewDataSource, UIPickerViewDataSource {
  
  var places: [NSManagedObject] = []
  var tableViewController: PlacesTableViewController?
  var appDelegate: AppDelegate?
  var managedContext: NSManagedObjectContext?
  var entity: NSEntityDescription?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Setup variables for Core Data
    appDelegate = UIApplication.shared.delegate as? AppDelegate
    managedContext = appDelegate?.persistentContainer.viewContext
    entity = NSEntityDescription.entity(forEntityName: "Place", in: managedContext!)
    
    populatePlacesArray()
    //self.tableViewController?.tableView.reloadData()
    
    // Intialize Core Data
    initializeCoreData()
  }
  
  func generateURL () -> String {
    var serverhost:String = "localhost"
    var jsonrpcport:String = "8080"
    var serverprotocol:String = "http"
    // access and log all of the app settings from the settings bundle resource
    if let path = Bundle.main.path(forResource: "ServerInfo", ofType: "plist"){
      // defaults
      if let dict = NSDictionary(contentsOfFile: path) as? [String:AnyObject] {
        serverhost = (dict["server_host"] as? String)!
        jsonrpcport = (dict["jsonrpc_port"] as? String)!
        serverprotocol = (dict["server_protocol"] as? String)!
      }
    }
    print("setURL returning: \(serverprotocol)://\(serverhost):\(jsonrpcport)")
    return "\(serverprotocol)://\(serverhost):\(jsonrpcport)"
  }
  
  func populatePlacesArray() {
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Place")
    do {
      places = try (managedContext?.fetch(fetchRequest))!
    } catch let error as NSError {
      print("Could not fetch for the places array. Error is as follows: \(error)")
    }
  }
  
  // MARK: - UIPickerViewDataSource methods
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return places.count
  }
  
  // MARK: - UITableViewDataSource methods
  
  /**
   Returns the number of rows in the given section. In this particular class,
   it will return the number of entries in the place library.
   */
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return places.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    // Get and configure the cell...
    let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath)
    let place = places[indexPath.row]
    cell.textLabel?.text = place.value(forKey: "name") as? String
    return cell
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    print("tableView editing row at: \(indexPath.row)")
    if editingStyle == .delete {
      
      print("The row is about to be deleted")
      managedContext?.delete(places[indexPath.row])
      
      print("The managed context deleted the row evidently")
      do {
        try managedContext?.save()
      } catch let error as NSError {
        print("Could not remove the place, error is as follows: \(error)")
      }
      
      print("Evidently it saved")
      
      places.remove(at: indexPath.row)
      
      // Let the tableView know what is being deleted.
      tableView.deleteRows(at: [indexPath], with: .fade)
      // don't need to reload data, using delete to make update
    }
  }
  
  func initializeCoreData() {
    
    if (places.count == 0) {
      
      /*
       * Use the PlaceLibrary class and json file ONLY TO LOAD IN THE INTIALIZER
       * DATA. This is not used as the backing of the data for the app in any way.
       */
      let placeLibrary = PlaceLibrary()
      var i = 0
      while (i < placeLibrary.size()) {
        let currentPlace = placeLibrary.getPlaceAt(i)
        let newPlace = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        // Set all of the Place values
        newPlace.setValue(currentPlace.name, forKey: "name")
        newPlace.setValue(currentPlace.description, forKey: "placeDescription")
        newPlace.setValue(currentPlace.category, forKey: "category")
        newPlace.setValue(currentPlace.addressTitle, forKey: "addressTitle")
        newPlace.setValue(currentPlace.addressStreet, forKey: "addressStreet")
        newPlace.setValue(currentPlace.elevation, forKey: "elevation")
        newPlace.setValue(currentPlace.latitude, forKey: "latitude")
        newPlace.setValue(currentPlace.longitude, forKey: "longitude")
        
        i = i + 1
      }
      
      // Try to save after all of the new places are created.
      do {
        try managedContext?.save()
      } catch let error as NSError {
        print("Could not save the new place while initializing, error is as follows: \(error)")
      }
      
      // Re-populate the places array
      populatePlacesArray()
      self.tableViewController?.tableView.reloadData()
    }
  }
}

