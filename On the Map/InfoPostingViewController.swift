//
//  InfoPostingViewController.swift
//  On the Map
//
//  Created by leanne on 7/9/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import MapKit
import CoreLocation	// required for forward geocoding address
import SystemConfiguration	// required for SCNetworkReachability


class InfoPostingViewController: UIViewController, UITextViewDelegate {
	
	// MARK: - Constants
	
	let placeholderTextWhere = "Enter Your Location Here"
	let placeholderTextLink = "Enter a Link to Share Here"
	let newline = "\n"
	let emptyString = ""
	// NSURL will take non-URL, and SCNetworkReachability doesn't actually access URL,
	//	so using plain text to test for network availability (since we don't know the
	//	actual URL/host used by CLGeocoder)
	let fakeURLForAccessTest = "fakeURLforAccessTest"
	
	let errorReceivedMessage = "An error was received:\n"
	let missingLinkTitle = "Missing Link Information"
	let missingLinkMessage = "Please enter a link to display with your location!"
	let parsePostFailedTitle = "Post Action Failed"
	let parsePutFailedTitle = "Replace Action Failed"
	let networkUnreachableMessage = "Network connection is not available."
	let unableToGeocodeLocationTitle = "Invalid Location."
	let unableToGeocodeLocationMessage = "Unable to geocode provided location."
	let invalidLocationDataMessage = "Invalid location information."
	
	let actionTitle = "Return"
	
	// used for requests internal to this class
	let geocodingDidCompleteNotification = "geocodingDidCompleteNotification"
	let geocodingDidFailNotification = "geocodingDidFailNotification"
	
	
	// MARK: - Properties (Non-Outlets)
	
	var userModel: User!
	private var mapCoordinates: CLLocationCoordinate2D!
	private var userObjectId: String?
	
	
	// MARK: - Properties (Outlets)
	
	@IBOutlet weak var topView: UIView!
	@IBOutlet weak var topLabel: UILabel!
	@IBOutlet weak var linkTextView: UITextView!
	@IBOutlet weak var locationTextView: UITextView!
	@IBOutlet weak var bottomView: UIView!
	@IBOutlet weak var mapView: MKMapView!
	
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var findOnTheMapButton: UIButton!
	@IBOutlet weak var submitButton: UIButton!
	
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		subscribeToNotifications()
		
		// when starting, we show the topLabel, locationTextView, bottomView, and findTheMapButton
		// so, hide items that don't show when view is first loaded (topView always shows - has cancelButton!)
		linkTextView.hidden = true
		mapView.hidden = true
		submitButton.hidden = true
		
		activityIndicator.hidesWhenStopped = true
		activityIndicator.color = UIColor.blueColor()
		activityIndicator.hidden = true
		
