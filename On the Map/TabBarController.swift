//
//  TabBarController.swift
//  On the Map
//
//  Created by leanne on 7/6/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
	
	// MARK: - Constants
	
	let logoutButtonTitle = "Logout"
	let pinImageName = "pin"
	let unwindFromLogoutButtonSegueID = "unwindFromLogoutButton"
	let tabBarPinToInfoPostingViewSegueID = "tabBarPinToInfoPostingViewSegue"
	
	
	// MARK: - Properties
	
	var userModel: User!

	
	// MARK: - Overrides
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		// set up navigation bar items
		navigationItem.title = "On The Map"
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: logoutButtonTitle, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(doLogout))
		
		let pinButton = UIBarButtonItem(image: UIImage(named: pinImageName), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(postInformation))
		let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(retrieveUserData))
		
		// note: right bar buttons in array appear on nav bar right to left
		navigationItem.rightBarButtonItems = [refreshButton, pinButton]
		
		// do initial data call
		retrieveUserData()
    }
	
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		// if moving to posting information view, pass user data
		if segue.identifier == tabBarPinToInfoPostingViewSegueID {
			let viewController = segue.destinationViewController as! InfoPostingViewController
			
			viewController.userModel = userModel
		}
	}
	
	
	// MARK: - Selectors
	
	/// Segues back (unwinds) to logout function
	func doLogout() {
		
		performSegueWithIdentifier(unwindFromLogoutButtonSegueID, sender: nil)
	}
	
	
	/// Segues to Information Posting view
	func postInformation() {
		
		performSegueWithIdentifier(tabBarPinToInfoPostingViewSegueID, sender: nil)
	}
	
	
	/// Calls out for user information
	func retrieveUserData() {
		
		let parseInstance = Parse()
		parseInstance.retrieveMapData()
	}
	
}
