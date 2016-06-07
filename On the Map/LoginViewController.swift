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
	
	lazy var loginModel = Login()
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
		
		let loginDataValidationResult = loginModel.validateLoginData(emailField.text, password: passwordField.text)
		
		// get Udacity session id (not retrieving data at this time)
		if loginDataValidationResult.isSuccess {
			// TODO: valid data exists; now login, retrieve session id
			loginModel.loginToUdacity(emailField.text!, password: passwordField.text!)
		}
		else {
			let alertViewTitle = "Please correct login:"
			let alertViewMessage = loginDataValidationResult.errorMsg
			let alertControllerStyle = UIAlertControllerStyle.Alert
			let alertView = UIAlertController(title: alertViewTitle, message: alertViewMessage, preferredStyle: alertControllerStyle)
			
			let alertActionTitle = "Return"
			let alertActionStyle = UIAlertActionStyle.Default
			let alertActionOK = UIAlertAction(title: alertActionTitle, style: alertActionStyle, handler: nil)
			
			alertView.addAction(alertActionOK)
			
			presentViewController(alertView, animated: true, completion: nil)
		}
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
		
		// TODO: respond to login (bring up modal tab controller, set to map)
		print("IN \(#function)")
		
		print(notification.userInfo)
	}
	
	
	/**
	*	Handles actions related to a failed login attempt.
	*
	*	- parameter: notification object
	*/
	func loginDidFail(notification: NSNotification) {
		
		print("IN \(#function)")
		
		print(notification.userInfo)

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
	
}
