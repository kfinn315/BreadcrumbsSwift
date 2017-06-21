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
import CoreGraphics

class NavTableViewController: UITableViewController, CloudKitDelegate {
    var userpaths = Array<PathsType>();
    var sharedpaths = Array<PathsType>();
    var showHeader = false;
    var headerText = String();
    var container : ContainerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
            try CloudKitManager.GetICloudAvailable();
        } catch{
            ShowInHeader("Unable to find cloudkit status")
        }
        
        self.container = (self.parent as! ContainerViewController);

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CloudKitManager.sharedInstance.delegate = self;
        
        userpaths = CloudKitManager.sharedInstance.userPaths;
        sharedpaths = CloudKitManager.sharedInstance.sharedPaths;
        self.tableView.reloadData();
        
        if((AppManager.sharedInstance.SelectCrumbIndex) != nil){
            let indexPath = AppManager.sharedInstance.SelectCrumbIndex!;
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
        }
        
        
    }
    private var showPublic = true;
    func togglePublic(){
        showPublic = !showPublic;
        
        tableView.reloadData();
    }
    func ShowInHeader(_ message: String){
        showHeader = true;
        headerText = message;
        tableView.sectionHeaderHeight = tableView.frame.height;
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        CloudKitManager.sharedInstance.delegate = nil;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    func getErrorCell() -> UIView{
        let view = UIView(frame: CGRect.init(x:0, y:0, width:tableView.frame.size.width, height:40))
        let label = UILabel(frame: view.frame)
        label.text = headerText;
        label.textColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
        let centerX = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let centerY = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 22)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        view.addConstraints([centerX, centerY, height])
        
        view.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        return view;
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "headercell") as! HeaderCell
        headerCell.backgroundColor = UIColor.cyan
        
        
        switch(section){
        case 0:
            headerCell.textLabel?.text = "My Paths!";
        case 1:
            headerCell.textLabel?.text = "Shared Paths";
        default:
            headerCell.textLabel?.text = "Other";
            break;
        }
        
        
        return headerCell;
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var title : String;
        switch(section){
        case 0:
            title = "My Paths!";
        case 1:
            title = "Shared Paths";
        default:
            title = "Other";
            break;
        }
        
        return title;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var path : PathsType?
        
        if(indexPath.section == 0){
            path = userpaths[indexPath.row];
        } else if(indexPath.section == 1){
            path = sharedpaths[indexPath.row];
        }
        
        container?.SetMainCrumb(path: path)
        container?.closeLeft()
        
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if(indexPath == AppManager.sharedInstance.SelectCrumbIndex)
        {
            AppManager.sharedInstance.SelectCrumbIndex = nil;
        }
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
            EVC.Crumb = self.userpaths[index.row];
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
                let remove = self.userpaths[index.row];
                do{
                    try CloudKitManager.RemovePath(recordId: (remove.Record?.recordID)!)
                } catch{
                    //do something
                }
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
        if(section == 0){
            return userpaths.count;
        }
        else if(section == 1) {
            return sharedpaths.count;
        }
        
        return 0;
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var paths : Array<PathsType>?;
        if(indexPath.section==0){
            paths = userpaths;
        } else if(indexPath.section == 1){
            paths = sharedpaths;
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "crumbcell", for: indexPath)
        
        if let pathsUnwrapped = paths {
            let path = pathsUnwrapped[indexPath.row];
            cell.textLabel?.text = path.GetTitle();
            cell.detailTextLabel?.text =  path.GetUserName();
            if(path.GetIsShared()){
                cell.backgroundColor = UIColor.yellow;
            } else{
                cell.backgroundColor = UIColor.clear;
            }
        }
        return cell
    }
    
    func errorUpdatingCrumbs(_ Error: Error) {
        
    }
    func errorSavingData(_ Error: Error) {
        
    }
    
    func CrumbsUpdated(_ Crumbs: Array<PathsType>){
        userpaths = Crumbs;
        self.tableView.reloadData();
    }
    
    func CrumbSaved(_ Id: CKRecordID) {
        
    }
    
    func CrumbsReset() {
        
    }
    
    func CrumbDeleted(_ RecordID: CKRecordID){
    }
    
}

