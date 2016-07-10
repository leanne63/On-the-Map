//
//  InfoPostingViewController.swift
//  On the Map
//
//  Created by leanne on 7/9/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import MapKit

class InfoPostingViewController: UIViewController, UITextViewDelegate {
	
	// MARK: - Constants
	
	let placeholderText = "Enter Your Location Here"
	let whereTextLine1 = "Where are you"
	let whereTextLine2 = "studying"
	let whereTextLine3 = "today?"
	let newline = "\n"
	let emptyString = ""
	
	
	// MARK: - Properties (Private)
	private var placeholderTextPresent = true
	
	
	// MARK: - Properties (Outlets)
	
	@IBOutlet weak var topView: UIView!
	@IBOutlet weak var topLabel: UILabel!
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
		

// TODO: attributed text for label(s)
//		let topLabelTextAttributes = [
//			NSStrokeColorAttributeName : UIColor.blackColor(),
//			NSForegroundColorAttributeName : UIColor.whiteColor(),
//			NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
//			NSStrokeWidthAttributeName : -3.0,
//			
//			NSParagraphStyleAttributeName : paragraphStyleToCenterText,
//			]
//		
//		textField.defaultTextAttributes = memeTextAttributes
//		textField.adjustsFontSizeToFitWidth = true

    }

	
	// MARK: - Actions
	
	@IBAction func cancelInfoPosting(sender: UIButton) {
		
		// TODO: need to submit info to Parse!
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	
	@IBAction func findOnTheMap(sender: UIButton) {
		
		// TODO: geolocate location on our map view
		print("IN \(#function)")
	}
	
	
	@IBAction func submit(sender: UIButton) {
		
		// TODO: submit location information to Parse
		print("IN \(#function)")
	}

	
	// MARK: - Text View Delegate Methods
	
	func textViewDidBeginEditing(textView: UITextView) {

		if placeholderTextPresent {
			textView.text = emptyString
			placeholderTextPresent = false
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
