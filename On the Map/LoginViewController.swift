//
//  LoginViewController.swift
//  On the Map
//
//  Created by leanne on 4/20/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

// TODO: Add keyboard toolbar for <> and Done

import UIKit

class LoginViewController: UIViewController {
	
	// MARK: - Properties (Non-Outlets)
	
	lazy var loginModel = UdacityLogin()
	lazy var userModel = User()
	
	
	// MARK: - Properties (Outlets)
	
	@IBOutlet weak var emailField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet weak var loginButton: UIButton!
	
	
	// MARK: - Overrides
	
	override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
		
		subscribeToNotifications()
    }
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		// remove ourself from all notifications
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

	override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		
		// locking this login view to portrait since subviews won't all fit on smaller devices in landscape
		return .Portrait
	}
	
	
	// MARK: - Actions
	
	@IBAction func loginClicked(sender: UIButton) {
		
		loginModel.loginToUdacity(emailField.text, password: passwordField.text)
	}
	
	
	// MARK: - Notification Handlers
	
	/// Subscribes to any needed notifications.
	private func subscribeToNotifications() {
		
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(loginDidComplete(_:)),
		                                                 name: loginModel.loginDidCompleteNotification,
		                                                 object: nil)
		
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(loginDidFail(_:)),
		                                                 name: loginModel.loginDidFailNotification,
		                                                 object: nil)
	}
	
	
	/**
     *	Handles actions needed when login completes successfully.
	 *
	 *	- parameter: notification object
	 */
	func loginDidComplete(notification: NSNotification) {
		
		let accountKey = notification.userInfo![loginModel.accountKey] as! String
		
		userModel.getUserInfo(accountKey)
	}
	
	
	/**
	*	Handles actions related to a failed login attempt.
	*
	*	- parameter: notification object
	*/
	func loginDidFail(notification: NSNotification) {
		
		let alertViewTitle = "Login failed!"
		let alertViewMessage = notification.userInfo![loginModel.messageKey] as! String
		let alertControllerStyle = UIAlertControllerStyle.Alert
		let alertView = UIAlertController(title: alertViewTitle, message: alertViewMessage, preferredStyle: alertControllerStyle)
		
		let alertActionTitle = "Return"
		let alertActionStyle = UIAlertActionStyle.Default
		let alertActionOK = UIAlertAction(title: alertActionTitle, style: alertActionStyle, handler: nil)
		
		alertView.addAction(alertActionOK)
		
		presentViewController(alertView, animated: true, completion: nil)
	}
	
	
	/**
	 */
	func userDataRequestDidComplete(notification: NSNotification) {
		// TODO: bring up modal tab controller, set to map

	}
	
	/**
	*/
	func userDataRequestDidFail(notification: NSNotification) {
		// TODO: alert that request failed
		
	}
	
	
	
}
