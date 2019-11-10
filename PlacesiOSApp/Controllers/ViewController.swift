import UIKit

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
 * Purpose: CHANGE ME
 *
 * SER 423
 * see http://quay.poly.asu.edu/Mobile/
 * @author Anton Neuhold mailto:aneuhold@asu.edu
 *         Software Engineering
 * @version October 20, 2019
 */
class ViewController: UITabBarController, UITableViewDataSource {
  
  // var places: PlaceLibrary = PlaceLibrary()
  var placeNames: [String] = [String]()
  var tableViewController: PlacesTableViewController?
  
  let urlString = "http://127.0.0.1:8080"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    placeNames.append("Loading places...")
    
    populatePlaceNames()
  }
  
  /*
   Populates the placeNames variable using the PlaceLibraryStub class.
   */
  func populatePlaceNames() {
    print("Entered populatePlaceNames method with the following urlString: \(urlString)")
    let placesConnect: PlaceLibraryStub = PlaceLibraryStub(urlString: urlString)
    let _:Bool = placesConnect.getNames{(res: String, err: String?) -> Void in
      if err != nil {
        NSLog(err!)
      }else{
        NSLog(res)
        if let data: Data = res.data(using: String.Encoding.utf8){
          do{
            let dict = try JSONSerialization.jsonObject(with: data,options:.mutableContainers) as?[String:AnyObject]
            print("The returend dictionary is this size: \(String(describing: dict?.count))")
            self.placeNames = (dict!["result"] as? [String])!
            self.tableViewController?.tableView.reloadData()
          } catch {
            print("unable to convert to dictionary")
          }
        }
      }
    }
  }
  
  // MARK: - UITableViewDataSource methods
  
  /*
   Returns the number of rows in the given section. In this particular class,
   it will return the number of entries in the place library.
   */
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return placeNames.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    // Get and configure the cell...
    let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath)
    cell.textLabel?.text = placeNames[indexPath.row]
    return cell
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    print("tableView editing row at: \(indexPath.row)")
    if editingStyle == .delete {
      
      // Get a reference to the place name
      let placeName: String = placeNames[indexPath.row]
      
      // Remove the item locally
      placeNames.remove(at: indexPath.row)
      
      // Remove the item on the server
      let placesConnect: PlaceLibraryStub = PlaceLibraryStub(urlString: urlString)
      let _:Bool = placesConnect.remove(name: placeName, callback: {(res: String, err: String?) -> Void in
        if err != nil {
          NSLog(err!)
        }else{
          NSLog(res)
        }
      })
      
      // Let the tableView know what is being deleted.
      tableView.deleteRows(at: [indexPath], with: .fade)
      // don't need to reload data, using delete to make update
    }
  }
  
}

