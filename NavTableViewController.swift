//
//  NavTableViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/17/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import UIKit
import MapKit
import CloudKit

class NavTableViewController: UITableViewController, CloudKitDelegate {
    var paths = Array<PathsType>();
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CloudKitManager.sharedInstance.delegate = self;
        paths = CloudKitManager.sharedInstance.crumbs;
        
        self.tableView.reloadData();
        if((AppManager.sharedInstance.SelectCrumbIndex) != nil){
            let indexPath = AppManager.sharedInstance.SelectCrumbIndex!;
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        CloudKitManager.sharedInstance.delegate = nil;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        
        let c = paths[row];
        
        (self.parent as! ContainerViewController).SetMainCrumb(path: c)
        (self.parent as! ContainerViewController).closeLeft()
        
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
        
        AppManager.sharedInstance.SelectCrumbIndex = indexPath;
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if(indexPath == AppManager.sharedInstance.SelectCrumbIndex)
        {
            AppManager.sharedInstance.SelectCrumbIndex = nil;
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            print("edit button tapped")
            tableView.setEditing(false, animated: true)
            //show edit modal
            
            
            let EVC = self.storyboard?.instantiateViewController(withIdentifier: "editVC") as! EditViewController
            EVC.Crumb = self.paths[index.row];
            self.present(EVC, animated: true, completion: nil)
        }
        edit.backgroundColor = UIColor.lightGray
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            print("delete button tapped")
            tableView.setEditing(false, animated: true)
            //show delete confirm
            let alert = UIAlertController.init(title: "Delete Crumb?", message: "Are you sure you want to permanently delete this Crumb?", preferredStyle: UIAlertControllerStyle.alert);
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(UIAlertAction)-> Void in
                tableView.setEditing(false, animated: true)
                let remove = self.paths[index.row];
                CloudKitManager.RemovePath(recordId: (remove.Record?.recordID)!)
            }
            ));
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {(UIAlertAction)-> Void in                
                tableView.setEditing(false, animated: true)
            }))
            self.present(alert, animated: true, completion:  nil)
        }
        delete.backgroundColor = UIColor.orange
        
        let share = UITableViewRowAction(style: .normal, title: "Share") { action, index in
            print("share button tapped")
            tableView.setEditing(false, animated: true)
            //show share modal
        }
        share.backgroundColor = UIColor.blue
        
        return [edit, delete, share ]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paths.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "crumbcell", for: indexPath)
        cell.textLabel?.text = paths[indexPath.row].GetTitle();
        cell.detailTextLabel?.text =  paths[indexPath.row].GetUserName();
        return cell
    }
    
    func errorUpdatingCrumbs(_ Error: Error) {
        
    }
    func errorSavingData(_ Error: Error) {
        
    }
    
    func CrumbsUpdated(_ Crumbs: Array<PathsType>){
        paths = Crumbs;
        self.tableView.reloadData();
    }

    func CrumbSaved(_ Id: CKRecordID) {
        
    }
    
    func CrumbsReset() {
        
    }

    func CrumbDeleted(_ RecordID: CKRecordID){
    }

}

