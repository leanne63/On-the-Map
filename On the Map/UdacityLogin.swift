//
//  UdacityLogin.swift
//  On the Map
//
//  Created by leanne on 5/20/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import Foundation
import SystemConfiguration	// required for SCNetworkReachability

/**

Handles Udacity login-related activities.

*/
class UdacityLogin {
	
	// MARK: - Constants
	
	// notification names
	let loginDidCompleteNotification = "loginDidCompleteNotification"
	let loginDidFailNotification = "loginDidFailNotification"
	let logoutDidCompleteNotification = "logoutDidCompleteNotification"
	let logoutDidFailNotification = "logoutDidFailNotification"
	
	// dictionary keys
	let messageKey = "message"
	let accountKey = "account"
	fileprivate let idKey = "id"
	fileprivate let apiKey = "udacity"
	fileprivate let usernameKey = "username"
	fileprivate let passwordKey = "password"
	fileprivate let sessionKey = "session"
	fileprivate let accountIdKey = "key"
	fileprivate let sessionIdKey = "sessionId"
	
	// request-related
	fileprivate let urlString = "https:/www.udacity.com/api/session"
	fileprivate let postMethod = "POST"
	fileprivate let deleteMethod = "DELETE"
	fileprivate let jsonMimeType = "application/json"
	fileprivate let acceptHeader = "Accept"
	fileprivate let contentTypeHeader = "Content-Type"
	
	// failure messages
	fileprivate let missingLoginDataMessage = "Login email and password are both required."
	fileprivate let regexCreationFailureMessage = "Unable to validate email address."
	fileprivate let invalidRequestURLMessage = "Invalid request URL."
	fileprivate let jsonSerializationFailureMessage = "Unable to convert login data to required format."
	fileprivate let invalidEmailFormatMessage = "Email address isn't formatted correctly"
	fileprivate let errorReceivedMessage = "An error was received:\n"
	fileprivate let badStatusCodeMessage = "Invalid login email or password."
	fileprivate let loginDataUnavailableMessage = "Login data is unavailable."
	fileprivate let unableToParseDataMessage = "Unable to parse received data."
	fileprivate let accountDataUnavailableMessage = "Account data is  not available."
	fileprivate let sessionDataUnavailableMessage = "Session data is not available."
	fileprivate let networkUnreachableMessage = "Network connection is not available."
	
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
	fileprivate let regexEmailPattern = "[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}"
	
	
	// MARK: - Properties
	
	/// Udacity session ID; required for logging out
	fileprivate var sessionID: String?
	
	
	// MARK: - Functions
	
	/**
	
	Attempts to login to Udacity API.
	  
	- parameters:
		- email: user's Udacity email address.
		- password: user's Udacity password.
	
	 */
	func loginToUdacity(_ email: String?, password: String?) {

		// validate login data
		let validationResult = validateLoginData(email, password: password)
		guard validationResult.isSuccess, let email = email, let password = password else {
			let failureMessage = validationResult.errorMsg!
			postFailureNotification(loginDidFailNotification, failureMessage: failureMessage)
			return
		}
		
		// data is good; begin request
		guard let requestURL = URL(string: urlString) else {
			postFailureNotification(loginDidFailNotification, failureMessage: invalidRequestURLMessage)
			return
		}
		
		var request = URLRequest(url: requestURL)
		request.httpMethod = postMethod
		request.addValue(jsonMimeType, forHTTPHeaderField: acceptHeader)
		request.addValue(jsonMimeType, forHTTPHeaderField: contentTypeHeader)
		
		let jsonBodyDict = [apiKey: [usernameKey: email, passwordKey: password]]
		let jsonWritingOptions = JSONSerialization.WritingOptions()
		guard let jsonBody: Data = try? JSONSerialization.data(withJSONObject: jsonBodyDict, options: jsonWritingOptions) else {
			postFailureNotification(loginDidFailNotification, failureMessage: jsonSerializationFailureMessage)
			return
		}

		request.httpBody = jsonBody
		
		guard SCNetworkReachability.checkIfNetworkAvailable(requestURL) == true else {
			postFailureNotification(loginDidFailNotification, failureMessage: networkUnreachableMessage)
			return
		}
		
		let task = URLSession.shared.dataTask(with: request, completionHandler: {
			(data, response, error) in
			
			if let error = error {
				let errorMessage = error.localizedDescription
				let failureMessage = self.errorReceivedMessage + "\(errorMessage)"
				self.postFailureNotification(self.loginDidFailNotification, failureMessage: failureMessage)
				return
			}
			
			if let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode != 200 {
				
				let failureMessage = self.badStatusCodeMessage + " (\(statusCode))"
				self.postFailureNotification(self.loginDidFailNotification, failureMessage: failureMessage)
				return
			}
			
			guard let data = data else {
				
				self.postFailureNotification(self.loginDidFailNotification, failureMessage: self.loginDataUnavailableMessage)
				return
			}
			//print("\n*** DATA:\n\(String(data: data, encoding: String.Encoding.utf8))\n")
			
			/* "FOR ALL RESPONSES FROM THE UDACITY API, YOU WILL NEED TO SKIP THE FIRST 5 CHARACTERS OF THE RESPONSE.
			 * These characters are used for security purposes. In the examples, you will see that we subset the
			 * response data in order to skip over them." - per API doc at:
			 * https://docs.google.com/document/d/1MECZgeASBDYrbBg7RlRu9zBBLGd3_kfzsN-0FtURqn0/pub?embedded=true
			 */
			let actualStartPos = 5
			let endPos = data.count
			let range = Range(uncheckedBounds: (actualStartPos, endPos))
			let subData = data.subdata(in: range)
			//print("\n*** SUBDATA:\n\(String(data: subData, encoding: String.Encoding.utf8))\n")
			
			guard let parsedData = try? JSONSerialization.jsonObject(with: subData, options: .allowFragments) as! [String: AnyObject] else {
				
				self.postFailureNotification(self.loginDidFailNotification, failureMessage: self.unableToParseDataMessage)
				return
			}
			
			guard let accountData = parsedData[self.accountKey] as? [String: AnyObject],
				let userAccountId = accountData[self.accountIdKey] as? String else {
					
					self.postFailureNotification(self.loginDidFailNotification, failureMessage: self.accountDataUnavailableMessage)
					return
			}
			
			guard let sessionData = parsedData[self.sessionKey] as? [String: String],
				let udacitySessionId = sessionData[self.idKey] else {
					
					self.postFailureNotification(self.loginDidFailNotification, failureMessage: self.sessionDataUnavailableMessage)
					return
			}
			
			self.sessionID = udacitySessionId
			
			// post success notification for observers
			let userInfo = [self.accountKey: userAccountId]
			
			NotificationCenter.postNotificationOnMain(self.loginDidCompleteNotification, userInfo: userInfo)
		}) 
		
		task.resume()
	}

