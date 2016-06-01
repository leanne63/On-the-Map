//
//  Login.swift
//  On the Map
//
//  Created by leanne on 5/20/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import Foundation

/**

Represents On the Map login-related data.

*/
struct Login {
	
	// MARK: - Constants
	
	let sessionIdChanged = "sessionIdChanged"
	let sessionIdKey = "sessionIdKey"
	
	
	// MARK: - Properties
	
	/**
	
	Retrieved on successful login.
	
	*/
	var sessionId: String? {
		didSet {
			var userInfo: [String: String]?
			if let sessionId = sessionId {
				userInfo = [sessionIdKey: sessionId]
			}
			
			// post notification for observers
			let notification = NSNotification(name: sessionIdChanged, object: nil, userInfo: userInfo)
			NSNotificationCenter.defaultCenter().postNotification(notification)
		}
	}
	
	
	// MARK: - Functions
	
	func loginToUdacity() {
		// TODO: POST request to get session id
		// https://docs.google.com/document/d/1MECZgeASBDYrbBg7RlRu9zBBLGd3_kfzsN-0FtURqn0/pub?embedded=true
		print("IN: \(#function)")
	}

	func logoutFromUdacity() {
		// TODO: DELETE request with session id
		print("IN: \(#function)")
	}
	
	/**
	
	Validate login data for minimal correctness
	
	- returns: Tuple containing
	- Bool indicating whether validation was successful
	- Failure message if validation unsuccessful, nil otherwise
	
	*/
	func validateLoginData(email: String?, password: String?) -> (isSuccess: Bool, errorMsg: String?) {
		
		var returnBool = true
		var failMessage: String? = nil
		
		// validate login email and password aren't empty
		guard let email = email where !email.isEmpty,
			let password = password where !password.isEmpty else {
				returnBool = false
				failMessage = "login email and password are both required"
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
			failMessage = "unable to validate email address"
			return (returnBool, failMessage)
		}
		
		// email address will be processed under the hood as an NSString
		//	if it contains UTF multi-code-unit characters, its length will differ from
		//	Swift's characters.count value; so convert to NSString for correct length
		let searchRange = NSMakeRange(0, (emailAddress as NSString).length)
		
		guard regex.numberOfMatchesInString(emailAddress, options: .WithoutAnchoringBounds, range: searchRange) > 0 else {
			returnBool = false
			failMessage = "email address isn't formatted correctly"
			return (returnBool, failMessage)
		}
		
		// if we're here, the email has passed all the tests
		return(returnBool, failMessage)
		
	}
	


}
