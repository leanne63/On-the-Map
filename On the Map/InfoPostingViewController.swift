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
	
	
	// MARK: - Properties (Non-Outlets)
	private var mapCoordinates: CLLocationCoordinate2D!
	
	
	// MARK: - Properties (Outlets)
	
	@IBOutlet weak var topView: UIView!
	@IBOutlet weak var topLabel: UILabel!
	@IBOutlet weak var linkTextView: UITextView!
	@IBOutlet weak var locationTextView: UITextView!
	@IBOutlet weak var bottomView: UIView!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var findOnTheMapButton: UIButton!
	@IBOutlet weak var submitButton: UIButton!
	
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		// hide items that don't show when view is first loaded
		mapView.hidden = true
		submitButton.hidden = true
		
		locationTextView.delegate = self
    }

	
	// MARK: - Actions
	
	@IBAction func cancelInfoPosting(sender: UIButton) {
		
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	
	@IBAction func findOnTheMap(sender: UIButton) {
		
		// show/hide items for map version of view
		locationTextView.hidden = true
		bottomView.hidden = true
		findOnTheMapButton.hidden = true
		
		mapView.hidden = false
		submitButton.hidden = false

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
		
		// TODO: submit location information to Parse
		print("IN \(#function)")
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
