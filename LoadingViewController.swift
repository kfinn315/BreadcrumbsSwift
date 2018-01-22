//
//  LoadingViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 5/28/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class LoadingViewController : UIViewController, CloudKitDelegate{
    
    
    override func viewWillAppear(_ animated: Bool) {

        CloudKitManager.sharedInstance.delegate = self
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
     
      
    }
    
    //CloudKitDelegate
    func errorUpdatingCrumbs(_ Error: Error) {
        self.present(UIAlertController(title: "Error Updating", message: "Failed to Update: "+Error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert), animated: true)
    }
    func errorSavingData(_ Error: Error) {
        self.present(UIAlertController(title: "Error Updating", message: "Failed to Update: "+Error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert), animated: true)
    }
    
    func showErrorAlert(title: String, message: String, Error: Error) {
        self.present(UIAlertController(title: title, message: message+": "+Error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert), animated: true)
    }
    

    func CrumbsUpdated(_ Crumbs: Array<PathsType>){
        ShowNextVC();
    }
    
    func ShowNextVC(){
        CloudKitManager.sharedInstance.delegate = nil
        let container = self.storyboard?.instantiateViewController(withIdentifier: "SplitVC")
//        self.modalPresentationStyle = UIModalPresentationStyle.fullScreen;
        
        if container != nil {
            self.navigationController?.pushViewController(container!, animated: true)
//        self.present(container!, animated: true)
        }
    }
    
    func CrumbSaved(_ Id: CKRecordID) {
        
    }
    
    func CrumbsReset() {
        
    }
    
    func CrumbDeleted(_ RecordID: CKRecordID){
    }
}
