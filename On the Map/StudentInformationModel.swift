//
//  StudentInformationModel.swift
//  On the Map
//
//  Created by leanne on 7/1/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import Foundation

struct StudentInformationModel {
	
	// MARK: - Constants
	
	static let createdAtKey = "createdAt"
	static let firstNameKey = "firstName"
	static let lastNameKey = "lastName"
	static let latitudeKey = "latitude"
	static let longitudeKey = "longitude"
	static let mapStringKey = "mapString"
	static let mediaURLKey = "mediaURL"
	static let objectIDKey = "objectID"
	static let uniqueKeyKey = "uniqueKey"
	static let updatedAtKey = "updatedAt"
	
	
	// MARK: - Properties
	
	/// Shared property to hold all student instances
	static var students = [StudentInformation]()
}