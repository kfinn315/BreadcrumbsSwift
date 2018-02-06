//
//  SettingsController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 5/7/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class SettingsViewController : UIViewController {
   // @IBOutlet weak var btnDone: UIBarButtonItem!
    @IBOutlet weak var segmentAccuracy: UISegmentedControl!    
    @IBOutlet weak var switchBGUpdates: UISwitch!
    @IBOutlet weak var sliderDist: UISlider!
    @IBOutlet weak var switchSigUpdates: UISwitch!
    @IBOutlet weak var lblDistance: UILabel!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
       // btnDone.action=#selector(btnDoneClicked)
        
        sliderDist.minimumValue = 0;
        sliderDist.maximumValue = 100;
        sliderDist.addTarget(self, action: #selector(updateDistLabel), for: .valueChanged )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        segmentAccuracy.selectedSegmentIndex = getAccuracySegment(accuracy: LocationSettings.locationAccuracy);
        sliderDist.value = getSliderVal(distance: LocationSettings.minimumDistance);
        switchBGUpdates.isOn = LocationSettings.backgroundLocationUpdatesOn;
        switchSigUpdates.isOn = LocationSettings.significantUpdatesOn;
        
        updateDistLabel()
    }
    
    @objc func updateDistLabel(){
        lblDistance.text = String(sliderDist.value)+" meters"
    }
    
    func getSliderVal(distance: Double) -> Float{
        return Float(distance);
    }
    
    func getDistanceVal(sliderval: Float) -> CLLocationDistance{
        return CLLocationDistance(Double(sliderval));
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        LocationSettings.locationAccuracy = getSegmentAccuracy();
        LocationSettings.minimumDistance = getDistanceVal(sliderval: sliderDist.value);
        LocationSettings.backgroundLocationUpdatesOn = switchBGUpdates.isOn;
        LocationSettings.significantUpdatesOn = switchSigUpdates.isOn;
       // CoreLocationManager.updateSettings();
    }
    
    func getAccuracySegment(accuracy: CLLocationAccuracy)->Int{
        var segment = 0;
        switch(accuracy){
        case kCLLocationAccuracyNearestTenMeters:
            segment = 2
            break;
        case kCLLocationAccuracyBest:
            segment = 1
            break;
        case kCLLocationAccuracyKilometer:
            segment = 4
            break;
        case kCLLocationAccuracyHundredMeters:
            segment = 3
            break;
        case kCLLocationAccuracyThreeKilometers:
            segment = 5
            break;
        case kCLLocationAccuracyBestForNavigation:
            segment = 0
            break;
        default:
            break;
        }
        
        return segment;
    }
    
    func getSegmentAccuracy()->CLLocationAccuracy{
        var accuracy : CLLocationAccuracy;
        switch(segmentAccuracy.selectedSegmentIndex){
        case 0: accuracy = kCLLocationAccuracyBestForNavigation;
        break;
        case 1: accuracy = kCLLocationAccuracyBest;
        break;
        case 2: accuracy = kCLLocationAccuracyNearestTenMeters; break
        case 3:
            accuracy = kCLLocationAccuracyHundredMeters;
            break;
        case 4:
            accuracy = kCLLocationAccuracyKilometer;
            break;
        case 5:
            accuracy = kCLLocationAccuracyThreeKilometers;
            break;
        default:
            accuracy = kCLLocationAccuracyBestForNavigation;
            break;
            
        }
        
        return accuracy;
    }
    
    func setLocationAccuracy(accuracy:CLLocationAccuracy){
        LocationSettings.locationAccuracy = accuracy;
    }
    
    func btnDoneClicked(){
        //save
        
       // LocationSettings.locationAccuracy = getSegmentAccuracy();
        
        self.dismiss(animated: true, completion: nil)
    }
}
