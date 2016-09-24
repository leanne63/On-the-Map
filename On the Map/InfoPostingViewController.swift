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
	fileprivate var mapCoordinates: CLLocationCoordinate2D!
	fileprivate var userObjectId: String?
	
	
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
		linkTextView.isHidden = true
		mapView.isHidden = true
		submitButton.isHidden = true
		
		activityIndicator.hidesWhenStopped = true
		activityIndicator.color = UIColor.blue
		activityIndicator.isHidden = true
		
		linkTextView.delegate = self
		locationTextView.delegate = self
    }
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// check for existing student; if present, need to ask if they want to replace their current location
		userObjectId = StudentInformationModel.checkForStudentWithID(uniqueKey: userModel.userId)
		
		if userObjectId != nil {
			
			// give student choice to replace or cancel (stay at current view)
			let alertControllerStyle = UIAlertControllerStyle.alert
			let alertView = UIAlertController(title: "Student In List", message: "You're already in the list! What would you like to do?", preferredStyle: alertControllerStyle)
			
			let alertActionReplace = UIAlertAction(title: "Replace", style: UIAlertActionStyle.default, handler: nil)
			alertView.addAction(alertActionReplace)

			let alertActionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
				
				(alertAction) in
				
				self.dismiss(animated: true, completion: nil)
			}
			alertView.addAction(alertActionCancel)

			present(alertView, animated: true, completion: nil)
		}
	}
	
	
	deinit {
		
		// unsubscribe ourself from all notifications
		NotificationCenter.default.removeObserver(self)
	}

	
	// MARK: - Actions
	
	@IBAction func cancelInfoPosting(_ sender: UIButton) {
		
		dismiss(animated: true, completion: nil)
	}
	
	
	@IBAction func findOnTheMap(_ sender: UIButton) {
		
		activityIndicator.isHidden = false
		activityIndicator.startAnimating()
		
		// show/hide items for map version of view
		topLabel.isHidden = true
		locationTextView.isHidden = true
		bottomView.isHidden = true
		findOnTheMapButton.isHidden = true
		
		linkTextView.isHidden = false
		mapView.isHidden = false
		submitButton.isHidden = false
		
		// change the cancel button's text color, so it's not invisible!
		cancelButton.setTitleColor(UIColor.white, for: UIControlState())
		
		// retrieve and display location info
		let address = locationTextView.text
		let geocoder = CLGeocoder()

		
		let fakeURL = URL(string: fakeURLForAccessTest)
		guard SCNetworkReachability.checkIfNetworkAvailable(fakeURL!) == true else {
			postFailureNotification(self.geocodingDidFailNotification, failureMessage: networkUnreachableMessage)
			return
		}
		
		geocoder.geocodeAddressString(address!) {

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
			
			NotificationCenter.postNotificationOnMain(self.geocodingDidCompleteNotification, userInfo: nil)
		}
	}
	
	
	@IBAction func submit(_ sender: UIButton) {
		
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
		
		NotificationCenter.default.addObserver(self,
		                                                 selector: #selector(parsePostDidComplete(_:)),
		                                                 name: NSNotification.Name(rawValue: Parse.parsePostDidCompleteNotification),
		                                                 object: nil)
		
		NotificationCenter.default.addObserver(self,
		                                                 selector: #selector(parsePostDidFail(_:)),
		                                                 name: NSNotification.Name(rawValue: Parse.parsePostDidFailNotification),
		                                                 object: nil)
		
		NotificationCenter.default.addObserver(self,
		                                                 selector: #selector(parsePostDidComplete(_:)),
		                                                 name: NSNotification.Name(rawValue: Parse.parsePutDidCompleteNotification),
		                                                 object: nil)
		
		NotificationCenter.default.addObserver(self,
		                                                 selector: #selector(parsePostDidFail(_:)),
		                                                 name: NSNotification.Name(rawValue: Parse.parsePutDidFailNotification),
		                                                 object: nil)
		
		NotificationCenter.default.addObserver(self,
		                                                 selector: #selector(geocodingDidComplete(_:)),
		                                                 name: NSNotification.Name(rawValue: geocodingDidCompleteNotification),
		                                                 object: nil)
		
		NotificationCenter.default.addObserver(self,
		                                                 selector: #selector(geocodingDidFail(_:)),
		                                                 name: NSNotification.Name(rawValue: geocodingDidFailNotification),
		                                                 object: nil)
	}
	
	
	func parsePostDidComplete(_ notification: Notification) {
		
		activityIndicator.stopAnimating()
		
		dismiss(animated: true, completion: nil)
	}
	
	
	func parsePostDidFail(_ notification: Notification) {
		
		var failureMessage: String = ""
		if let userInfo = (notification as NSNotification).userInfo as? [String: String] {
			failureMessage = userInfo[Parse.messageKey] ?? ""
		}
		
		presentAlert(parsePostFailedTitle, message: failureMessage, actionTitle: actionTitle) {
			
			(alertAction) in
			
			self.dismiss(animated: true, completion: nil)
		}
	}
	
	
	func parsePutDidComplete(_ notification: Notification) {
		
		activityIndicator.stopAnimating()
		
		dismiss(animated: true, completion: nil)
	}
	
	
	func parsePutDidFail(_ notification: Notification) {
		
		var failureMessage: String = ""
		if let userInfo = (notification as NSNotification).userInfo as? [String: String] {
			failureMessage = userInfo[Parse.messageKey] ?? ""
		}
		
		presentAlert(parsePostFailedTitle, message: failureMessage, actionTitle: actionTitle) {
			
			(alertAction) in
			
			self.dismiss(animated: true, completion: nil)
		}
	}
	
	
	func geocodingDidComplete(_ notification: Notification) {
		
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
	
	
	func geocodingDidFail(_ notification: Notification) {
		
		activityIndicator.stopAnimating()
		
		var failureMessage: String = ""
		if let userInfo = (notification as NSNotification).userInfo as? [String: String] {
			failureMessage = userInfo[Parse.messageKey] ?? ""
		}
		
		presentAlert(unableToGeocodeLocationTitle, message: failureMessage, actionTitle: actionTitle) {
			
			(alertAction) in
			
			self.dismiss(animated: true, completion: nil)
		}
	}
	
	
	/**
	
	Post notification containing a failure message.
	
	- parameter failureMessage: Failure information to be provided to observers.
	
	*/
	fileprivate func postFailureNotification(_ notificationName: String, failureMessage: String) {
		
		let userInfo = [Parse.messageKey: failureMessage]
		
		NotificationCenter.postNotificationOnMain(notificationName, userInfo: userInfo)
	}

	
	// MARK: - Private Functions
	
	fileprivate func createStudent() -> StudentInformation {
		
		var studentInfo = [String: AnyObject]()
		studentInfo[StudentInformationModel.uniqueKeyKey] = userModel.userId as AnyObject?
		studentInfo[StudentInformationModel.firstNameKey] = userModel.firstName as AnyObject?
		studentInfo[StudentInformationModel.lastNameKey] = userModel.lastName as AnyObject?
		studentInfo[StudentInformationModel.latitudeKey] = mapCoordinates.latitude as AnyObject?
		studentInfo[StudentInformationModel.longitudeKey] = mapCoordinates.longitude as AnyObject?
		studentInfo[StudentInformationModel.mapStringKey] = locationTextView.text as AnyObject?
		studentInfo[StudentInformationModel.mediaURLKey] = linkTextView.text as AnyObject?
		
		let student = StudentInformation(studentInfo)
		
		return student
	}

	
	// MARK: - Text View Delegate Methods
	
	func textViewDidBeginEditing(_ textView: UITextView) {

		if textView.text == placeholderTextWhere || textView.text == placeholderTextLink {
			textView.text = emptyString
		}
	}
	
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		
		if text == newline {
			textView.resignFirstResponder()
			
			return false
		}
		
		return true
	}
	
	
}
