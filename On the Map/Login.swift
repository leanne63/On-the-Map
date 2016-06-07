//
//  Login.swift
//  On the Map
//
//  Created by leanne on 5/20/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import Foundation

/**

Handles On the Map login-related activities.

*/
struct Login {
	
	// MARK: - Constants
	
	// notification names
	let loginDidCompleteNotification = "loginDidCompleteNotification"
	let loginDidFailNotification = "loginDidFailNotification"
	
	// dictionary keys
	let idKey = "id"
	let apiKey = "udacity"
	let usernameKey = "username"
	let passwordKey = "password"
	let accountKey = "account"
	let sessionKey = "session"
	let accountIdKey = "key"
	let sessionIdKey = "sessionId"
	let messageKey = "message"
	
	// request-related
	let urlString = "https:/www.udacity.com/api/session"
	let postMethod = "POST"
	let jsonMimeType = "application/json"
	let acceptHeader = "Accept"
	let contentTypeHeader = "Content-Type"
	
	// failure messages
	let missingLoginDataMessage = "Login email and password are both required."
	let regexCreationFailureMessage = "Unable to validate email address."
	let jsonSerializationFailureMessage = "Unable to convert login data to required format."
	let invalidEmailFormatMessage = "Email address isn't formatted correctly"
	let errorReceivedMessage = "An error was received:\n"
	let badStatusCodeMessage = "Invalid login email or password."
	let loginDataUnavailableMessage = "Login data unavailable."
	let unableToParseDataMessage = "Unable to parse received data."
	let accountDataUnavailableMessage = "Account data unavailable."
	let sessionDataUnavailableMessage = "Session data unavailable."
	
	// regular expression patterns, including pattern explanation
	/*
	 * NSRegularExpression to ensure email in at least a correct format before sending
	 * [A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}
	 * [A-Z0-9._%+-]+
	 *		matches letters A thru Z, digits 0 thru 9, dot, underscore, percent, plus, hyphen
	 *			occurring 1 or more times (+)
	 * @ matches literal "at" character
	 * [A-Z0-9.-]+
	 *		matches letters A thru Z, digits 0 thru 9, dot, hyphen occurring 1 or more times (+)
	 * \. matches literal "dot" character
	 *		(note: our version has two backslashes - the first is escaping the 2nd, real backslash)
	 * [A-Z]{2,}
	 *		matches letters A thru Z occurring 2 or more times
	 * Note: regular expression matches are case sensitive by default;
	 *	we'll use NSRegularExpressionOptions.CaseInsensitive to ignore that
	 */
	let regexEmailPattern = "[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}"

	
	
	// MARK: - Functions
	
	/**
	Attempts to login to Udacity API.
	  
	- parameters:
		- email: user's Udacity email address.
		- password: user's Udacity password.
	 */
	func loginToUdacity(email: String, password: String) {

		guard let requestURL = NSURL(string: urlString) else {
			// send login failure notification
			return
		}
		
		let request = NSMutableURLRequest(URL: requestURL)
		request.HTTPMethod = postMethod
		request.addValue(jsonMimeType, forHTTPHeaderField: acceptHeader)
		request.addValue(jsonMimeType, forHTTPHeaderField: contentTypeHeader)
		
		let jsonBodyDict = [apiKey: [usernameKey: email, passwordKey: password]]
		let jsonWritingOptions = NSJSONWritingOptions()
		guard let jsonBody: NSData = try? NSJSONSerialization.dataWithJSONObject(jsonBodyDict, options: jsonWritingOptions) else {
			let failureMessage = jsonSerializationFailureMessage
			postFailureNotification(failureMessage)
			return
		}

		request.HTTPBody = jsonBody
		
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
			(data, response, error) in
			
			if error != nil {
				
				let errorMessage = error!.userInfo[NSLocalizedDescriptionKey] as! String
				let failureMessage = self.errorReceivedMessage + "\(errorMessage)"
				self.postFailureNotification(failureMessage)
				return
			}
			
			if let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode != 200 {
				
				let failureMessage = self.badStatusCodeMessage + " (\(statusCode))"
				self.postFailureNotification(failureMessage)
				return
			}
			
			guard let data = data else {
				
				self.postFailureNotification(self.loginDataUnavailableMessage)
				return
			}
			
			/* "FOR ALL RESPONSES FROM THE UDACITY API, YOU WILL NEED TO SKIP THE FIRST 5 CHARACTERS OF THE RESPONSE.
			 * These characters are used for security purposes. In the examples, you will see that we subset the
			 * response data in order to skip over them." - per API doc at:
			 * https://docs.google.com/document/d/1MECZgeASBDYrbBg7RlRu9zBBLGd3_kfzsN-0FtURqn0/pub?embedded=true
			 */
			let range = NSMakeRange(5, data.length - 5)
			let subData = data.subdataWithRange(range)
			
			guard let parsedData = try? NSJSONSerialization.JSONObjectWithData(subData, options: .AllowFragments) else {
				
				self.postFailureNotification(self.unableToParseDataMessage)
				return
			}
			
			guard let accountData = parsedData[self.accountKey] as? [String: AnyObject],
				let userAccountId = accountData[self.accountIdKey] as? String else {
					
					self.postFailureNotification(self.accountDataUnavailableMessage)
					return
			}
			
			guard let sessionData = parsedData[self.sessionKey] as? [String: String],
				let udacitySessionId = sessionData[self.idKey] else {
					
					self.postFailureNotification(self.sessionDataUnavailableMessage)
					return
			}
			
			// post notification for observers
			let userInfo = [
				self.accountKey: userAccountId,
				self.sessionIdKey: udacitySessionId
			]
			
			self.postNotificationOnMain(self.loginDidCompleteNotification, userInfo: userInfo)
		}
		
