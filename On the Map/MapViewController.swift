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
		
		loadMapData()
	}
	
	
	private func loadMapData() {
		
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
	func parseRetrievalDidFail(notification: NSNotification) {
		
		// TODO: what to do if fails???
		print(Parse.parseRetrievalDidFailNotification)
	}
	
	
	// MARK: - MKMapViewDelegate
	
	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		
		var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier) as? MKPinAnnotationView
		
		if pinView == nil {
			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
			pinView!.pinTintColor = UIColor.redColor()
			pinView!.canShowCallout = true
			pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
		}
		else {
			pinView!.annotation = annotation
		}
		
		return pinView
	}
	
	
	// This delegate method is implemented to respond to taps. It opens the system browser
	// to the URL specified in the annotationViews subtitle property.
	func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		
		if control == view.rightCalloutAccessoryView {
			let app = UIApplication.sharedApplication()
			if let toOpen = view.annotation?.subtitle! {
				app.openURL(NSURL(string: toOpen)!)
			}
		}
	}

}

