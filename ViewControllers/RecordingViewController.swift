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
    lazy var SaveAlert : UIAlertController = {
        let alert = UIAlertController(title: "Save?", message: "Would you like to save this path or reset?", preferredStyle: UIAlertControllerStyle.alert)
        let actionSave = UIAlertAction.init(title: "Save", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in self.buttonSaveClicked()})
        let actionReset = UIAlertAction.init(title: "Reset", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in self.buttonResetClicked()})
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
        self.present(SaveAlert, animated: true, completion: nil)
    }
    
    func buttonSaveClicked(){
        recordingMgr.save() { [weak self] path, error in
            if error == nil, path != nil {
                CrumbsManager.shared.currentPath.value = path

                //get map snapshot
                MapViewController().getSnapshot() { snapshot, error in
                    if error == nil, snapshot != nil {
                        CrumbsManager.shared.setCoverImg(snapshot!.image)
                    }
                    var firstVC = self?.navigationController?.viewControllers.first
                    if firstVC == nil {
                        firstVC = self?.storyboard?.instantiateViewController(withIdentifier: "nav")
                    }
                    
                    let newVC_list : [UIViewController] = [firstVC!, EditPathViewController()]
                    
                    DispatchQueue.main.async{
                        self?.navigationController?.setViewControllers(newVC_list, animated: true)
                    }
                }
            }
            else {
                print("error \(error)")
            }
        }
    }
    
//    - (void)image:(UIImage *)image
//    didFinishSavingWithError:(NSError *)error
//    contextInfo:(void *)contextInfo;
//
//    @objc func onSnapshotSaved(image: UIImage, error: Error?, contextInfo: UnsafeMutableRawPointer?){
//        image.imageAsset
//    }
    func buttonResetClicked(){
        //go to new path vc
        self.navigationController?.popViewController(animated: true)
    }
    
}
