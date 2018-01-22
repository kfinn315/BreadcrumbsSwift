//
//  NavTableViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/17/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import MapKit
import CloudKit
import CoreGraphics
import RxCocoa
import RxSwift
import RxCoreData
import RxDataSources

class NavTableViewController: UITableViewController, CloudKitDelegate {
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    var userpaths : [Path] = []
    var showHeader = false;
    var headerText = String();
    
    var isLoading = false
    
    var coreData = CoreDataManager()
    
    var managedObjectContext: NSManagedObjectContext!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = nil
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            managedObjectContext = appDelegate.managedObjectContext
        }
        
        configureTableView()
        
        //
        //        CloudKitManager.sharedInstance.delegate = self;
        //        initCD()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .always
        } else {
            // Fallback on earlier versions
        }
        
        if isLoading {
            //show loading table
        }
    }
    
    func configureTableView(){
        managedObjectContext.rx.entities(Path.self, sortDescriptors: [NSSortDescriptor(key: "startdate", ascending: false)])
            .bind(to:tableView.rx.items(cellIdentifier: "crumbcell")) { row, path, cell in
                cell.textLabel?.text = path.title
                cell.detailTextLabel?.text = path.startdate?.string ?? ""
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected.map { [unowned self] ip -> Path in return try self.tableView.rx.model(at: ip)
            }.subscribe(onNext: { [unowned self] (path) in
                do {
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "pathDetail") as? PathDetailViewController
                    {
                        vc.path = path
                        self.showDetailViewController(vc, sender: self)
                    }
                }
            }).disposed(by: disposeBag)
        
        
        self.tableView.rx.itemDeleted.map { [unowned self] ip -> Path in
            return try self.tableView.rx.model(at: ip)
            }
            .subscribe(onNext: { [unowned self] (path) in
                do {
                    try self.managedObjectContext.rx.delete(path)
                } catch {
                    print(error)
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    private func reloadData(){
        do{
            userpaths = try coreData.getPaths()
        } catch{
            
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData();
        }
    }
    
    private func initCD(){
        isLoading = true
        CloudKitManager.GetICloudAccountStatus(Callback: {(status: CKAccountStatus)->Void in
            if(status == CKAccountStatus.available){
                do{
                    try CloudKitManager.fetchPathsForUser()
                } catch {
                    //showErrorAlert(title: "CloudKit Error", message: "", Error: error)
                }
                do{
                    try CloudKitManager.fetchPublicPaths()
                } catch {
                    //showErrorAlert(title: "CloudKit Error", message: "", Error: error)
                }
                
            } else{
                //error
            }
        })
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
        reloadData()
    }
    
    func CrumbSaved(_ Id: CKRecordID) {
        
    }
    
    func CrumbsReset() {
        
    }
    
    func CrumbDeleted(_ RecordID: CKRecordID){
    }
    
}


