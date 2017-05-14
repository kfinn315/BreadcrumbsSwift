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
    var paths = Array<Crumb>();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CloudKitManager.GetCrumbPaths();
        
        CloudKitManager.sharedInstance.delegate = self;
        
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        
        let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController;

//        if(paths.count > row) {
        let c = paths[row];        
            secondViewController.crumb = c;
  //      }
        self.navigationController!.pushViewController(secondViewController, animated: true)
            
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paths.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customcell", for: indexPath)
        cell.textLabel?.text = String(paths[indexPath.row].Title);
        return cell
    }
    
    func CrumbsLoaded(_ Crumbs: Array<Crumb>) {
        paths = Crumbs;
        self.tableView.reloadData();
    }
    
    func errorUpdatingCrumbs(_ Error: NSError) {
        
    }
    
    func CrumbSaved(_ Id: CKRecordID) {
        
    }
    func CrumbsReset(){}
}

