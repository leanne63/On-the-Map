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
		
		// TODO: remove this if notifications not needed here
		subscribeToNotifications()

		// set up navigation bar items
		navigationItem.title = "On The Map"
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(doLogout))
		
		let pinButton = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(postInformation))
		let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(retrieveUserData))
		
		// note: right bar buttons in array appear on nav bar right to left
		navigationItem.rightBarButtonItems = [refreshButton, pinButton]
		
		// do initial data call
		retrieveUserData()
    }
	
	
	deinit {
		
		// unsubscribe ourself from any notifications
		NSNotificationCenter.defaultCenter().removeObserver(self)
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
	
	
	/// Calls out for user information
	func retrieveUserData() {
		
		let parseInstance = Parse()
		parseInstance.retrieveMapData()
	}
	
	
	// TODO: remove below if notifications not needed here
	// MARK: - Notification Handlers
	
	private func subscribeToNotifications() {
		
//		NSNotificationCenter.defaultCenter().addObserver(self,
//		                                                 selector: #selector(parseRetrievalDidComplete(_:)),
//		                                                 name: Parse.parseRetrievalDidCompleteNotification,
//		                                                 object: nil)
//	
//		NSNotificationCenter.defaultCenter().addObserver(self,
//		                                                 selector: #selector(parseRetrievalDidFail(_:)),
//		                                                 name: Parse.parseRetrievalDidFailNotification,
//		                                                 object: nil)
	}
	
	
	// TODO: move this (or both these?) into map and table view controllers? They're the ones using the data...
	func parseRetrievalDidComplete(notification: NSNotification) {
		
		// TODO: share data as needed with view controllers
		print(Parse.parseRetrievalDidCompleteNotification)
		print("Student Info:\n\(StudentInformationModel.students)")
	}

	func parseRetrievalDidFail(notification: NSNotification) {
		
		// TODO: what to do if fails???
		print(Parse.parseRetrievalDidFailNotification)
	}
	
}
