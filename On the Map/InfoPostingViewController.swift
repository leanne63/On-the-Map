//
//  InfoPostingViewController.swift
//  On the Map
//
//  Created by leanne on 7/9/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import MapKit

class InfoPostingViewController: UIViewController {

	// MARK: - Outlets
	
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

        // Do any additional setup after loading the view.
    }

	
	// MARK: - Actions
	
	@IBAction func cancelInfoPosting(sender: UIButton) {
		
		// TODO: need to submit info to Parse!
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	
	@IBAction func findOnTheMap(sender: UIButton) {
		
		// TODO: geolocate location on our map view
	}
	
	
	@IBAction func submit(sender: UIButton) {
		
		// TODO: submit location information to Parse
	}
	/*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
