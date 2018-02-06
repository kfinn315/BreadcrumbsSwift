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

public class RecordViewController : UIViewController,CLLocationManagerDelegate, CrumbsDelegate {
    var recordingMgr = RecordingManager.shared
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //delegate callbacks
    func errorUpdatingLocations(_ Error: Error) {
        print("Could not update locations. \(Error), \(Error.localizedDescription)")
        
        let alert = UIAlertController(title: "Error", message: Error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func errorSavingData(_ Error: Error) {
        print("Could not save data. \(Error), \(Error.localizedDescription)")
        let alert = UIAlertController(title: "Error", message: Error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func CrumbSaved(error: Error?) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

public class NewPathViewController : RecordViewController {
    
    @IBOutlet weak var btnStart: UIButton!
    
    @IBOutlet weak var segAction: UISegmentedControl!

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if recordingMgr.isRecording {
            //show recording vc
            if let vc = storyboard?.instantiateViewController(withIdentifier: "recording") {
                self.navigationController?.pushViewController(vc, animated: false)
            }
        } else{
            btnStart.addTarget(self, action: #selector(startUpdating), for: .touchUpInside )         
        }
    }
    
    @objc
    func startUpdating(){
        recordingMgr.startUpdating(with: LocationAccuracy(rawValue: segAction.selectedSegmentIndex) ?? LocationAccuracy.walking)
    }
}
