//
//  RecordingViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 2/2/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import Foundation
import UIKit
import Photos

public class RecordingViewController : BaseRecordingController {
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var lblTime: UILabel!
    
    public var recordingAccuracy : LocationAccuracy = LocationAccuracy.walking
    
    private var timePast : TimeInterval = 0.0
    private var timer : Timer?
    private let timeFormatter : DateComponentsFormatter
    
    lazy var saveAlert : UIAlertController = {
        let alert = UIAlertController(title: "Save?", message: "Would you like to save this path or reset?", preferredStyle: UIAlertControllerStyle.alert)
        let actionSave = UIAlertAction.init(title: "Save", style: UIAlertActionStyle.default) {[unowned self] _ in self.buttonSaveClicked()}
        let actionReset = UIAlertAction.init(title: "Reset", style: UIAlertActionStyle.default) {[unowned self] _ in self.buttonResetClicked()}
        alert.addAction(actionSave)
        alert.addAction(actionReset)
        
        return alert
    }()
    
    required public init?(coder aDecoder: NSCoder) {
        timeFormatter = DateComponentsFormatter()
        timeFormatter.allowedUnits = [.hour, .minute, .second]
        timeFormatter.unitsStyle = .abbreviated
        
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        btnStop.addTarget(self, action: #selector(buttonStopClicked), for: .touchUpInside)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateView()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] (_) in
            self?.timePast += 1
            self?.updateView()
        })
        
        if !isRecording {
            startUpdating(accuracy: recordingAccuracy)
            isRecording = true
        } else{
            log.error("recording vc is already recording")
        }
        
        //        else{
        //            self?.timePast =
        //        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    
    @objc
    func buttonStopClicked() {
        stopUpdating()
        timer?.invalidate()
        log.debug("show save alert")
        self.present(saveAlert, animated: true, completion: nil)
    }
    
    private func updateView(){
        lblTime.text = timeFormatter.string(from: self.timePast)
    }
    
    func buttonSaveClicked() {
        save { [weak self] path, error in
            DispatchQueue.main.async {
                log.debug("saving path")
                if error == nil, path != nil {
                    self?.navigationController?.popToRootViewController(animated: true)
                } else {
                    log.error(error?.localizedDescription ?? "no error message")
                }
                
            }
        }
    }
    
    func buttonResetClicked() {
        //go to new path vc
        self.navigationController?.popViewController(animated: true)
    }
    
}