	/**
	
	Attempts to logout from Udacity API.
	
	- parameter sessionID: ID for current Udacity session.
	
	*/
	func logoutFromUdacity() {

		guard let requestURL = URL(string: urlString) else {
			postFailureNotification(logoutDidFailNotification, failureMessage: invalidRequestURLMessage)
			return
		}
		
		var request = URLRequest(url: requestURL)
		request.httpMethod = deleteMethod

		var xsrfCookie: HTTPCookie? = nil
		let sharedCookieStorage = HTTPCookieStorage.shared
		for cookie in sharedCookieStorage.cookies! {
			if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
		}
		if let xsrfCookie = xsrfCookie {
			request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
		}
		
		guard SCNetworkReachability.checkIfNetworkAvailable(requestURL) == true else {
			postFailureNotification(logoutDidFailNotification, failureMessage: networkUnreachableMessage)
			return
		}
		
		let session = URLSession.shared
		let task = session.dataTask(with: request, completionHandler: {
			
			data, response, error in
			
			if let error = error {
				let errorMessage = error.localizedDescription
				let failureMessage = self.errorReceivedMessage + "\(errorMessage)"
				self.postFailureNotification(self.logoutDidFailNotification, failureMessage: failureMessage)
				return
			}
			
			// if status code is 200, we've successfully deleted the session (ie, logged out)
			if let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode != 200 {
				
				let failureMessage = self.badStatusCodeMessage + " (\(statusCode))"
				self.postFailureNotification(self.logoutDidFailNotification, failureMessage: failureMessage)
				return
			}
			
			NotificationCenter.postNotificationOnMain(self.logoutDidCompleteNotification, userInfo: nil)
		}) 
		
		task.resume()

	}
	
	/**
	
	Validates login data for minimal correctness
	
	- returns: Tuple containing:
		* Bool indicating whether validation was successful
		* Failure message if validation unsuccessful, nil otherwise
	
	*/
	func validateLoginData(_ email: String?, password: String?) -> (isSuccess: Bool, errorMsg: String?) {
		
		var returnBool = true
		var failMessage: String? = nil
		
		// validate login email and password aren't empty
		guard let email = email , !email.isEmpty,
			let password = password , !password.isEmpty else {
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
	fileprivate func validateEmailAddressFormat(_ emailAddress: String) -> (Bool, String?) {
		
		var returnBool = true
		var failMessage: String? = nil
		
		guard let regex = try? NSRegularExpression(pattern: regexEmailPattern, options: .caseInsensitive) else {
			returnBool = false
			failMessage = regexCreationFailureMessage
			return (returnBool, failMessage)
		}
		
		// email address will be processed under the hood as an NSString
		//	if it contains UTF multi-code-unit characters, its length will differ from
		//	Swift's characters.count value; so convert to NSString for correct length
		let searchRange = NSMakeRange(0, (emailAddress as NSString).length)
		
		guard regex.numberOfMatches(in: emailAddress, options: .withoutAnchoringBounds, range: searchRange) > 0 else {
			returnBool = false
			failMessage = invalidEmailFormatMessage
			return (returnBool, failMessage)
		}
		
		// if we're here, the email has passed all the tests
		return(returnBool, failMessage)
		
	}
	
	
	// MARK: - Notification Handling
	
	/**
	
	Post notification containing a failure message.
	
	- parameter failureMessage: Failure information to be provided to observers.
	
	 */
	fileprivate func postFailureNotification(_ notificationName: String, failureMessage: String) {
		
		let userInfo = [messageKey: failureMessage]

		NotificationCenter.postNotificationOnMain(notificationName, userInfo: userInfo)
	}
	
}
