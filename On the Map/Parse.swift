//
//  Parse.swift
//  On the Map
//
//  Created by leanne on 6/30/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

// TODO: set retrieveMapData as class func? if so, constants should be static/class variables

import Foundation
import SystemConfiguration	// required for SCNetworkReachability


/// Handles map data (provided via Parse API)
struct Parse {
	
	// MARK: - Constants
	
	// notification names
	static let parseRetrievalDidCompleteNotification = "parseRetrievalDidComplete"
	static let parseRetrievalDidFailNotification = "parseRetrievalDidFail"
	static let parsePostDidCompleteNotification = "parsePostDidComplete"
	static let parsePostDidFailNotification = "parsePostDidFail"
	
	// dictionary keys
	static let messageKey = "message"
	static let resultsKey = "results"

	// request-related
	private let limitParm = "limit"
	private let limitValue = "100"
	private let orderParm = "order"
	private let orderValue = "-updatedAt"
	private let apiScheme = "https"
	private let apiHost = "api.parse.com"
	private let apiPath = "/1/classes/StudentLocation"
	private let getMethod = "GET"
	private let postMethod = "POST"
	private let parseApplicationId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
	private let parseRESTAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
	private let jsonContentType = "application/json"
	private let xParseApplicationId = "X-Parse-Application-Id"
	private let xParseRESTAPIKey = "X-Parse-REST-API-Key"
	private let xParseContentTypeKey = "Content-Type"
	
	// failure messages
	private let invalidRequestURLMessage = "Invalid request URL."
	private let networkUnreachableMessage = "Network connection is not available."
	private let errorReceivedMessage = "An error was received:\n"
	private let badStatusCodeMessage = "Unable to retrieve data from server."
	private let locationDataUnavailableMessage = "Location data is unavailable."
	private let unableToParseDataMessage = "Unable to parse received data."
	private let jsonSerializationFailureMessage = "Unable to convert post data to JSON format."
	private let noDataReceivedMessage = "No data received from Parse server."
	private let invalidDataReceivedMessage = "Invalid data received from Parse server."


	// MARK: - Functions
	
