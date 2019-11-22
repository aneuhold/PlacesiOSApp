import Foundation
import CoreData
import UIKit
import MapKit

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
 * Purpose: This class uses Core Data as a backbone data structure to hold information
 * on the different place objects. Whenever data is edited or added it also
 * updates the coordinates on the MapView.
 *
 * SER 423 see http://quay.poly.asu.edu/Mobile/
 * @author Anton Neuhold mailto:aneuhold@asu.edu
 *         Software Engineering
 * @version October 30, 2019
 */
class PlaceCoreData {
  
  /**
   Holds the source of truth for the place descriptions.
   */
  var places: [NSManagedObject] = []
  
  /**
   Holds the place annotations for the library. This is reflected from the
   Core Data information and not used as the source of truth.
   */
  var placeAnnotations: [PlaceAnnotation] = []
  
  /**
   Used as a variable that can be null until the map is created. If the map
   exists then changes are made to it as needed.
   */
  var mapView: MKMapView?
  
  /**
   Used as a variable that can be null until the tableView is created. If the
   tableView exists then changes are made to it as needed.
   */
  var tableView: UITableView?
  
  /**
   Holds the place names from the JSON Server. This isn't used as a return value
   publicy and it is only used within this class.
   */
  private var placeNames: [String] = []
  
  private var appDelegate: AppDelegate?
  private var managedContext: NSManagedObjectContext?
  private var entity: NSEntityDescription?
  var urlString = "http://127.0.0.1:8080"
  
  init() {
    initializeCoreData()
    
    // Sync data with the Json server on startup
    syncPlacesWithJsonServer(){}
    
  }
  
  /**
   Provides a way to call the constructor for this class so that a callback
   can be provided to call after initialization is complete.
   */
  init(callback: @escaping () -> Void) {
    initializeCoreData()
    
    // Sync data with the Json server on startup
    syncPlacesWithJsonServer(executeAfterSync: callback)
    
  }
  
  private func initializeCoreData() {
    // Setup variables for Core Data
    appDelegate = UIApplication.shared.delegate as? AppDelegate
    managedContext = appDelegate?.persistentContainer.viewContext
    entity = NSEntityDescription.entity(forEntityName: "Place", in: managedContext!)
    
    populatePlacesArray()
    
    // Sync data with the Json server on startup
    urlString = generateURL()
  }
  
