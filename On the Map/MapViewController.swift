//
//  MapViewController.swift
//  On the Map
//
//  Created by leanne on 4/20/16.
//  Copyright © 2016 leanne63. All rights reserved.
//
//	MapViewController based on sample code provided by Udacity:
//		ViewController.swift
//		PinSample
//
//		Created by Jason on 3/23/15.
//		Copyright (c) 2015 Udacity. All rights reserved.
//

import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
	
	// MARK: - Constants
	
	let reuseIdentifier = "reusableAnnotationView"
	
	let returnActionTitle = "Return"
	let invalidLinkProvidedMessage = "Unable to open provided link!"
	let badLinkTitle = "Invalid URL"
	let parseRetrievalFailedTitle = "No Location Data"
	
	
	// MARK: - Properties (Outlets)
	
	@IBOutlet weak var mapView: MKMapView!
	
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		subscribeToNotifications()
		
		loadMapData()
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
		
		loadMapData()
	}
	
	
	fileprivate func loadMapData() {
		
		mapView.removeAnnotations(mapView.annotations)
		
		let students = StudentInformationModel.students
		
		var annotations = [MKPointAnnotation]()
		
		for student in students {
			
			// get the appropriate information
			let lat: Double = CLLocationDegrees(student.latitude)
			let long: Double = CLLocationDegrees(student.longitude)
			
			// The lat and long are used to create a CLLocationCoordinates2D instance.
			let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
			
			let first: String = student.firstName
			let last: String = student.lastName
			let mediaURL: String = student.mediaURL
			
			let annotation = MKPointAnnotation()
			annotation.coordinate = coordinate
			annotation.title = "\(first) \(last)"
			annotation.subtitle = mediaURL
			
			// add to to our array of annotations
			annotations.append(annotation)
		}
		
		// When the array is complete, we add the annotations to the map.
		self.mapView.addAnnotations(annotations)
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
	
	
	// MARK: - MKMapViewDelegate
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		
		var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKPinAnnotationView
		
		if pinView == nil {
			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
			pinView!.pinTintColor = UIColor.red
			pinView!.canShowCallout = true
			pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
		}
		else {
			pinView!.annotation = annotation
		}
		
		return pinView
	}
	
	
	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		
		if control == view.rightCalloutAccessoryView {
			
			// this object will check for applications that can open the provided URL
			let app = UIApplication.shared
			
			// make sure text is present in the cell and can be turned into a NSURL; if so, open it; else, alert and return!
			guard let providedURL = view.annotation?.subtitle , providedURL != nil,
				let url = URL(string: providedURL!) , app.openURL(url) == true else {
					
					let alertViewMessage = invalidLinkProvidedMessage
					let alertActionTitle = returnActionTitle
					
					presentAlert(badLinkTitle, message: alertViewMessage, actionTitle: alertActionTitle)
					
					return
			}
		}
	}

}

