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
		
		let loginDataValidationResult = validateLoginData()
		print("loginDataValidationResult = \(loginDataValidationResult)")
		
		
		// get Udacity session id (not retrieving data at this time)
		if loginDataValidationResult.isSuccess {
			// TODO: valid data exists; now login, retrieve session id
			loginModel.login()
			
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
	
	/**
	
	Validate login data for minimal correctness
	
	- returns: Tuple containing
		- Bool indicating whether validation was successful
		- Failure message if validation unsuccessful, nil otherwise
	
	*/
	private func validateLoginData() -> (isSuccess: Bool, errorMsg: String?) {
		
		var returnBool = true
		var failMessage: String? = nil
		
		// validate login email and password aren't empty
		guard let email = emailField.text where !email.isEmpty,
			  let password = passwordField.text where !password.isEmpty else {
			returnBool = false
			failMessage = "Login email and password are both required!"
			return (returnBool, failMessage)
		}
		
		// validate basic email format
		let successData: (isSuccess: Bool, errorMsg: String?) = validateEmailAddressFormat(email)
		if !successData.isSuccess {
			returnBool = false
			failMessage = successData.errorMsg
			return (returnBool, failMessage)
		}
		
		return (returnBool, failMessage)
	}
	
	
	/**
	
	Validate email address string for correct format
	
	- parameter emailAddress: an email address to validate
	
	- returns: Tuple containing:
		- Bool indicating whether validation was successful
		- Failure message if validation unsuccessful, nil otherwise
	
	*/
	private func validateEmailAddressFormat(emailAddress: String) -> (Bool, String?) {
		
		var returnBool = true
		var failMessage: String? = nil
		
		// NSRegularExpression to ensure email in at least a correct format before sending
		// [A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}
		// [A-Z0-9._%+-]+
		//		matches letters A thru Z, digits 0 thru 9, dot, underscore, percent, plus, hyphen
		//			occurring 1 or more times (+)
		// @ matches literal "at" character
		// [A-Z0-9.-]+
		//		matches letters A thru Z, digits 0 thru 9, dot, hyphen occurring 1 or more times (+)
		// \. matches literal "dot" character
		//		(note: our version has two backslashes - the first is escaping the 2nd, real backslash)
		// [A-Z]{2,}
		//		matches letters A thru Z occurring 2 or more times
		// Note: regular expression matches are case sensitive by default;
		//	we'll use NSRegularExpressionOptions.CaseInsensitive to ignore that
		let regexPattern = "[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}"
		guard let regex = try? NSRegularExpression(pattern: regexPattern, options: .CaseInsensitive) else {
			returnBool = false
			failMessage = "Unable to validate email address!"
			return (returnBool, failMessage)
		}
		
		// email address will be processed under the hood as an NSString
		//	if it contains UTF multi-code-unit characters, its length will differ from
		//	Swift's characters.count value; so convert to NSString for correct length
		let searchRange = NSMakeRange(0, (emailAddress as NSString).length)
		
		guard regex.numberOfMatchesInString(emailAddress, options: .WithoutAnchoringBounds, range: searchRange) > 0 else {
			returnBool = false
			failMessage = "Email address is invalid!"
			return (returnBool, failMessage)
		}
		
		// if we're here, the email has passed all the tests
		return(returnBool, failMessage)
		
	}

}
