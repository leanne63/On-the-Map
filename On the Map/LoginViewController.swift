//
//  LoginViewController.swift
//  On the Map
//
//  Created by leanne on 4/20/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

// TODO: Add keyboard toolbar for <> and Done
// Password field needs to be marked as such
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
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
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
			loginModel.loginToUdacity()
			
			// TODO: if successful login, get user data; use key-value observing
			// TODO: alertview for login failure - why? invalid Udacity login values or network?
			// TEST: what happens if network is unavailable?
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
	
	
	// MARK: - Private Functions
	
}
