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
    let crumbsManager = CrumbsManager.shared
    
    lazy var saveAlert : UIAlertController = {
        let alert = UIAlertController(title: "Save?", message: "Would you like to save this path or reset?", preferredStyle: UIAlertControllerStyle.alert)
        let actionSave = UIAlertAction.init(title: "Save", style: UIAlertActionStyle.default, handler: {(_) -> Void in self.buttonSaveClicked()})
        let actionReset = UIAlertAction.init(title: "Reset", style: UIAlertActionStyle.default, handler: {(_) -> Void in self.buttonResetClicked()})
        alert.addAction(actionSave)
        alert.addAction(actionReset)
        
        return alert
    }()
    
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var lblTime: UILabel!
    
    private var timePast = 0
    private var timer : Timer?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        btnStop.addTarget(self, action: #selector(buttonStopClicked), for: .touchUpInside)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.lblTime.text = "\(self.timePast) seconds"
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {(_) in
            self.timePast += 1
            self.lblTime.text = "\(self.timePast) seconds"
        })
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    
    @objc
    func buttonStopClicked() {
        recordingMgr.stopUpdating()
        timer?.invalidate()
        log.debug("show save alert")
        self.present(saveAlert, animated: true, completion: nil)
    }
    
    func buttonSaveClicked() {
        recordingMgr.save { [weak self] path, error in
            log.debug("saving path")
            if error == nil, path != nil {
                self?.crumbsManager.setCurrentPath(path)

                //get map snapshot
                MapViewController().getSnapshot { snapshot, error in
                    log.debug("getting map snapshot")
                    guard error == nil else {
                        log.error(error!.localizedDescription)
                        return
                    }
                    
                    if snapshot != nil {
                        self?.crumbsManager.setCoverImage(snapshot!.image)
                    }
                   
                    self?.navigateToEditView()
                }
            } else {
                log.error(error?.localizedDescription ?? "no error message")
            }
        }
    }
    
    func navigateToEditView(){
        log.debug("navigate to edit view")
        var firstVC = self.navigationController?.viewControllers.first
        if firstVC == nil {
            firstVC = self.storyboard?.instantiateViewController(withIdentifier: "table view")
        }
        let editVC = EditPathViewController()
        editVC.isNewPath = true
        
        let newVC_list : [UIViewController] = [firstVC!, editVC]
        
        DispatchQueue.main.async {
            self.navigationController?.setViewControllers(newVC_list, animated: true)
        }
    }
    
//    - (void)image:(UIImage *)image
//    didFinishSavingWithError:(NSError *)error
//    contextInfo:(void *)contextInfo;
//
//    @objc func onSnapshotSaved(image: UIImage, error: Error?, contextInfo: UnsafeMutableRawPointer?){
//        image.imageAsset
//    }
    func buttonResetClicked() {
        //go to new path vc
        self.navigationController?.popViewController(animated: true)
    }
    
}
