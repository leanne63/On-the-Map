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
	static let parsePutDidCompleteNotification = "parsePutDidComplete"
	static let parsePutDidFailNotification = "parsePutDidFail"
	
	// dictionary keys
	static let messageKey = "message"
	static let resultsKey = "results"

	// request-related
	fileprivate let limitParm = "limit"
	fileprivate let limitValue = "100"
	fileprivate let orderParm = "order"
	fileprivate let orderValue = "-updatedAt"
	fileprivate let apiScheme = "https"
	/*
		from:
		https://discussions.udacity.com/t/is-the-parse-database-down/181702/7
		
		new Parse path:
		https://api.parse.com/1/classes becomes https://parse.udacity.com/parse/classes
	*/
//	fileprivate let apiHost = "api.parse.com"
//	fileprivate let apiPath = "/1/classes/StudentLocation"
	fileprivate let apiHost = "parse.udacity.com"
	fileprivate let apiPath = "/parse/classes/StudentLocation"
	fileprivate let getMethod = "GET"
	fileprivate let postMethod = "POST"
	fileprivate let putMethod = "PUT"
	fileprivate let parseApplicationId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
	fileprivate let parseRESTAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
	fileprivate let jsonContentType = "application/json"
	fileprivate let xParseApplicationId = "X-Parse-Application-Id"
	fileprivate let xParseRESTAPIKey = "X-Parse-REST-API-Key"
	fileprivate let xParseContentTypeKey = "Content-Type"
	
	// failure messages
	fileprivate let invalidRequestURLMessage = "Invalid request URL."
	fileprivate let networkUnreachableMessage = "Network connection is not available."
	fileprivate let errorReceivedMessage = "An error was received:\n"
	fileprivate let badStatusCodeMessage = "Unable to retrieve data from server."
	fileprivate let locationDataUnavailableMessage = "Location data is unavailable."
	fileprivate let unableToParseDataMessage = "Unable to parse received data."
	fileprivate let jsonSerializationFailureMessage = "Unable to convert post data to JSON format."
	fileprivate let noDataReceivedMessage = "No data received from Parse server."
	fileprivate let invalidDataReceivedMessage = "Invalid data received from Parse server."


	// MARK: - Functions
	
	func retrieveMapData() {
		
		let methodParameters = [
			limitParm: limitValue,
			orderParm: orderValue
		]
		
		let requestURL = createURLFromParameters(methodParameters as [String : AnyObject]?, pathExtension: nil)
		var request = URLRequest(url: requestURL)
		
		request.addValue(parseApplicationId, forHTTPHeaderField: xParseApplicationId)
		request.addValue(parseRESTAPIKey, forHTTPHeaderField: xParseRESTAPIKey)
	
		guard SCNetworkReachability.checkIfNetworkAvailable(requestURL) == true else {
			postFailureNotification(Parse.parseRetrievalDidFailNotification, failureMessage: networkUnreachableMessage)
			return
		}
		
		let session = URLSession.shared
		let task = session.dataTask(with: request, completionHandler: {

			(data, response, error) in
			
			if let error = error {
				let errorMessage = error.localizedDescription
				let failureMessage = self.errorReceivedMessage + "\(errorMessage)"
				self.postFailureNotification(Parse.parseRetrievalDidFailNotification, failureMessage: failureMessage)
				return
			}
		
			if let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode != 200 {
				
				let failureMessage = self.badStatusCodeMessage + " (\(statusCode))"
				self.postFailureNotification(Parse.parseRetrievalDidFailNotification, failureMessage: failureMessage)
				return
			}
			
			guard let data = data else {
				
				self.postFailureNotification(Parse.parseRetrievalDidFailNotification, failureMessage: self.locationDataUnavailableMessage)
				return
			}
			
			let options = JSONSerialization.ReadingOptions()
			guard let parsedData = try? JSONSerialization.jsonObject(with: data, options: options) as? [String: AnyObject],
				let results = parsedData[Parse.resultsKey] as? [[String: AnyObject]] else {
				
				self.postFailureNotification(Parse.parseRetrievalDidFailNotification, failureMessage: self.unableToParseDataMessage)
				return
			}

			StudentInformationModel.populateStudentList(withStudents: results)
			
			NotificationCenter.postNotificationOnMain(Parse.parseRetrievalDidCompleteNotification, userInfo: nil)
		}) 
		
		task.resume()
}
	
	
	func postStudentData(_ studentInfo: StudentInformation) {
		
		let requestURL = createURLFromParameters(nil, pathExtension: nil)
		var request = URLRequest(url: requestURL)
		
		request.httpMethod = postMethod
		
		request.addValue(parseApplicationId, forHTTPHeaderField: xParseApplicationId)
		request.addValue(parseRESTAPIKey, forHTTPHeaderField: xParseRESTAPIKey)
		request.addValue(jsonContentType, forHTTPHeaderField: xParseContentTypeKey)
		
		let jsonBodyDict = StudentInformationModel.convertStudentInfoToParseDict(student: studentInfo, includeMetaFields: false)
		
		let jsonWritingOptions = JSONSerialization.WritingOptions()
		
		guard let jsonBody: Data = try? JSONSerialization.data(withJSONObject: jsonBodyDict, options: jsonWritingOptions) else {
			postFailureNotification(Parse.parsePostDidFailNotification, failureMessage: jsonSerializationFailureMessage)
			return
		}
		
		request.httpBody = jsonBody
		
		guard SCNetworkReachability.checkIfNetworkAvailable(requestURL) == true else {
			postFailureNotification(Parse.parsePostDidFailNotification, failureMessage: networkUnreachableMessage)
			return
		}
		
		let session = URLSession.shared
		let task = session.dataTask(with: request, completionHandler: {
			
			(data, response, error) in
			
			if let error = error {
				let errorMessage = error.localizedDescription
				let failureMessage = self.errorReceivedMessage + "\(errorMessage)"
				self.postFailureNotification(Parse.parsePostDidFailNotification, failureMessage: failureMessage)
				return
			}
			
			// ensure status code present
			guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
				
				let failureMessage = self.badStatusCodeMessage
				self.postFailureNotification(Parse.parsePostDidFailNotification, failureMessage: failureMessage)
				return
				
			}
			
			// status code = 201 means successfully updated; but anything in the 200 range should indicate success
			guard statusCode >= 200 && statusCode <= 299 else {
				
				let failureMessage = "\(self.badStatusCodeMessage) (code: \(statusCode))"
				self.postFailureNotification(Parse.parsePostDidFailNotification, failureMessage: failureMessage)
				return
			}

			guard let data = data else {
				
				self.postFailureNotification(Parse.parsePostDidFailNotification, failureMessage: self.noDataReceivedMessage)
				return
			}
			
			let options = JSONSerialization.ReadingOptions()
			guard let parsedData = try? JSONSerialization.jsonObject(with: data, options: options) as? [String: AnyObject] else {
					
					self.postFailureNotification(Parse.parsePostDidFailNotification, failureMessage: self.unableToParseDataMessage)
					return
			}
			
			guard parsedData[StudentInformationModel.createdAtKey] != nil && parsedData[StudentInformationModel.objectIdKey] != nil else {
				
				self.postFailureNotification(Parse.parsePostDidFailNotification, failureMessage: self.invalidDataReceivedMessage)
				return
			}

			NotificationCenter.postNotificationOnMain(Parse.parsePostDidCompleteNotification, userInfo: nil)
		}) 
		
		task.resume()
	}
	
	
	// TODO: refactor into postStudentData method
	func replaceStudentData(_ studentInfo: StudentInformation) {
		
		let requestURL = createURLFromParameters(nil, pathExtension: studentInfo.objectId)
		var request = URLRequest(url: requestURL)
		
		request.httpMethod = putMethod
		
		request.addValue(parseApplicationId, forHTTPHeaderField: xParseApplicationId)
		request.addValue(parseRESTAPIKey, forHTTPHeaderField: xParseRESTAPIKey)
		request.addValue(jsonContentType, forHTTPHeaderField: xParseContentTypeKey)
		
		let jsonBodyDict = StudentInformationModel.convertStudentInfoToParseDict(student: studentInfo, includeMetaFields: false)
		
		let jsonWritingOptions = JSONSerialization.WritingOptions()
		
		guard let jsonBody: Data = try? JSONSerialization.data(withJSONObject: jsonBodyDict, options: jsonWritingOptions) else {
			postFailureNotification(Parse.parsePutDidFailNotification, failureMessage: jsonSerializationFailureMessage)
			return
		}

		request.httpBody = jsonBody
		
		guard SCNetworkReachability.checkIfNetworkAvailable(requestURL) == true else {
			postFailureNotification(Parse.parsePutDidFailNotification, failureMessage: networkUnreachableMessage)
			return
		}
		
		let session = URLSession.shared
		let task = session.dataTask(with: request, completionHandler: {
			
			(data, response, error) in
			
			if let error = error {
				let errorMessage = error.localizedDescription
				let failureMessage = self.errorReceivedMessage + "\(errorMessage)"
				self.postFailureNotification(Parse.parsePutDidFailNotification, failureMessage: failureMessage)
				return
			}
			
			// ensure status code present
			guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
				
				let failureMessage = self.badStatusCodeMessage
				self.postFailureNotification(Parse.parsePutDidFailNotification, failureMessage: failureMessage)
				return
				
			}
			
			// status code = 201 means successfully updated; but anything in the 200 range should indicate success
			guard statusCode >= 200 && statusCode <= 299 else {
				
				let failureMessage = "\(self.badStatusCodeMessage) (code: \(statusCode))"
				self.postFailureNotification(Parse.parsePutDidFailNotification, failureMessage: failureMessage)
				return
			}
			
			guard let data = data else {
				
				self.postFailureNotification(Parse.parsePutDidFailNotification, failureMessage: self.noDataReceivedMessage)
				return
			}
			
			let options = JSONSerialization.ReadingOptions()
			guard let parsedData = try? JSONSerialization.jsonObject(with: data, options: options) as? [String: AnyObject] else {
				
				self.postFailureNotification(Parse.parsePutDidFailNotification, failureMessage: self.unableToParseDataMessage)
				return
			}
			
			guard parsedData[StudentInformationModel.updatedAtKey] != nil else {
				
				self.postFailureNotification(Parse.parsePutDidFailNotification, failureMessage: self.invalidDataReceivedMessage)
				return
			}
			
			NotificationCenter.postNotificationOnMain(Parse.parsePostDidCompleteNotification, userInfo: nil)
		}) 
		
		task.resume()
	}

	
	// MARK: - Notification Handling
	
	/**
	
	Post notification containing a failure message.
	
	- parameter failureMessage: Failure information to be provided to observers.
	
	*/
	fileprivate func postFailureNotification(_ notificationName: String, failureMessage: String) {
		
		let userInfo = [Parse.messageKey: failureMessage]
		
		NotificationCenter.postNotificationOnMain(notificationName, userInfo: userInfo)
	}
	
	
	//: MARK: - Private Functions
	
	func createURLFromParameters(_ parameters: [String:AnyObject]?, pathExtension: String?) -> URL {
		
		var components = URLComponents()
		components.scheme = apiScheme
		components.host = apiHost
		components.path = ("\(apiPath)/\(pathExtension ?? "")")
		
		if let parameters = parameters {
			components.queryItems = [URLQueryItem]()
		
			for (key, value) in parameters {
				let queryItem = URLQueryItem(name: key, value: "\(value)")
				components.queryItems!.append(queryItem)
			}
		}
		
		return components.url!
	}

}
