//
//  CrumbsManager.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/22/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import MapKit
import CloudKit

class CloudKitManager{
    static let sharedInstance = CloudKitManager();
    
    var crumbs : Array<Crumb>!
    let container: CKContainer
    let publicDB: CKDatabase
    let privateDB: CKDatabase
        
    var delegate: CloudKitDelegate?;
    
    internal init(){
        crumbs = Array<Crumb>();
        
        print("CloudKit init")
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
       
    }
    
    class func GetCrumbPaths() {
        fetchAllPaths();
    }
    
    class func SaveCrumb(_ Data: Crumb){
    
        let record = CKRecord(recordType: "Paths");
        record["Title"] = Data.Title as CKRecordValue?;
        record["Description"] = Data.Description as CKRecordValue?;
        record["Points"] = Data.Path as CKRecordValue?;
        
        sharedInstance.privateDB.save(record, completionHandler:  {(results, error) -> Void in
            sharedInstance.delegate?.CrumbSaved(results!.recordID)
        })
    }
    
    class func RemoveAllCrumbs(){
        var addRecords : [CKRecord]?
        var modRecords : [CKRecord]?
        let container: CKContainer = CKContainer.default()

        var recordIDsArray: [CKRecordID] = []
        
        for crumb in sharedInstance.crumbs {
            recordIDsArray.append(crumb.RecordId!);
        }
        
        container.fetchUserRecordID { (recordID, error) -> Void in
                recordIDsArray.append(recordID!);
            
            print("fetchPaths exit")
        }
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDsArray)
        operation.modifyRecordsCompletionBlock = { addRecords, modRecords, error in print("deleted all records")}
        
        sharedInstance.privateDB.add(operation)
        
    }
    
    class func fetchPathsForUser(){
        let container: CKContainer = CKContainer.default()
        
        container.fetchUserRecordID { (userID, error) -> Void in
            if let userID = userID {
                let reference = CKReference(recordID: userID, action: .none)
                let predicate = NSPredicate(format: "creatorUserRecordID == %@", reference)
                let query = CKQuery(recordType: "Paths", predicate: predicate)
                
                sharedInstance.privateDB.perform(query, inZoneWith: nil, completionHandler:
                    {(results, error) -> Void in
                        if error != nil {
                            sharedInstance.delegate?.errorUpdatingCrumbs(error as NSError!)
                            print("Cloud Query Error - Fetch Establishments: \(error)")
                            
                            return
                        }
                        
                        sharedInstance.crumbs.removeAll(keepingCapacity:true)
                        
                        print("performQuery returns "+String(describing: results?.count)+" results")
                        results?.forEach({ (record: CKRecord) in
                            let path = PathsType(record: record, database: sharedInstance.publicDB).ToCrumb()
                            
                            sharedInstance.crumbs.append(path);
                        })
                        
                        sharedInstance.delegate!.CrumbsLoaded(sharedInstance.crumbs)
                        
                        print("CrumbsManager GetCrumbPaths() returns "+String(sharedInstance.crumbs.count)+" items")
                        
                })
            }
            
            print("fetchPaths exit")
        }
    }
    
    class func fetchAllPaths(){
        print("fetchAllPaths")
        let locationPredicate = NSPredicate(value: true);
        
        let query = CKQuery(recordType: "Paths", predicate: locationPredicate)
        
        sharedInstance.privateDB.perform(query, inZoneWith: nil, completionHandler: {(results, error) -> Void in
            if error != nil {
                sharedInstance.delegate?.errorUpdatingCrumbs(error! as NSError)
                print("Cloud Query Error - Fetch Establishments: \(error)")
                
                return
            }
            
            sharedInstance.crumbs.removeAll(keepingCapacity:true)
            
            print("performQuery returns "+String(describing: results?.count)+"results")
            results?.forEach({ (record: CKRecord) in
                let path = PathsType(record: record, database: sharedInstance.publicDB).ToCrumb()
                sharedInstance.crumbs.append(path);
            })
            
            sharedInstance.delegate!.CrumbsLoaded(sharedInstance.crumbs)
            
            print("CrumbsManager GetCrumbPaths() returns "+String(sharedInstance.crumbs.count)+" items")
            
        })
        
        print("fetchPaths exit")
    }
    }
