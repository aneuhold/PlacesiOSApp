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
  
  var places: PlaceLibrary = PlaceLibrary()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - UITableViewDataSource methods
  
  /**
   Returns the number of rows in the given section. In this particular class,
   it will return the number of entries in the place library.
   */
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return places.size()
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    // Get and configure the cell...
    let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath)
    let aPlace = places.getPlaceAt(indexPath.row)
    cell.textLabel?.text = aPlace.name
    return cell
  }
  
}

