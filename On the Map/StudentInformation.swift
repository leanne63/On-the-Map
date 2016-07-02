//
//  Student.swift
//  On the Map
//
//  Created by leanne on 6/30/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import Foundation

/// Stores student-entered map information from Parse
struct StudentInformation {
	
	let createdAt: String
	let firstName: String
	let lastName: String
	let latitude: Float
	let longitude: Float
	let mapString: String
	let mediaURL: String
	let objectID: String
	let uniqueKey: String
	let updatedAt: String
	
	
	// MARK: - Initializer
	
	init(_ studentInfo: [String: AnyObject]) {
		
		createdAt = studentInfo[StudentInformationModel.createdAtKey] as! String
		firstName = studentInfo[StudentInformationModel.firstNameKey] as! String
		lastName  = studentInfo[StudentInformationModel.lastNameKey]  as! String
		latitude  = studentInfo[StudentInformationModel.latitudeKey]  as! Float
		longitude = studentInfo[StudentInformationModel.longitudeKey] as! Float
		mapString = studentInfo[StudentInformationModel.mapStringKey] as! String
		mediaURL  = studentInfo[StudentInformationModel.mediaURLKey]  as! String
		objectID  = studentInfo[StudentInformationModel.objectIDKey] != nil ? studentInfo[StudentInformationModel.createdAtKey] as! String : ""
		uniqueKey = studentInfo[StudentInformationModel.uniqueKeyKey] as! String
		updatedAt = studentInfo[StudentInformationModel.updatedAtKey] as! String
		
		StudentInformationModel.students.append(self)
		
	}

}
