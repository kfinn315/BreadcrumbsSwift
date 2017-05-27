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


class EditViewController : UIViewController{
    @IBOutlet weak var buttonSave: UIBarButtonItem!
    @IBOutlet weak var buttonCancel: UIBarButtonItem!
    @IBOutlet weak var tfTitle: UITextField!
    
    var RecordId : CKRecordID?
    
    @IBOutlet weak var tfDesc: UITextField!
    override func viewDidLoad(){
        super.viewDidLoad()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        //get crumb data from recordid
        
        print("Get crumb data for recordID "+(RecordId?.recordName)!)
        
        buttonSave.action = #selector(ButtonSaveClicked)
        buttonCancel.action = #selector(ButtonCancelClicked)
    }
    
    func ButtonSaveClicked(){
        //do save
        self.dismiss(animated: true, completion: nil)
        
    }
    func ButtonCancelClicked(){
        self.dismiss(animated: true, completion: nil)
    }
}
