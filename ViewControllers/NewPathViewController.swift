//
//  NewPathViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 1/11/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import CoreData
import CloudKit
import RxCocoa
import RxSwift

public class NewPathViewController : UIViewController {
    @IBOutlet weak var lblInstructions: UILabel!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var segAction: UISegmentedControl!
    
    var disposeBag = DisposeBag()
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        onAuthStatusChanged(CLLocationManager.authorizationStatus())

        CLLocationManager().rx.didChangeAuthorizationStatus.subscribe(onNext: { authstatus in self.onAuthStatusChanged(authstatus)
        }).disposed(by: disposeBag)
        
//        if isRecording {
//            //show recording vc
//            if let vc = storyboard?.instantiateViewController(withIdentifier: "recording") {
//                self.navigationController?.pushViewController(vc, animated: false)
//            }
//        } else {
            btnStart.addTarget(self, action: #selector(startUpdating), for: .touchUpInside )
//        }
    }
    func onAuthStatusChanged(_ authstatus: CLAuthorizationStatus) {
        if authstatus != CLAuthorizationStatus.authorizedAlways, authstatus != CLAuthorizationStatus.authorizedWhenInUse {
            //not authorized, show message. prevent recording
            self.lblInstructions.text = "Please enable location in settings"
            self.btnStart.isEnabled = false
        } else {
            self.lblInstructions.text = "Your path accuracy will be set based on the activity type you select."
            self.btnStart.isEnabled = true
        }
    }
    @objc func startUpdating(){
        if let vc = storyboard?.instantiateViewController(withIdentifier: "recording") as? RecordingViewController {
            let accuracy = LocationAccuracy(rawValue: segAction.selectedSegmentIndex) ?? LocationAccuracy.walking
            vc.recordingAccuracy = accuracy
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
