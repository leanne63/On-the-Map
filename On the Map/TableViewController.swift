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
	
	let returnActionTitle = "Return"
	let invalidLinkProvidedMessage = "Unable to open provided link!"
	let badLinkTitle = "Invalid URL"
	let parseRetrievalFailedTitle = "No Location Data"
	

	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		subscribeToNotifications()
	}
	
	
	deinit {
		
		// unsubscribe ourself from any notifications
		NotificationCenter.default.removeObserver(self)
	}

	
	// MARK: - Notification Handlers
	
	/// Subscribes to necessary notifications.
	fileprivate func subscribeToNotifications() {
		
		NotificationCenter.default.addObserver(self,
		                                                 selector: #selector(parseRetrievalDidComplete(_:)),
		                                                 name: NSNotification.Name(rawValue: Parse.parseRetrievalDidCompleteNotification),
		                                                 object: nil)
		
		NotificationCenter.default.addObserver(self,
		                                                 selector: #selector(parseRetrievalDidFail(_:)),
		                                                 name: NSNotification.Name(rawValue: Parse.parseRetrievalDidFailNotification),
		                                                 object: nil)
	}
	
	
	/**
	Handles actions needed when student information updates successfully.
	
	- parameter: notification object
	
	*/
	func parseRetrievalDidComplete(_ notification: Notification) {
		
		self.tableView.reloadData()
	}
	
	
	/**
	Handles actions needed when student information update is unsuccessful.
	
	- parameter: notification object
	
	*/
	func parseRetrievalDidFail(_ notification: Notification) {
		
		let alertViewMessage = (notification as NSNotification).userInfo![Parse.messageKey] as! String
		let alertActionTitle = returnActionTitle
		
		presentAlert(parseRetrievalFailedTitle, message: alertViewMessage, actionTitle: alertActionTitle)
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		
		return 1
	}
	
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		let numStudents = StudentInformationModel.students.count
		return numStudents
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
		
		let thisStudent = StudentInformationModel.students[(indexPath as NSIndexPath).item]
		
		let firstName = thisStudent.firstName
		let lastName = thisStudent.lastName
		let studentName = "\(firstName) \(lastName)"
		
		let studentURL = thisStudent.mediaURL
		
		cell.textLabel?.text = studentName
		cell.detailTextLabel?.text = studentURL
	
		return cell
	}
	
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		// this object will check for applications that can open the provided URL
		let app = UIApplication.shared
		
		// make sure text is present in the cell and can be turned into a NSURL; if so, open it; else, alert and return!
		guard let providedURL = tableView.cellForRow(at: indexPath)?.detailTextLabel?.text,
			  let url = URL(string: providedURL) , app.openURL(url) == true else {
				
			let alertViewMessage = invalidLinkProvidedMessage
			let alertActionTitle = returnActionTitle
				
			presentAlert(badLinkTitle, message: alertViewMessage, actionTitle: alertActionTitle)
				
			return
		}
	}
	
}

