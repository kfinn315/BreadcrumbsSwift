//
//  EditViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 5/21/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import UIKit
import CloudKit


public class EditViewController : UIViewController, CloudKitDelegate{
    @IBOutlet weak var buttonSave: UIBarButtonItem!
    @IBOutlet weak var buttonCancel: UIBarButtonItem!
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tfDescription: UITextField!
    
    var Crumb : PathsType?
    
    override public func viewDidLoad(){
        super.viewDidLoad()
        
        buttonSave.action = #selector(ButtonSaveClicked)
        buttonCancel.action = #selector(ButtonCancelClicked)
        
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        CloudKitManager.sharedInstance.delegate = self;
        
        //get crumb data from recordid
        
        print("Edit crumb "+(Crumb?.GetTitle())!)
        
        tfTitle.text = Crumb?.GetTitle();
        tfDescription.text = Crumb?.GetDescription();
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        CloudKitManager.sharedInstance.delegate = nil;
    }
    
    func ButtonSaveClicked(){
        
        if let CrumbUnwrapped = Crumb {
            //do save
            CrumbUnwrapped.SetTitle(Title: tfTitle.text!)
            CrumbUnwrapped.SetDescription(Desc: tfDescription.text!)
            
            do{
                try CloudKitManager.UpdatePath(Record:CrumbUnwrapped.Record!);
            }catch {
                self.present(UIAlertController(title: "Error Updating", message: "Failed to Update: "+error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert), animated: true)
            }
        }
    }
    
    func ButtonCancelClicked(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //CloudKitDelegate
    func errorUpdatingCrumbs(_ Error: Error) {
        self.present(UIAlertController(title: "Error Updating", message: "Failed to Update: "+Error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert), animated: true)
    }
    func errorSavingData(_ Error: Error) {
        
    }
    
    func CrumbsUpdated(_ Crumbs: Array<PathsType>){
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func CrumbSaved(_ Id: CKRecordID) {
        
    }
    
    func CrumbsReset() {
        
    }
    
    func CrumbDeleted(_ RecordID: CKRecordID){
    }
    
}
