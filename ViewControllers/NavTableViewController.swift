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

class NavTableViewController: UITableViewController {
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    var pathsManager = PathsManager()
    
    static var managedObjectContext: NSManagedObjectContext!
    var persistentContainer: NSPersistentContainer!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = nil
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            NavTableViewController.managedObjectContext = appDelegate.managedObjectContext
            persistentContainer = appDelegate.persistentContainer
        }
        
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .always
        } else {
            // Fallback on earlier versions
        }
//
//        do{
//            try persistentContainer.viewContext.rx.update(Path())
//        } catch{
//
//        }
        
        //try{persistentContainer.ba}
        tableView.reloadData()
    }
    
    func configureTableView(){
        //tableView.isEditing = true
        NavTableViewController.managedObjectContext!.rx.entities(Path.self, sortDescriptors: [NSSortDescriptor(key: "startdate", ascending: false)])
            .bind(to:tableView.rx.items(cellIdentifier: "crumbcell")) { row, path, cell in
                cell.textLabel?.text = path.title
                cell.detailTextLabel?.text = path.startdate?.string ?? ""
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected.map { [unowned self] ip -> Path in return try self.tableView.rx.model(at: ip)
            }.subscribe(onNext: { [unowned self] (path) in
                do {
                    CrumbsManager.shared.currentPath = path
                    
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Pager")
                    {
                       // vc.path = path
                        self.showDetailViewController(vc, sender: self)
                    }
                }
            }).disposed(by: disposeBag)
        
        
        self.tableView.rx.itemDeleted.map { [unowned self] ip -> Path in
            return try self.tableView.rx.model(at: ip)
            }
            .subscribe(onNext: { (path) in
                do {
                    try NavTableViewController.managedObjectContext.rx.delete(path)
                } catch {
                    print(error)
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}


