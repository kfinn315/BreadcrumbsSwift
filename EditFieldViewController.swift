//
//  EditFieldViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 1/23/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import UIKit
import Eureka

class EditPathViewController : FormViewController {
    var crumbsManager : CrumbsManager?
    
    var dateformatter : DateFormatter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateformatter = DateFormatter()
        dateformatter?.dateStyle = .short
        dateformatter?.timeStyle = .short
        
        crumbsManager = CrumbsManager.shared
        let path = crumbsManager?.currentPath
        
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
    @objc func save(){
        let path = crumbsManager?.currentPath
        
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
        crumbsManager?.currentPath = path
        let updatedCount = CrumbsManager.shared.UpdateCurrentPath()
        print("updated \(updatedCount) rows")
        self.navigationController?.popViewController(animated: true)
    }
}
