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
        CloudKitManager.fetchAllPaths()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
       

    }
    
    //CloudKitDelegate
    func errorUpdatingCrumbs(_ Error: Error) {
        self.present(UIAlertController(title: "Error Updating", message: "Failed to Update: "+Error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert), animated: true)
    }
    func errorSavingData(_ Error: Error) {
        
    }
    
    func CrumbsUpdated(_ Crumbs: Array<PathsType>){
        CloudKitManager.sharedInstance.delegate = nil
        let container = self.storyboard?.instantiateViewController(withIdentifier: "Container")
        self.modalPresentationStyle = UIModalPresentationStyle.fullScreen;
        self.present(container!, animated: true, completion: {()->Void in
            print("Presented container vc")
        })
    }
    
    func CrumbSaved(_ Id: CKRecordID) {
        
    }
    
    func CrumbsReset() {
        
    }
    
    func CrumbDeleted(_ RecordID: CKRecordID){
    }
}
