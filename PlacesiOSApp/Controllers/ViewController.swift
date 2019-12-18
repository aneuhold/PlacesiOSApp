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
  
  /**
   The reference to tableViewController is set within the PlacesTableViewController
   class.
   */
  var tableViewController: PlacesTableViewController?
  var placeCoreData: PlaceCoreData?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    placeCoreData = PlaceCoreData(){
      self.tableViewController?.tableView.reloadData()
    }
  }
  
  // MARK: - UIPickerViewDataSource methods
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return (placeCoreData?.size())!
  }
  
  // MARK: - UITableViewDataSource methods
  
  /**
   Returns the number of rows in the given section. In this particular class,
   it will return the number of entries in the place library.
   */
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return (placeCoreData?.size())!
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    // Get and configure the cell...
    let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath)
    cell.textLabel?.text = placeCoreData?.getNameOfPlaceAt(indexPath.row)
    return cell
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    print("tableView editing row at: \(indexPath.row)")
    if editingStyle == .delete {
      placeCoreData?.deletePlaceAt(indexPath.row)
      
      // Let the tableView know what is being deleted.
      tableView.deleteRows(at: [indexPath], with: .fade)
      // don't need to reload data, using delete to make update
    }
  }
}