  private func generateURL () -> String {
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
  
  // MARK: JSON Server Methods
  
  func syncPlacesWithJsonServer(executeAfterSync: @escaping () -> Void) {
    
    // Update placeNames
    getPlaceNamesFromJsonServer(){
      
      // Create a fetch request that will be used multiple times
      let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Place")
      
      var placesToAddToServer = self.getLocalPlaceNames()
      
      /*
       After placeNames has been updated, check to see if the names match
       those of the local Core Data. For each one that doesn't, add the
       information from the server.
       */
      for placeName in self.placeNames {
        var coreDataContainsName = false
        fetchRequest.predicate = NSPredicate(format: "name == %@", placeName)
        
        do {
          let placesResult = try (self.managedContext?.fetch(fetchRequest))!
          if (placesResult.count > 0) {
            coreDataContainsName = true
            placesToAddToServer.removeAll(where: { $0 == placeName })
          }
        } catch let error as NSError {
          print("Could not fetch data for the place description. Error is as follows: \(error)")
        }
        if (!coreDataContainsName) {
          self.addPlaceFromJsonServerToCoreData(placeName)
        }
      }
      
      // Add the places that werene't matched to the server
      self.addLocalPlacesToServer(placeNames: placesToAddToServer, executeAfterAdditions: {
        
        // Call the provided function so any views that need to be changed can be changed here
        executeAfterSync()
      })

    }
  }
  
  func syncPlacesToJsonServer() {
    
    placeNames.removeAll()
    getPlaceNamesFromJsonServer {
      
      // Delete all server places
      for placeName in self.placeNames {
        self.removePlaceOnServerWithName(placeName)
      }
      
      // Add all local places to server
      let localPlaceNames = self.getLocalPlaceNames()
      self.addLocalPlacesToServer(placeNames: localPlaceNames, executeAfterAdditions: {})
      
    }
  }
  
  func syncPlacesFromJsonServer() {
    
    // Delete all local objects
    for managedObject in places {
      managedContext?.delete(managedObject)
    }
    places.removeAll()
    for placeAnnotation in placeAnnotations {
      mapView?.removeAnnotation(placeAnnotation)
    }
    placeAnnotations.removeAll()
    do {
      try managedContext?.save()
    } catch let error as NSError {
      print("Could not remove the places locally, error is as follows: \(error)")
    }
    placeNames.removeAll()
    
    // Refresh placeNames
    getPlaceNamesFromJsonServer {
      
      // Add each place locally
      for placeName in self.placeNames {
        self.getPlaceOnJsonServerWithName(
          placeName,
          executeAfterGettingPlaceDescription: {(placeDescription) in
            self.addPlace(newPlaceDescription: placeDescription)
          })
      }
    }
  }
  
  private func addPlaceFromJsonServerToCoreData(_ name: String) {
    getPlaceOnJsonServerWithName(name, executeAfterGettingPlaceDescription: {(placeDescription) in
      self.addPlace(newPlaceDescription: placeDescription)
    })
  }
  
  private func getPlaceNamesFromJsonServer(executeAfterUpdate: @escaping () -> Void) {
    let placesConnect: PlaceLibraryStub = PlaceLibraryStub(urlString: urlString)
    let _:Bool = placesConnect.getNames{(res: String, err: String?) -> Void in
      if err != nil {
        NSLog(err!)
      }else {
        NSLog(res)
        if let data: Data = res.data(using: String.Encoding.utf8){
          do {
            let dict = try JSONSerialization.jsonObject(with: data,options:.mutableContainers) as?[String:AnyObject]
            self.placeNames = (dict!["result"] as? [String])!
            executeAfterUpdate()
          } catch {
            print("unable to convert to dictionary")
          }
        }
      }
    }
  }
  
  private func getPlaceOnJsonServerWithName(
    _ name: String,
    executeAfterGettingPlaceDescription: @escaping (_ placeDescription: PlaceDescription) -> Void)
  {
    let placesConnect: PlaceLibraryStub = PlaceLibraryStub(urlString: self.urlString)
    let _:Bool = placesConnect.get(name: name, callback: {(res: String, err: String?) -> Void in
      if err != nil {
        NSLog(err!)
      } else{
        NSLog(res)
        if let data: Data = res.data(using: String.Encoding.utf8){
          do {
            let dict = try JSONSerialization.jsonObject(with: data,options:.mutableContainers) as?[String:AnyObject]
            let aDict:[String:AnyObject] = (dict!["result"] as? [String:AnyObject])!
            let returnedPlaceDescription = PlaceDescription(jsonObjDict: aDict)
            executeAfterGettingPlaceDescription(returnedPlaceDescription)
          } catch {
            print("getPlaceOnJsonServerWithName -> Unable to convert place data to dictionary")
          }
        }
      }
    })
  }
  
  private func addLocalPlacesToServer(placeNames: [String], executeAfterAdditions: () -> Void) {
    let placesConnect: PlaceLibraryStub = PlaceLibraryStub(urlString: urlString)
    for placeName in placeNames {
      let placeDescription = getPlaceDescriptionWithName(placeName)
      let _:Bool = placesConnect.add(placeDescription: placeDescription, callback: {(res: String, err: String?) -> Void in
        if err != nil {
          NSLog(err!)
        }else{
          NSLog(res)
        }
      })
    }
    executeAfterAdditions()
  }
  
  private func removePlaceOnServerWithName(_ name: String) {
    let placesConnect: PlaceLibraryStub = PlaceLibraryStub(urlString: self.urlString)
    let _:Bool = placesConnect.remove(name: name, callback: {(res: String, err: String?) -> Void in
      if err != nil {
        NSLog(err!)
      } else{
        NSLog(res)
      }
    })
  }
  
  // MARK: Local Core Data methods
  
  func getLocalPlaceNames() -> [String] {
    var result: [String] = []
    for managedObject in places {
      result.append(managedObject.value(forKey: "name") as! String)
    }
    return result
  }
  
  private func populatePlacesArray() {
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Place")
    do {
      places = try (managedContext?.fetch(fetchRequest))!
    } catch let error as NSError {
      print("Could not fetch for the places array. Error is as follows: \(error)")
    }
    
    for managedPlace in places {
      let newPlaceAnnotation = PlaceAnnotation(
        name: (managedPlace.value(forKey: "name") as? String)!,
        description: (managedPlace.value(forKey: "placeDescription") as? String)!,
        latitude: (managedPlace.value(forKey: "latitude") as? Double)!,
        longitude: (managedPlace.value(forKey: "longitude") as? Double)!)
      placeAnnotations.append(newPlaceAnnotation)
      print("The length of placeAnnotations is now \(placeAnnotations.count)")
      
      // If the optional mapView is there, then add some annotations.
      mapView?.addAnnotation(newPlaceAnnotation)
    }
  }
  
  func getNameOfPlaceAt(_ index: Int) -> String {
    return (places[index].value(forKey: "name") as? String)!
  }
  
  func deletePlaceAt(_ index: Int) {
    
    // Remove place from Core Data
    managedContext?.delete(places[index])
    print("The place has been deleted")
    do {
      try managedContext?.save()
    } catch let error as NSError {
      print("Could not remove the place, error is as follows: \(error)")
    }
    places.remove(at: index)
    print("The place has been removed from the places array")
    
    // Remove place from map
    mapView?.removeAnnotation(placeAnnotations[index])
    placeAnnotations.remove(at: index)
  }
  
  func setPlaceAt(_ index: Int, newPlaceDescription: PlaceDescription) {
    
    let editedPlaceName = places[index].value(forKey: "name") as! String
    print("Updating place with name: \(editedPlaceName)")
    
    // Update in Core Data
    places[index].setValue(newPlaceDescription.description, forKey: "placeDescription")
    places[index].setValue(newPlaceDescription.category, forKey: "category")
    places[index].setValue(newPlaceDescription.addressTitle, forKey: "addressTitle")
    places[index].setValue(newPlaceDescription.addressStreet, forKey: "addressStreet")
    places[index].setValue(newPlaceDescription.elevation, forKey: "elevation")
    places[index].setValue(newPlaceDescription.latitude, forKey: "latitude")
    places[index].setValue(newPlaceDescription.longitude, forKey: "longitude")
    do {
      try managedContext?.save()
    } catch let error as NSError {
      print("Could not remove the place, error is as follows: \(error)")
    }
    
    // Update place in annotation list and update MapView
    mapView?.removeAnnotation(placeAnnotations[index])
    let newAnnotation = PlaceAnnotation(
      name: newPlaceDescription.name,
      description: newPlaceDescription.description!,
      latitude: newPlaceDescription.latitude!,
      longitude: newPlaceDescription.longitude!)
    placeAnnotations[index] = newAnnotation
    mapView?.addAnnotation(newAnnotation)
  }
  
  func getPlaceDescriptionWithName(_ name: String) -> PlaceDescription {
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Place")
    fetchRequest.predicate = NSPredicate(format: "name == %@", name)
    let placeDescription: PlaceDescription = PlaceDescription()
    do {
      let placesResult = try (managedContext?.fetch(fetchRequest))!
      placeDescription.name = placesResult[0].value(forKey: "name") as! String
      placeDescription.description = placesResult[0].value(forKey: "placeDescription") as? String
      placeDescription.addressTitle = placesResult[0].value(forKey: "addressTitle") as? String
      placeDescription.addressStreet = placesResult[0].value(forKey: "addressStreet") as? String
      placeDescription.elevation = placesResult[0].value(forKey: "elevation") as? Double
      placeDescription.latitude = placesResult[0].value(forKey: "latitude") as? Double
      placeDescription.longitude = placesResult[0].value(forKey: "longitude") as? Double
    } catch let error as NSError {
      print("Could not fetch data for the place description. Error is as follows: \(error)")
    }
    return placeDescription
  }
  
  func addPlace(newPlaceDescription: PlaceDescription) {
    
    // Create the new place
    let newPlace = NSManagedObject(entity: entity!, insertInto: managedContext)
    
    // Set the values
    newPlace.setValue(newPlaceDescription.name, forKey: "name")
    newPlace.setValue(newPlaceDescription.description, forKey: "placeDescription")
    newPlace.setValue(newPlaceDescription.category, forKey: "category")
    newPlace.setValue(newPlaceDescription.addressTitle, forKey: "addressTitle")
    newPlace.setValue(newPlaceDescription.addressStreet, forKey: "addressStreet")
    newPlace.setValue(newPlaceDescription.elevation, forKey: "elevation")
    newPlace.setValue(newPlaceDescription.latitude, forKey: "latitude")
    newPlace.setValue(newPlaceDescription.longitude, forKey: "longitude")
    
    // Append the new place to the local array
    places.append(newPlace)
    
    // Try to save after the new place is created
    do {
      try managedContext?.save()
    } catch let error as NSError {
      print("Could not save the new place, error is as follows: \(error)")
    }
    
    // Add the place to the annotation list and update the map view
    let newPlaceAnnotation = PlaceAnnotation(
      name: newPlaceDescription.name,
      description: newPlaceDescription.description!,
      latitude: newPlaceDescription.latitude!,
      longitude: newPlaceDescription.longitude!)
    placeAnnotations.append(newPlaceAnnotation)
    print("The length of placeAnnotations is now \(placeAnnotations.count)")
    mapView?.addAnnotation(newPlaceAnnotation)
    print("The annotation was added to the mapView")
    tableView?.reloadData()
  }
  
  func size() -> Int {
    return places.count;
  }
}
