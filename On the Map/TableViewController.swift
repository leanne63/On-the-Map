//
//  TableViewController.swift
//  On the Map
//
//  Created by leanne on 4/20/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
	
	// MARK: - Constants
	
	let reuseIdentifier = "reusableCell"
	

	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		subscribeToNotifications()
	}
	
	
	deinit {
		
		// unsubscribe ourself from any notifications
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

	
	// MARK: - Notification Handlers
	
	/// Subscribes to necessary notifications.
	private func subscribeToNotifications() {
		
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(parseRetrievalDidComplete(_:)),
		                                                 name: Parse.parseRetrievalDidCompleteNotification,
		                                                 object: nil)
		
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(parseRetrievalDidFail(_:)),
		                                                 name: Parse.parseRetrievalDidFailNotification,
		                                                 object: nil)
	}
	
	
	/**
	Handles actions needed when student information updates successfully.
	
	- parameter: notification object
	
	*/
	func parseRetrievalDidComplete(notification: NSNotification) {
		
		// TODO: share data as needed with view controllers
		print(Parse.parseRetrievalDidCompleteNotification)
		print("Student Info:\n\(StudentInformationModel.students)")
	}
	
	
	/**
	Handles actions needed when student information update is unsuccessful.
	
	- parameter: notification object
	
	*/
	func parseRetrievalDidFail(notification: NSNotification) {
		
		// TODO: what to do if fails???
		print(Parse.parseRetrievalDidFailNotification)
	}
	
	// MARK: - Table view data source
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		
		return 1
	}
	
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		let numStudents = StudentInformationModel.students.count
		return numStudents
	}
	
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
		
		let thisStudent = StudentInformationModel.students[indexPath.item]
		
		let firstName = thisStudent.firstName
		let lastName = thisStudent.lastName
		let studentName = "\(firstName) \(lastName)"
		
		let studentURL = thisStudent.mediaURL
		
		cell.textLabel?.text = studentName
		cell.detailTextLabel?.text = studentURL
	
		return cell
	}
	
}

