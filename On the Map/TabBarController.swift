//
//  TabBarController.swift
//  On the Map
//
//  Created by leanne on 7/6/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
	
	var userModel: User!

    override func viewDidLoad() {
        super.viewDidLoad()

		navigationItem.title = "On The Map"
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(doLogout))
		
		let pinButton = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(postInformation))
		let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(refreshData))
		
		// note: right bar buttons in array appear on nav bar right to left
		navigationItem.rightBarButtonItems = [refreshButton, pinButton]
		
    }
	
	
	// MARK: - Selectors
	
	/// Segues back (unwinds) to logout function
	func doLogout() {
		
		performSegueWithIdentifier("unwindFromLogoutButton", sender: self)
	}
	
	
	func postInformation() {
		
		print("IN \(#function)")
		// TODO: segue to Post Information View
	}
	
	
	func refreshData() {
		
		print("IN \(#function)")
		// TODO: reload data, update views
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
