//
//  InfoPostingViewController.swift
//  On the Map
//
//  Created by leanne on 7/9/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import MapKit
import CoreLocation	// required for forward geocoding address

class InfoPostingViewController: UIViewController, UITextViewDelegate {
	
	// MARK: - Constants
	
	let placeholderTextWhere = "Enter Your Location Here"
	let placeholderTextLink = "Enter a Link to Share Here"
	let newline = "\n"
	let emptyString = ""
	
	let missingLinkTitle = "Missing Link Information"
	let missingLinkMessage = "Please enter a link to display with your location!"
	let parsePostFailedTitle = "Post Action Failed"
	
	let actionTitle = "Return"
	
	
	// MARK: - Properties (Non-Outlets)
	
	var userModel: User!
	private var mapCoordinates: CLLocationCoordinate2D!
	
	
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
	
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		subscribeToNotifications()
		
		// when starting, we show the topLabel, locationTextView, bottomView, and findTheMapButton
		// so, hide items that don't show when view is first loaded (topView always shows - has cancelButton!)
		linkTextView.hidden = true
		mapView.hidden = true
		submitButton.hidden = true
		
		linkTextView.delegate = self
		locationTextView.delegate = self
    }
	
	
	deinit {
		
		// unsubscribe ourself from any notifications
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

	
	// MARK: - Actions
	
	@IBAction func cancelInfoPosting(sender: UIButton) {
		
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	
	@IBAction func findOnTheMap(sender: UIButton) {
		
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
		geocoder.geocodeAddressString(address) {
			/*
				Adding capture list (unowned self) so closure won't cause strong reference cycle;
			    see weak and unowned references and "capture lists" at Automatic Reference Counting:
			    https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/AutomaticReferenceCounting.html#//apple_ref/doc/uid/TP40014097-CH20-ID48
			*/
			[unowned self]
			(placemarkData, error) in
			
			guard error == nil, let placemarkData = placemarkData, let location = placemarkData[0].location else {
				// TODO: what if no data found? alert?
				return
			}
			
			self.mapCoordinates = location.coordinate
			
			let span = MKCoordinateSpanMake(0.5, 0.5)
			let region = MKCoordinateRegion(center: self.mapCoordinates, span: span)
			
			self.mapView.setRegion(region, animated: true)
			
			let annotation = MKPointAnnotation()
			annotation.coordinate = self.mapCoordinates
			
			self.mapView.addAnnotation(annotation)
		}
	}
	
	
	@IBAction func submit(sender: UIButton) {
		
		// if text hasn't changed, notify that link needs to be added
		guard linkTextView.text != placeholderTextLink && linkTextView.text != emptyString  else {
			
			presentAlert(missingLinkTitle, message: missingLinkMessage, actionTitle: actionTitle)
			
			return
		}
		
		// submit location information to Parse
		let studentInfo = createStudent()
		let parse = Parse()
		parse.postStudentData(studentInfo)
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
	}
	
	
	func parsePostDidComplete(notification: NSNotification) {
		
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	
	func parsePostDidFail(notification: NSNotification) {
		
		var failureMessage: String = ""
		if let userInfo = notification.userInfo as? [String: String] {
			failureMessage = userInfo[Parse.messageKey] ?? ""
		}
		
		presentAlert(parsePostFailedTitle, message: failureMessage, actionTitle: actionTitle)
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
