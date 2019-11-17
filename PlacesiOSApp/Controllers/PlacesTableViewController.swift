
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
 * Purpose: Provides the view controller for the UITableView. This populates
 * data from a remote JSON RPC server. If there is an error in the connection,
 * currently it will hang on "Loading".
 *
 * SER 423
 * see http://quay.poly.asu.edu/Mobile/
 * @author Anton Neuhold mailto:aneuhold@asu.edu
 *         Software Engineering
 * @version November 10, 2019
 */
class PlacesTableViewController: UITableViewController {
  var viewController: ViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // This will create a reference to the tab bar controller of the app which holds most of the data for the app
    viewController = tabBarController as? ViewController
    
    // Set the data source for the UITableView
    tableView.dataSource = viewController
    
    // Set a reference to this tableView in the main ViewController so that changes can be made if needed.
    viewController?.tableViewController = self
    
    // Add an edit button, which is handled by the func table view editing forRowAt
    self.navigationItem.leftBarButtonItem = self.editButtonItem
    
    // place an add button on the right side of the nav bar for adding a student
    // call addStudent function when clicked.
    let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(PlacesTableViewController.addPlace))
    self.navigationItem.rightBarButtonItem = addButton
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.identifier == "PlaceDescriptionSegue") {
      
      // Get a reference to the target UIViewController
      let placeDetailsViewController: PlaceDetailsViewController
        = segue.destination as! PlaceDetailsViewController
      
      let indexPath = self.tableView.indexPathForSelectedRow!
      
      // Set the information inside the new place details view
      placeDetailsViewController.place = viewController?.places[indexPath.row]
    }
  }
  
  // Called with the Navigation Bar Add button (+) is clicked
  @objc func addPlace() {
    print("add button clicked")
    
    // Query the user for the new place name.
    let promptND = UIAlertController(title: "New Place", message: "Enter New Place Name", preferredStyle: UIAlertController.Style.alert)
    
    // If the user cancels, we don't want to add a place
    promptND.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
    
    // setup the OK action and provide a closure to be executed when/if OK selected
    promptND.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) -> Void in
      
      // Provide default values for name
      let newPlaceName:String = (promptND.textFields?[0].text == "") ?
        "unknown" : (promptND.textFields?[0].text)!

      // Create the new place
      let newPlace = NSManagedObject(entity: (self.viewController?.entity)!, insertInto: self.viewController?.managedContext)
      newPlace.setValue(newPlaceName, forKey: "name")
      self.viewController?.places.append(newPlace)
      
      // Try to save after the new place is created
      do {
        try self.viewController!.managedContext?.save()
      } catch let error as NSError {
        print("Could not save the new place, error is as follows: \(error)")
      }
      
      // Reload the table view data
      self.tableView.reloadData()
      
    }))
    promptND.addTextField(configurationHandler: {(textField: UITextField!) in
      textField.placeholder = "Place Name"
    })
    present(promptND, animated: true, completion: nil)
  }
}