		task.resume()
		
		// TODO: what happens if network is unavailable?

	}

	/**
	
	Attempts to logout from Udacity API.
	
	- parameter sessionID: ID for current Udacity session.
	
	*/
	func logoutFromUdacity() {
		// TODO: DELETE request with session id
		print("IN: \(#function)")
	}
	
	/**
	
	Validates login data for minimal correctness
	
	- returns: Tuple containing:
		* Bool indicating whether validation was successful
		* Failure message if validation unsuccessful, nil otherwise
	
	*/
	func validateLoginData(email: String?, password: String?) -> (isSuccess: Bool, errorMsg: String?) {
		
		var returnBool = true
		var failMessage: String? = nil
		
		// validate login email and password aren't empty
		guard let email = email where !email.isEmpty,
			let password = password where !password.isEmpty else {
				returnBool = false
				failMessage = missingLoginDataMessage
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
		* Bool indicating whether validation was successful
		* Failure message if validation unsuccessful, nil otherwise
	
	*/
	private func validateEmailAddressFormat(emailAddress: String) -> (Bool, String?) {
		
		var returnBool = true
		var failMessage: String? = nil
		
		guard let regex = try? NSRegularExpression(pattern: regexEmailPattern, options: .CaseInsensitive) else {
			returnBool = false
			failMessage = regexCreationFailureMessage
			return (returnBool, failMessage)
		}
		
		// email address will be processed under the hood as an NSString
		//	if it contains UTF multi-code-unit characters, its length will differ from
		//	Swift's characters.count value; so convert to NSString for correct length
		let searchRange = NSMakeRange(0, (emailAddress as NSString).length)
		
		guard regex.numberOfMatchesInString(emailAddress, options: .WithoutAnchoringBounds, range: searchRange) > 0 else {
			returnBool = false
			failMessage = invalidEmailFormatMessage
			return (returnBool, failMessage)
		}
		
		// if we're here, the email has passed all the tests
		return(returnBool, failMessage)
		
	}
	
	
	// MARK: - Notification Handling
	
	/**
	
	Sets up notification containing a failure message.
	
	- parameter failureMessage: Failure information to be provided to observers.
	
	 */
	func postFailureNotification(failureMessage: String) {
		
		let userInfo = [messageKey: failureMessage]
		postNotificationOnMain(loginDidFailNotification, userInfo: userInfo)
	}
	
	
	/**
	
	Creates and posts a notification to the main thread.
	
	- parameters:
		- notificationName: Notification name to be provided to observers.
		- userInfo: Dictionary of custom information to be provided to observers, or nil if none needed.
	
	 */
	func postNotificationOnMain(notificationName: String, userInfo: [String: String]?) {
		
		let notification = NSNotification(name: notificationName, object: nil, userInfo: userInfo)
		
		NSOperationQueue.mainQueue().addOperationWithBlock {
			NSNotificationCenter.defaultCenter().postNotification(notification)
		}
	}
	
}
