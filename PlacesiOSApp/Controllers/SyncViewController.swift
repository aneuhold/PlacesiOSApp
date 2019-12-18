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
 * Purpose: This controls the view for the syncing options to the remote JSON
 * RPC server.
 *
 * SER 423
 * see http://quay.poly.asu.edu/Mobile/
 * @author Anton Neuhold mailto:aneuhold@asu.edu
 *         Software Engineering
 * @version November 27, 2019
 */
class SyncViewController: UIViewController {
  var viewController: ViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Get a reference to the top level view controller
    viewController = tabBarController as? ViewController
    
  }
  
  @IBAction func didPressSyncServerToLocalDB(_ sender: UIButton) {
    viewController?.placeCoreData?.syncPlacesFromJsonServer()
  }
  
  @IBAction func didPressSyncLocalDBToServer(_ sender: UIButton) {
    viewController?.placeCoreData?.syncPlacesToJsonServer()
  }
}
