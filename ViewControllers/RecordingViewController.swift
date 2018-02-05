//
//  RecordingViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 2/2/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import Foundation
import UIKit

public class RecordingViewController : RecordViewController {
    var SaveAlert : UIAlertController?
    
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var lblTime: UILabel!
    
    private var timePast = 0
    private var timer : Timer?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.SaveAlert = UIAlertController(title: "Save?", message: "Would you like to save this path or reset?", preferredStyle: UIAlertControllerStyle.alert)
        let actionSave = UIAlertAction.init(title: "Save", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in self.buttonSaveClicked()})
        let actionReset = UIAlertAction.init(title: "Reset", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in self.buttonResetClicked()})
        self.SaveAlert?.addAction(actionSave)
        self.SaveAlert?.addAction(actionReset)
        
        btnStop.addTarget(self, action: #selector(buttonStopClicked), for: .touchUpInside)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.lblTime.text = "\(self.timePast) seconds"
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {(timer) in
            self.timePast = self.timePast + 1
            self.lblTime.text = "\(self.timePast) seconds"
        })
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    
    @objc
    func buttonStopClicked(){
        recordingMgr.stopUpdating()
        timer?.invalidate()
        
        if let vc = SaveAlert {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func buttonSaveClicked(){
        recordingMgr.save()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func buttonResetClicked(){
        //go to new path vc
        self.navigationController?.popViewController(animated: true)
    }
    
}
