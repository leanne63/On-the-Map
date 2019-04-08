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
	
	// request-related (GET)
	//fileprivate let urlString = "https://www.udacity.com/api/users/" // chg'd per email from Owen at Udacity, Fri, Nov 30, 7:03 PM
	fileprivate let urlString = "https://onthemap-api.udacity.com/v1/users/"
	
	// dictionary keys
	let messageKey = "message"
	fileprivate let userKey = "user"
	//fileprivate let userKey = "key"
	
	// failure messages
	fileprivate let invalidRequestURLMessage = "Invalid request URL."
	fileprivate let errorReceivedMessage = "An error was received:\n"
	fileprivate let badStatusCodeMessage = "Invalid login email or password."
	fileprivate let userDataUnavailableMessage = "User data unavailable."
	fileprivate let unableToParseDataMessage = "Unable to parse received data."
	fileprivate let unableToParseUserDataMessage = "Unable to parse user data."

	
	// MARK: - Properties
	
	// values will differ based on account used to log in
	var userId: String!
	var firstName: String!
	var lastName: String!
	var nickname: String?
	
	
	// MARK: - Public Functions
	
	func getUserInfo(_ accountId: String) {
		
		let apiURL = urlString + accountId
		guard let requestURL = URL(string: apiURL) else {
			let failureMessage = invalidRequestURLMessage
			postFailureNotification(failureMessage)
			return
		}
		
		let request = URLRequest(url: requestURL)

		let task = URLSession.shared.dataTask(with: request, completionHandler: {
			(data, response, error) in
			
			if let error = error {
				let errorMessage = error.localizedDescription
				let failureMessage = self.errorReceivedMessage + "\(errorMessage)"
				self.postFailureNotification(failureMessage)
				return
			}
			
			if let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode != 200 {
				
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
			let actualStartPos = 5
			let endPos = data.count
			let range = Range(uncheckedBounds: (actualStartPos, endPos))
			let subData = data.subdata(in: range)
			
			guard let parsedData = try? JSONSerialization.jsonObject(with: subData, options: []) as? [String: AnyObject] else {
				
				self.postFailureNotification(self.unableToParseDataMessage)
				return
			}
			
//			guard let userData = parsedData[self.userKey] as? [String: AnyObject] else {
//				
//				self.postFailureNotification(self.unableToParseUserDataMessage)
//				return
//			}
//			
//			self.userId = accountId
//			self.firstName = userData["first_name"] as? String
//			self.lastName = userData["last_name"] as? String
//			self.nickname = userData["nickname"] as? String
			
			self.userId = accountId
			self.firstName = parsedData["first_name"] as? String
			self.lastName = parsedData["last_name"] as? String
			self.nickname = parsedData["nickname"] as? String

			
			NotificationCenter.postNotificationOnMain(self.userDataRequestDidCompleteNotification, userInfo: nil)
		}) 
		
		task.resume()
	}
	
	// MARK: - Notification Handling
	
	/**
	
	Post notification containing a failure message.
	
	- parameter failureMessage: Failure information to be provided to observers.
	
	*/
	fileprivate func postFailureNotification(_ failureMessage: String) {
		
		let userInfo = [messageKey: failureMessage]
		
		NotificationCenter.postNotificationOnMain(userDataRequestDidFailNotification, userInfo: userInfo)
	}
	
}
