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
        
       // self.navigationController?.hideTransparentNavigationBar()
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
    }
    func configureTableView() {
        let datasource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String,Path>>(configureCell: { (_, _, indexPath:IndexPath, item:Path) in
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "crumbcell", for: indexPath)
            cell.textLabel?.text = item.displayTitle
            cell.detailTextLabel?.text = item.startdate?.timestring
            return cell
        })
        datasource.canEditRowAtIndexPath = {_,_ in
            true
        }
        datasource.titleForHeaderInSection = { ds, index in return ds.sectionModels[index].identity }
        NavTableViewController.managedObjectContext!.rx.entities(Path.self, sortDescriptors: [NSSortDescriptor(key: "startdate", ascending: false)]).map(mapPathsToSections).bind(to: tableView.rx.items(dataSource: datasource)).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.map { [unowned self] indexPath -> Path in
            return try self.tableView.rx.model(at: indexPath)
            }.subscribe(onNext: { [unowned self] (path) in
                do {
                    CrumbsManager.shared.setCurrentPath(path)
                    
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Pager") {
                        self.showDetailViewController(vc, sender: self)
                    }
                }
            }).disposed(by: disposeBag)
        
        self.tableView.rx.itemDeleted.map { [unowned self] indexPath -> Path in
            return try self.tableView.rx.model(at: indexPath)
            }.subscribe(onNext: { (path) in
                //add delete confirmation alert
                do {
                    try NavTableViewController.managedObjectContext.rx.delete(path)
                } catch {
                    print(error)
                }
            })
            .disposed(by: disposeBag)
    }
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//    }
    private func mapPathsToSections(_ paths: [Path]) -> [AnimatableSectionModel<String, Path>] { //group paths into sections by date and sort by date descending
        var dates : [Date : [Path]] = [:]
        for path in paths {
            if let startdate = path.startdate {
                let day = Calendar.current.startOfDay(for: startdate)
                if dates[day] == nil {
                    dates[day] = []
                }
                dates[day]?.append(path)
            }
        }
        let sorteddates = dates.sorted(by: { (date0, date1) -> Bool in
            return date0.key > date1.key
        })
        let result = sorteddates.reduce(into: [AnimatableSectionModel<String, Path>](), { (result, record) in
            result.append(AnimatableSectionModel(model: record.key.datestring, items: record.value))
        })
        
        return result
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
