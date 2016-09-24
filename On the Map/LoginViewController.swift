//
//  LoginViewController.swift
//  On the Map
//
//  Created by leanne on 4/20/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

// TODO: Add keyboard toolbar for <> and Done
// TODO: Put constant strings into plist for localization

import UIKit

class LoginViewController: UIViewController {
	
	// MARK: - Constants
	
	let loginFailedTitle = "Login failed!"
	let logoutFailedTitle = "Logout failed!"
	let loggedOutTitle = "Logout succeeded!"
	let loggedOutMessage = "Logged out successfully!"
	let unableToRetrieveUserDataMessage = "Unable to retrieve user data."
	let returnActionTitle = "Return"
	
	let loginViewToTabViewSegue = "loginViewToTabViewSegue"
	
	
	// MARK: - Properties (Non-Outlets)
	
	lazy var loginModel = UdacityLogin()
	lazy var userModel = User()
	
	
	// MARK: - Properties (Outlets)
	
	@IBOutlet weak var emailField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet weak var loginButton: UIButton!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		activityIndicator.hidesWhenStopped = true
		activityIndicator.color = UIColor.blue
		activityIndicator.isHidden = true
		subscribeToNotifications()
	}
	
	deinit {
		
		// remove ourself from all notifications
		NotificationCenter.default.removeObserver(self)
	}
	
	override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
		
		// locking this login view to portrait since subviews won't all fit on smaller devices in landscape
		return .portrait
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let segueId = segue.identifier else {
			return
		}
		
		if segueId == loginViewToTabViewSegue {
			
			let navController = segue.destination as! UINavigationController
			let tabBarController = navController.childViewControllers[0] as! TabBarController
			
			tabBarController.userModel = userModel
			
			activityIndicator.stopAnimating()
		}
	}
	
	
	// MARK: - Actions
	
	@IBAction func loginClicked(_ sender: UIButton) {
		
		activityIndicator.isHidden = false
		activityIndicator.startAnimating()
		loginModel.loginToUdacity(emailField.text, password: passwordField.text)
	}
	
	
	@IBAction func unwindFromLogoutButton(_ segue: UIStoryboardSegue) {
		
		loginModel.logoutFromUdacity()
	}
	
	
	// MARK: - Notification Handlers
	
	/// Subscribes to any needed notifications.
	fileprivate func subscribeToNotifications() {
		
		NotificationCenter.default.addObserver(self,
		                                                 selector: #selector(loginDidComplete(_:)),
		                                                 name: NSNotification.Name(rawValue: loginModel.loginDidCompleteNotification),
		                                                 object: nil)
		
		NotificationCenter.default.addObserver(self,
		                                                 selector: #selector(loginDidFail(_:)),
		                                                 name: NSNotification.Name(rawValue: loginModel.loginDidFailNotification),
		                                                 object: nil)
	
		NotificationCenter.default.addObserver(self,
		                                                 selector: #selector(userDataRequestDidComplete(_:)),
		                                                 name: NSNotification.Name(rawValue: userModel.userDataRequestDidCompleteNotification),
		                                                 object: nil)

		NotificationCenter.default.addObserver(self,
		                                                 selector: #selector(userDataRequestDidFail(_:)),
		                                                 name: NSNotification.Name(rawValue: userModel.userDataRequestDidFailNotification),
		                                                 object: nil)
		
		NotificationCenter.default.addObserver(self,
		                                                 selector: #selector(logoutDidComplete(_:)),
		                                                 name: NSNotification.Name(rawValue: loginModel.logoutDidCompleteNotification),
		                                                 object: nil)
		
		NotificationCenter.default.addObserver(self,
		                                                 selector: #selector(logoutDidFail(_:)),
		                                                 name: NSNotification.Name(rawValue: loginModel.logoutDidFailNotification),
		                                                 object: nil)
		
}
	
	
	/**
	Handles actions needed when login completes successfully.
	
	- parameter: notification object
	
	 */
	func loginDidComplete(_ notification: Notification) {
		
		let accountKey = (notification as NSNotification).userInfo![loginModel.accountKey] as! String
		
		userModel.getUserInfo(accountKey)
	}
	
	
	/**
	Handles actions related to a failed login attempt.
	
	- parameter: notification object
	
	*/
	func loginDidFail(_ notification: Notification) {
		
		activityIndicator.stopAnimating()
		
		let alertViewMessage = (notification as NSNotification).userInfo![loginModel.messageKey] as! String
		let alertActionTitle = returnActionTitle

		presentAlert(loginFailedTitle, message: alertViewMessage, actionTitle: alertActionTitle)
	}
	
	
	/**
	Handles actions related to a successful logout attempt.
	
	- parameter: notification object
	
	*/
	func logoutDidComplete(_ notification: Notification) {
		
		// logout completed, so blank out username and email
		emailField.text = ""
		passwordField.text = ""
		
		activityIndicator.stopAnimating()
	}
	
	
	/**
	Handles actions related to a failed logout attempt.
	
	- parameter: notification object
	
	*/
	func logoutDidFail(_ notification: Notification) {
		
		activityIndicator.stopAnimating()
		
		let alertViewMessage = (notification as NSNotification).userInfo![loginModel.messageKey] as! String
		let alertActionTitle = returnActionTitle
		
		presentAlert(logoutFailedTitle, message: alertViewMessage, actionTitle: alertActionTitle)
	}
	
	
	/**
	Handles actions related to completion of a user data request.
	
	- parameter: notification object
	
	*/
	func userDataRequestDidComplete(_ notification: Notification) {
		
		performSegue(withIdentifier: loginViewToTabViewSegue, sender: self)
	}
	
	/**
	Handles actions related to failure of a user data request.
	
	- parameter: notification object
	
	*/
	func userDataRequestDidFail(_ notification: Notification) {
		
		let alertViewMessage = (notification as NSNotification).userInfo![loginModel.messageKey] as! String
		let alertActionTitle = returnActionTitle

		presentAlert(unableToRetrieveUserDataMessage, message: alertViewMessage, actionTitle: alertActionTitle)
	}
	
}