		linkTextView.delegate = self
		locationTextView.delegate = self
    }
	
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		// check for existing student; if present, need to ask if they want to replace their current location
		userObjectId = StudentInformationModel.checkForStudentWithID(userModel.userId)
		
		if userObjectId != nil {
			
			// give student choice to replace or cancel (stay at current view)
			let alertControllerStyle = UIAlertControllerStyle.Alert
			let alertView = UIAlertController(title: "Student In List", message: "You're already in the list! What would you like to do?", preferredStyle: alertControllerStyle)
			
			let alertActionReplace = UIAlertAction(title: "Replace", style: UIAlertActionStyle.Default, handler: nil)
			alertView.addAction(alertActionReplace)

			let alertActionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
				
				(alertAction) in
				
				self.dismissViewControllerAnimated(true, completion: nil)
			}
			alertView.addAction(alertActionCancel)

			presentViewController(alertView, animated: true, completion: nil)
		}
	}
	
	
	deinit {
		
		// unsubscribe ourself from all notifications
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

	
	// MARK: - Actions
	
	@IBAction func cancelInfoPosting(sender: UIButton) {
		
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	
	@IBAction func findOnTheMap(sender: UIButton) {
		
		activityIndicator.hidden = false
		activityIndicator.startAnimating()
		
		// show/hide items for map version of view
		topLabel.hidden = true
		locationTextView.hidden = true
		bottomView.hidden = true
		findOnTheMapButton.hidden = true
		
		linkTextView.hidden = false
		mapView.hidden = false
		submitButton.hidden = false
		
		// change the cancel button's text color, so it's not invisible!
		cancelButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
		
		// retrieve and display location info
		let address = locationTextView.text
		let geocoder = CLGeocoder()

		
		let fakeURL = NSURL(string: fakeURLForAccessTest)
		guard SCNetworkReachability.checkIfNetworkAvailable(fakeURL!) == true else {
			postFailureNotification(self.geocodingDidFailNotification, failureMessage: networkUnreachableMessage)
			return
		}
		
		geocoder.geocodeAddressString(address) {

			(placemarkData, error) in
			
			guard error == nil else {
				self.postFailureNotification(self.geocodingDidFailNotification, failureMessage: self.unableToGeocodeLocationMessage)
				return
			}
			
			guard let placemarkData = placemarkData, let location = placemarkData[0].location else {
				self.postFailureNotification(self.geocodingDidFailNotification, failureMessage: self.invalidLocationDataMessage)
				return
			}
			
			self.mapCoordinates = location.coordinate
			
			NSNotificationCenter.postNotificationOnMain(self.geocodingDidCompleteNotification, userInfo: nil)
		}
	}
	
	
	@IBAction func submit(sender: UIButton) {
		
		// if text hasn't changed, notify that link needs to be added
		guard linkTextView.text != placeholderTextLink && linkTextView.text != emptyString  else {
			
			presentAlert(missingLinkTitle, message: missingLinkMessage, actionTitle: actionTitle)
			
			return
		}
		
		// submit location information to Parse
		var studentInfo = createStudent()
		
		if let replacementObjectId = userObjectId {
			studentInfo.objectId = replacementObjectId
			
			Parse().replaceStudentData(studentInfo)
		}
		else {
			Parse().postStudentData(studentInfo)
		}
	}
	
	
	// MARK: - Notification Handlers
	
	func subscribeToNotifications() {
		
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(parsePostDidComplete(_:)),
		                                                 name: Parse.parsePostDidCompleteNotification,
		                                                 object: nil)
		
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(parsePostDidFail(_:)),
		                                                 name: Parse.parsePostDidFailNotification,
		                                                 object: nil)
		
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(parsePostDidComplete(_:)),
		                                                 name: Parse.parsePutDidCompleteNotification,
		                                                 object: nil)
		
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(parsePostDidFail(_:)),
		                                                 name: Parse.parsePutDidFailNotification,
		                                                 object: nil)
		
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(geocodingDidComplete(_:)),
		                                                 name: geocodingDidCompleteNotification,
		                                                 object: nil)
		
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(geocodingDidFail(_:)),
		                                                 name: geocodingDidFailNotification,
		                                                 object: nil)
	}
	
	
	func parsePostDidComplete(notification: NSNotification) {
		
		activityIndicator.stopAnimating()
		
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	
	func parsePostDidFail(notification: NSNotification) {
		
		var failureMessage: String = ""
		if let userInfo = notification.userInfo as? [String: String] {
			failureMessage = userInfo[Parse.messageKey] ?? ""
		}
		
		presentAlert(parsePostFailedTitle, message: failureMessage, actionTitle: actionTitle) {
			
			(alertAction) in
			
			self.dismissViewControllerAnimated(true, completion: nil)
		}
	}
	
	
	func parsePutDidComplete(notification: NSNotification) {
		
		activityIndicator.stopAnimating()
		
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	
	func parsePutDidFail(notification: NSNotification) {
		
		var failureMessage: String = ""
		if let userInfo = notification.userInfo as? [String: String] {
			failureMessage = userInfo[Parse.messageKey] ?? ""
		}
		
		presentAlert(parsePostFailedTitle, message: failureMessage, actionTitle: actionTitle) {
			
			(alertAction) in
			
			self.dismissViewControllerAnimated(true, completion: nil)
		}
	}
	
	
	func geocodingDidComplete(notification: NSNotification) {
		
		activityIndicator.stopAnimating()

		// update the map with the new location information
		mapView.removeAnnotations(mapView.annotations)
		
		let span = MKCoordinateSpanMake(0.5, 0.5)
		let region = MKCoordinateRegion(center: mapCoordinates, span: span)
		
		mapView.setRegion(region, animated: true)
		
		let annotation = MKPointAnnotation()
		annotation.coordinate = mapCoordinates
		
		mapView.addAnnotation(annotation)
	}
	
	
	func geocodingDidFail(notification: NSNotification) {
		
		activityIndicator.stopAnimating()
		
		var failureMessage: String = ""
		if let userInfo = notification.userInfo as? [String: String] {
			failureMessage = userInfo[Parse.messageKey] ?? ""
		}
		
		presentAlert(unableToGeocodeLocationTitle, message: failureMessage, actionTitle: actionTitle) {
			
			(alertAction) in
			
			self.dismissViewControllerAnimated(true, completion: nil)
		}
	}
	
	
	/**
	
	Post notification containing a failure message.
	
	- parameter failureMessage: Failure information to be provided to observers.
	
	*/
	private func postFailureNotification(notificationName: String, failureMessage: String) {
		
		let userInfo = [Parse.messageKey: failureMessage]
		
		NSNotificationCenter.postNotificationOnMain(notificationName, userInfo: userInfo)
	}

	
	// MARK: - Private Functions
	
	private func createStudent() -> StudentInformation {
		
		var studentInfo = [String: AnyObject]()
		studentInfo[StudentInformationModel.uniqueKeyKey] = userModel.userId
		studentInfo[StudentInformationModel.firstNameKey] = userModel.firstName
		studentInfo[StudentInformationModel.lastNameKey] = userModel.lastName
		studentInfo[StudentInformationModel.latitudeKey] = mapCoordinates.latitude
		studentInfo[StudentInformationModel.longitudeKey] = mapCoordinates.longitude
		studentInfo[StudentInformationModel.mapStringKey] = locationTextView.text
		studentInfo[StudentInformationModel.mediaURLKey] = linkTextView.text
		
		let student = StudentInformation(studentInfo)
		
		return student
	}

	
	// MARK: - Text View Delegate Methods
	
	func textViewDidBeginEditing(textView: UITextView) {

		if textView.text == placeholderTextWhere || textView.text == placeholderTextLink {
			textView.text = emptyString
		}
	}
	
	
	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		
		if text == newline {
			textView.resignFirstResponder()
			
			return false
		}
		
		return true
	}
	
	
}
