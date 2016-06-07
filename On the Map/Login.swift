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
	let errorReceivedMessage = "An error was received:\n"
	let badStatusCodeMessage = "Invalid login email or password."
	let loginDataUnavailableMessage = "Login data unavailable."
	let unableToParseDataMessage = "Unable to parse received data."
	let accountDataUnavailableMessage = "Account data unavailable."
	let sessionDataUnavailableMessage = "Session data unavailable."
	
	
	// MARK: - Functions
	
	func loginToUdacity(email: String, password: String) {
		// TODO: POST request to get session id
		// https://docs.google.com/document/d/1MECZgeASBDYrbBg7RlRu9zBBLGd3_kfzsN-0FtURqn0/pub?embedded=true
		print("IN: \(#function)")
		
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
			// TODO: send failure notification
			return
		}

		request.HTTPBody = jsonBody
		
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
			(data, response, error) in
			
			func postFailureNotification(failureMessage: String) {

				let userInfo = [self.messageKey: failureMessage]
				let notification = NSNotification(name: self.loginDidFailNotification, object: nil, userInfo: userInfo)
				postNotificationOnMain(notification)
			}
			
			func postNotificationOnMain(notification: NSNotification) {
				
				NSOperationQueue.mainQueue().addOperationWithBlock {
					NSNotificationCenter.defaultCenter().postNotification(notification)
				}
			}
			
			if error != nil {
				
				let errorMessage = error!.userInfo[NSLocalizedDescriptionKey] as! String
				let failureMessage = self.errorReceivedMessage + "\(errorMessage)"
				postFailureNotification(failureMessage)
				return
			}
			
			if let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode != 200 {
				
				let failureMessage = self.badStatusCodeMessage + " (\(statusCode))"
				postFailureNotification(failureMessage)
				return
			}
			
			guard let data = data else {
				
				postFailureNotification(self.loginDataUnavailableMessage)
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
				
				postFailureNotification(self.unableToParseDataMessage)
				return
			}
			
			guard let accountData = parsedData[self.accountKey] as? [String: AnyObject],
				let userAccountId = accountData[self.accountIdKey] as? String else {
					
					postFailureNotification(self.accountDataUnavailableMessage)
					return
			}
			
			guard let sessionData = parsedData[self.sessionKey] as? [String: String],
				let udacitySessionId = sessionData[self.idKey] else {
					
					postFailureNotification(self.sessionDataUnavailableMessage)
					return
			}
			
			let userInfo = [
				self.accountKey: userAccountId,
				self.sessionIdKey: udacitySessionId
			]
			
			// post notification for observers
			let notification = NSNotification(name: self.loginDidCompleteNotification, object: nil, userInfo: userInfo)
			postNotificationOnMain(notification)
		}
		
		task.resume()
		
		// TODO: what happens if network is unavailable?

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