	func retrieveMapData() {
		
		let methodParameters = [
			limitParm: limitValue,
			orderParm: orderValue
		]
		
		let requestURL = createURLFromParameters(methodParameters)
		let request = NSMutableURLRequest(URL: requestURL)
		
		request.addValue(parseApplicationId, forHTTPHeaderField: xParseApplicationId)
		request.addValue(parseRESTAPIKey, forHTTPHeaderField: xParseRESTAPIKey)
	
		guard SCNetworkReachability.checkIfNetworkAvailable(requestURL) == true else {
			postFailureNotification(Parse.parseRetrievalDidFailNotification, failureMessage: networkUnreachableMessage)
			return
		}
		
		let session = NSURLSession.sharedSession()
		let task = session.dataTaskWithRequest(request) {

			(data, response, error) in
			
			guard error == nil else {
				
				let errorMessage = error!.userInfo[NSLocalizedDescriptionKey] as! String
				let failureMessage = self.errorReceivedMessage + "\(errorMessage)"
				self.postFailureNotification(Parse.parseRetrievalDidFailNotification, failureMessage: failureMessage)
				return
			}
		
			if let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode != 200 {
				
				let failureMessage = self.badStatusCodeMessage + " (\(statusCode))"
				self.postFailureNotification(Parse.parseRetrievalDidFailNotification, failureMessage: failureMessage)
				return
			}
			
			guard let data = data else {
				
				self.postFailureNotification(Parse.parseRetrievalDidFailNotification, failureMessage: self.locationDataUnavailableMessage)
				return
			}
			
			let options = NSJSONReadingOptions()
			guard let parsedData = try? NSJSONSerialization.JSONObjectWithData(data, options: options),
				let results = parsedData[Parse.resultsKey] as? [[String: AnyObject]] else {
				
				self.postFailureNotification(Parse.parseRetrievalDidFailNotification, failureMessage: self.unableToParseDataMessage)
				return
			}
			
			for studentItem in results {
				
				StudentInformationModel.addStudent(StudentInformation(studentItem))
			}
			
			NSNotificationCenter.postNotificationOnMain(Parse.parseRetrievalDidCompleteNotification, userInfo: nil)
		}
		
		task.resume()
}
	
	
	func postStudentData(studentInfo: StudentInformation) {
		
		let requestURL = createURLFromParameters(nil)
		let request = NSMutableURLRequest(URL: requestURL)
		
		request.HTTPMethod = postMethod
		
		request.addValue(parseApplicationId, forHTTPHeaderField: xParseApplicationId)
		request.addValue(parseRESTAPIKey, forHTTPHeaderField: xParseRESTAPIKey)
		request.addValue(jsonContentType, forHTTPHeaderField: xParseContentTypeKey)
		
		let jsonBodyDict = StudentInformationModel.convertStudentInfoToParseDict(studentInfo)
		let jsonWritingOptions = NSJSONWritingOptions()
		
		guard let jsonBody: NSData = try? NSJSONSerialization.dataWithJSONObject(jsonBodyDict, options: jsonWritingOptions) else {
			postFailureNotification(Parse.parsePostDidFailNotification, failureMessage: jsonSerializationFailureMessage)
			return
		}
		
		request.HTTPBody = jsonBody
		
		guard SCNetworkReachability.checkIfNetworkAvailable(requestURL) == true else {
			postFailureNotification(Parse.parsePostDidFailNotification, failureMessage: networkUnreachableMessage)
			return
		}
		
		let session = NSURLSession.sharedSession()
		let task = session.dataTaskWithRequest(request) {
			
			(data, response, error) in
			
			guard error == nil else {
				
				let errorMessage = error!.userInfo[NSLocalizedDescriptionKey] as! String
				let failureMessage = self.errorReceivedMessage + "\(errorMessage)"
				self.postFailureNotification(Parse.parsePostDidFailNotification, failureMessage: failureMessage)
				return
			}
			
			// status code = 201 means successfully updated; but anything in the 200 range should indicate success
			guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
				
				let failureMessage = self.badStatusCodeMessage + " (\((response as? NSHTTPURLResponse)?.statusCode))"
				self.postFailureNotification(Parse.parsePostDidFailNotification, failureMessage: failureMessage)
				return
			}

			guard let data = data else {
				
				self.postFailureNotification(Parse.parsePostDidFailNotification, failureMessage: self.noDataReceivedMessage)
				return
			}
			
			let options = NSJSONReadingOptions()
			guard let parsedData = try? NSJSONSerialization.JSONObjectWithData(data, options: options) else {
					
					self.postFailureNotification(Parse.parsePostDidFailNotification, failureMessage: self.unableToParseDataMessage)
					return
			}
			
			guard parsedData[StudentInformationModel.createdAtKey] != nil && parsedData[StudentInformationModel.objectIDKey] != nil else {
				
				self.postFailureNotification(Parse.parsePostDidFailNotification, failureMessage: self.invalidDataReceivedMessage)
				return
			}

			NSNotificationCenter.postNotificationOnMain(Parse.parsePostDidCompleteNotification, userInfo: nil)
		}
		
		task.resume()
	}
	
	
	// MARK: - Notification Handling
	
	/**
	
	Post notification containing a failure message.
	
	- parameter failureMessage: Failure information to be provided to observers.
	
	*/
	private func postFailureNotification(notificationName: String, failureMessage: String) {
		
		let userInfo = [Parse.messageKey: failureMessage]
		
		NSNotificationCenter.postNotificationOnMain(notificationName, userInfo: userInfo)
	}
	
	
	//: MARK: - Private Functions
	
	func createURLFromParameters(parameters: [String:AnyObject]?) -> NSURL {
		
		let components = NSURLComponents()
		components.scheme = apiScheme
		components.host = apiHost
		components.path = apiPath
		components.queryItems = [NSURLQueryItem]()
		
		if let parameters = parameters {
			for (key, value) in parameters {
				let queryItem = NSURLQueryItem(name: key, value: "\(value)")
				components.queryItems!.append(queryItem)
			}
		}
		
		return components.URL!
	}

}