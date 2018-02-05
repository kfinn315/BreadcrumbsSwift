//
//  EditFieldViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 1/23/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import UIKit
import Eureka
import RxCocoa
import RxSwift

class EditPathViewController : FormViewController, CrumbsDelegate {
   
    var crumbsManager : CrumbsManager?
    var dateformatter : DateFormatter?
    var disposeBag = DisposeBag()
    
    weak var path : Path?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateformatter = DateFormatter()
        dateformatter?.dateStyle = .short
        dateformatter?.timeStyle = .short
        
        crumbsManager = CrumbsManager.shared
        crumbsManager?.delegate = self
        crumbsManager?.currentPath.asObservable().subscribe(onNext: { [weak self] path in
            self?.path = path
            self?.updateData()
        }).disposed(by: disposeBag)
        
        form +++ Section("Main") <<< TextRow(){
            row in row.title = "Title"
            row.value = path?.title
            row.tag = "title"
            } <<< TextRow() {
                row in row.title = "Notes"
                row.value = path?.notes
                row.tag = "notes"
            } <<< TextRow() {
                row in row.title = "Locations"
                row.value = path?.locations
                row.tag = "locations"
            } <<< DateTimeRow() { row in
                row.title = "Start Date and Time"
                row.value = path?.startdate as Date!
                row.dateFormatter = dateformatter
                row.maximumDate = path?.enddate as Date!
                row.tag = "startdate"
                row.cellUpdate({ (datecell, row) in
                    if let enddate = self.form.rowBy(tag: "enddate") as? DateTimeRow {
                        enddate.minimumDate = row.value
                    }
                })
            } <<< DateTimeRow() { row in
                row.title = "End Date and Time"
                row.value = path?.enddate as Date!
                row.dateFormatter = dateformatter
                row.minimumDate = path?.startdate as Date!
                row.tag = "enddate"
                row.cellUpdate({ (datecell, row) in
                    if let startdate = self.form.rowBy(tag: "startdate") as? DateTimeRow {
                        startdate.maximumDate = row.value
                    }
                })
        }
        
        self.navigationItem.setRightBarButton(UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(save)), animated: false)
    }
    
    func updateData() {
        for row in form.allRows{
            if let tag = row.tag {
                switch tag {
                case "title":
                    (row as! TextRow).value = path?.title
                    break
                case "notes":
                    (row as! TextRow).value = path?.notes
                    break
                case "locations":
                    (row as! TextRow).value = path?.locations
                    break
                case "startdate" :
                    (row as! DateTimeRow).value = path?.startdate as Date?
                    break
                case "enddate" :
                    (row as! DateTimeRow).value = path?.enddate as Date?
                    break
                default:
                    break
                }
            }
        }
    }
    
    @objc func save(){
        weak var path = crumbsManager?.currentPath.value
        
        guard path != nil else {
            return
        }
        
        for row in form.allRows{
            if let tag = row.tag {
                switch tag {
                case "title":
                    path?.title = (row as! TextRow).value
                    break
                case "notes":
                    path?.notes = (row as! TextRow).value
                    break
                case "locations":
                    path?.locations = (row as! TextRow).value
                    break
                case "startdate" :
                    path?.startdate = (row as! DateTimeRow).value as NSDate?
                    break
                case "enddate" :
                    path?.enddate = (row as! DateTimeRow).value as NSDate?
                    break
                default:
                    break
                }
            }
        }
        CrumbsManager.shared.UpdateCurrentPath()
    }

    func CrumbsUpdated() {
            self.navigationController?.popViewController(animated: true)
    }    
}
