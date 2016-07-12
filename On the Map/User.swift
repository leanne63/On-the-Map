//
//  User.swift
//  On the Map
//
//  Created by leanne on 5/5/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import Foundation

// TODO: remove this class if not needed (session from login; student data from Parse!)
/// Represents On the Map user-related data.
class User {
	
	// MARK: - Constants
	
	// notification names
	let userDataRequestDidCompleteNotification = "userDataRequestDidCompleteNotification"
	let userDataRequestDidFailNotification = "userDataRequestDidFailNotification"
	
	// request-related
	private let urlString = "https://www.udacity.com/api/users/"
	
	// dictionary keys
	let messageKey = "message"
	private let userKey = "user"
	
	// failure messages
	private let invalidRequestURLMessage = "Invalid request URL."
	private let errorReceivedMessage = "An error was received:\n"
	private let badStatusCodeMessage = "Invalid login email or password."
	private let userDataUnavailableMessage = "User data unavailable."
	private let unableToParseDataMessage = "Unable to parse received data."
	private let unableToParseUserDataMessage = "Unable to parse user data."

	
	// MARK: - Properties
	
	// values will differ based on account used to log in
	var userId: String!
	var firstName: String!
	var lastName: String!
	var nickname: String?
	
	
	// MARK: - Public Functions
	
	func getUserInfo(accountId: String) {
		
		let apiURL = urlString + accountId
		guard let requestURL = NSURL(string: apiURL) else {
			let failureMessage = invalidRequestURLMessage
			postFailureNotification(failureMessage)
			return
		}
		
		let request = NSMutableURLRequest(URL: requestURL)

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
				
				self.postFailureNotification(self.userDataUnavailableMessage)
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
			
			guard let userData = parsedData[self.userKey] as? [String: AnyObject] else {
				
				self.postFailureNotification(self.unableToParseUserDataMessage)
				return
			}
			
			self.userId = accountId
			self.firstName = userData["first_name"] as? String
			self.lastName = userData["last_name"] as? String
			self.nickname = userData["nickname"] as? String
			
			NSNotificationCenter.postNotificationOnMain(self.userDataRequestDidCompleteNotification, userInfo: nil)
		}
		
		task.resume()
	}
	
	// MARK: - Notification Handling
	
	/**
	
	Post notification containing a failure message.
	
	- parameter failureMessage: Failure information to be provided to observers.
	
	*/
	private func postFailureNotification(failureMessage: String) {
		
		let userInfo = [messageKey: failureMessage]
		
		NSNotificationCenter.postNotificationOnMain(userDataRequestDidFailNotification, userInfo: userInfo)
	}
	
}
