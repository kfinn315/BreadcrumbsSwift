////
////  CrumbsManager.swift
////  BreadcrumbsSwift
////
////  Created by Kevin Finn on 4/22/17.
////  Copyright © 2017 Kevin Finn. All rights reserved.
////
//
//import Foundation
//import MapKit
//import CloudKit
//
//class CloudKitManager{
//    static var AccountStatus : CKAccountStatus!;
//    static let sharedInstance = CloudKitManager();
//
//    var userPaths = Array<PathsType>()
//    var sharedPaths = Array<PathsType>()
//    var delegate: CloudKitDelegate?;
//
//    let container: CKContainer
//    let publicDB: CKDatabase
//    let privateDB: CKDatabase
//
//    internal init(){
//        print("CloudKit init")
//        container = CKContainer.default()
//        publicDB = container.publicCloudDatabase
//        privateDB = container.privateCloudDatabase
//    }
//
//    class func SavePath(_ Data: Path) throws {
//        try GetICloudAvailable();
//
//        let record = CKRecord(recordType: "Paths");
//        record["Title"] = Data.title as CKRecordValue?;
//        record["Description"] = Data.notes as CKRecordValue?;
//        record["Points"] = Data.getPoints() as CKRecordValue?;
//
//
//        sharedInstance.privateDB.save(record, completionHandler:  {(results, error) -> Void in
//
//            if(error==nil){
//                print("Saved crumb "+record.recordID.recordName);
//                sharedInstance.delegate?.CrumbSaved(results!.recordID)
//                do{
//                    try fetchPathsForUser();
//                } catch{
//
//                }
//            } else{
//                sharedInstance.delegate?.errorSavingData(error!)
//            }
//        })
//
//    }
//
//    class func RemoveAllPaths() throws{
//        try GetICloudAvailable();
//
////        var addRecords : [CKRecord]?
////        var modRecords : [CKRecord]?
//        let container: CKContainer = CKContainer.default()
//
//        var recordIDsArray: [CKRecordID] = []
//
//        for path in sharedInstance.userPaths {
//            recordIDsArray.append((path.Record?.recordID)!);
//        }
//
//        container.fetchUserRecordID { (recordID, error) -> Void in
//            recordIDsArray.append(recordID!);
//        }
//
//        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDsArray)
//        operation.modifyRecordsCompletionBlock = { addRecords, modRecords, error in print("deleted all records")}
//
//        sharedInstance.privateDB.add(operation)
//
//    }
//
//    class func RemovePath(recordId: CKRecordID) throws{
//        try GetICloudAvailable();
//
////        var addRecords : [CKRecord]?
////        var modRecords : [CKRecord]?
//        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [recordId])
//        operation.modifyRecordsCompletionBlock = {addRecords, modRecords, error in
//            if(error==nil){
//                sharedInstance.delegate?.CrumbDeleted((modRecords?[0])!);
//                do{
//                    try fetchPathsForUser()
//                } catch{
//                }
//            } else{
//                sharedInstance.delegate?.errorSavingData(error!)
//            }
//        }
//
//        sharedInstance.privateDB.add(operation)
//
//    }
//
//
//
//    class func UnsharePath(recordId: CKRecordID) throws{
//        try GetICloudAvailable();
//
////        var addRecords : [CKRecord]?
////        var modRecords : [CKRecord]?
//        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [recordId])
//        operation.modifyRecordsCompletionBlock = {addRecords, modRecords, error in
//            if(error==nil){
//                sharedInstance.delegate?.CrumbDeleted((modRecords?[0])!);
//                do{
//                    try fetchPathsForUser()
//                } catch{
//                }
//            } else{
//                sharedInstance.delegate?.errorSavingData(error!)
//            }
//        }
//
//        sharedInstance.privateDB.add(operation)
//
//    }
//
//    class func DeletePublicPath(recordName: String) throws{
//        try GetICloudAvailable();
//
//        let recordID = CKRecordID(recordName: recordName);
////        var addRecords : [CKRecord]?
////        var modRecords : [CKRecord]?
//
//        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [recordID])
//        operation.modifyRecordsCompletionBlock = {addRecords, modRecords, error in
//            if(error==nil){
//                sharedInstance.delegate?.CrumbDeleted((modRecords?[0])!);
//                do{
//                    try fetchPathsForUser()
//                } catch{
//                }
//            } else{
//                sharedInstance.delegate?.errorSavingData(error!)
//            }
//        }
//
//        sharedInstance.publicDB.add(operation)
//
//    }
//
//    class func fetchAllPaths() throws{
//        try fetchPathsForUser();
//        try fetchAllPaths();
//    }
//
//
//    class func fetchPathsForUser() throws {
//        try GetICloudAvailable();
//
//        let container: CKContainer = CKContainer.default()
//
//        container.fetchUserRecordID { (userID, error) -> Void in
//            if let userID = userID {
//                let reference = CKReference(recordID: userID, action: .none)
//                let predicate = NSPredicate(format: "creatorUserRecordID == %@", reference)
//                let query = CKQuery(recordType: "Paths", predicate: predicate)
//
//                sharedInstance.privateDB.perform(query, inZoneWith: nil, completionHandler:
//                    {(results, error) -> Void in
//                        if error != nil {
//                            sharedInstance.delegate?.errorUpdatingCrumbs(error as NSError!)
//                            print("Cloud Query Error - Fetch Establishments: \(error!.localizedDescription)")
//
//                            return
//                        }
//
//                        sharedInstance.userPaths.removeAll(keepingCapacity:true)
//
//                        print("performQuery returns "+String(describing: results?.count)+" results")
//                        results?.forEach({ (record: CKRecord) in
//                            let path = PathsType(record: record, database: sharedInstance.publicDB)
//
//                            sharedInstance.userPaths.append(path);
//                        })
//
//                        sharedInstance.delegate?.CrumbsUpdated(sharedInstance.userPaths)
//
//                        print("CrumbsManager GetCrumbPaths() returns "+String(sharedInstance.userPaths.count)+" items")
//
//                })
//            }
//
//            print("fetchPaths exit")
//        }
//    }
//
//    class func fetchOtherSharedPaths() throws{
//
//        try GetICloudAvailable();
//
//        print("fetchSharedPaths")
//        let locationPredicate = NSPredicate(value: true);
//
//        let query = CKQuery(recordType: "Paths", predicate: locationPredicate)
//        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending:true)]
//        sharedInstance.publicDB.perform(query, inZoneWith: nil, completionHandler: {(results, error) -> Void in
//            if error != nil {
//                sharedInstance.delegate?.errorUpdatingCrumbs(error!)
//                print("Cloud Query Error - Fetch Establishments: \(error!.localizedDescription)")
//
//                return
//            }
//
//            sharedInstance.sharedPaths.removeAll(keepingCapacity:true)
//
//            print("performQuery returns "+String(describing: results?.count)+"results")
//            results?.forEach({ (record: CKRecord) in
//                let path = PathsType(record: record, database: sharedInstance.publicDB)
//                sharedInstance.sharedPaths.append(path);
//            })
//
//            sharedInstance.delegate?.CrumbsUpdated(sharedInstance.sharedPaths)
//
//            print("CrumbsManager GetCrumbPaths() returns "+String(sharedInstance.sharedPaths.count)+" items")
//
//        })
//
//        print("fetchPaths exit")
//    }
//
//
//    class func fetchPublicPaths() throws {
//
//        //try fetchOtherSharedPaths();
//
//        try GetICloudAvailable();
//
//        let container: CKContainer = CKContainer.default()
//
//        container.fetchUserRecordID { (userID, error) -> Void in
//            if let userID = userID {
//                let reference = CKReference(recordID: userID, action: .none)
//                let predicate = NSPredicate(format: "creatorUserRecordID != %@", reference)
//                let query = CKQuery(recordType: "Paths", predicate: predicate)
//
//                sharedInstance.publicDB.perform(query, inZoneWith: nil, completionHandler:
//                    {(results, error) -> Void in
//                        if error != nil {
//                            sharedInstance.delegate?.errorUpdatingCrumbs(error as NSError!)
//                            print("Cloud Query Error - Fetch Establishments: \(error!.localizedDescription)")
//
//                            return
//                        }
//
//                        sharedInstance.sharedPaths.removeAll(keepingCapacity:true)
//
//                        print("performQuery returns "+String(describing: results?.count)+" results")
//                        results?.forEach({ (record: CKRecord) in
//                            let path = PathsType(record: record, database: sharedInstance.publicDB)
//
//                            sharedInstance.sharedPaths.append(path);
//                        })
//
//                        sharedInstance.delegate?.CrumbsUpdated(sharedInstance.sharedPaths)
//
//                        print("CrumbsManager GetCrumbPaths() returns "+String(sharedInstance.sharedPaths.count)+" items")
//
//                })
//            }
//
//            print("fetchPaths exit")
//
//        }
//    }
//
//    class func UpdatePath(Record: CKRecord) throws{
//        try GetICloudAvailable();
//
//        let record = Record;
//        //record["Title"] = Data.Title as CKRecordValue?;
//        ///record["Description"] = Data.Description as CKRecordValue?;
//        //record["Points"] = Data.Path as CKRecordValue?;
//        sharedInstance.privateDB.save(record, completionHandler: {(results, error) -> Void in
//            do{
//                try fetchPathsForUser()
//            } catch{
//
//            }
//        })
//    }
//
//    class func SetPublicPath(record: CKRecord, share: Bool) throws {
//        //get private record
//        //check if already shared, then
//        //if do share and not shared, copy to public db
//        //if do not share and already shared, remove from publicDb
//
//        try GetICloudAvailable();
//
//
//        if(share){
//            addPublicRecord(record);
//        } else{
//            removePublicRecord(privateRecord:record);
//        }
//    }
//
//    class func removePublicRecord(privateRecord: CKRecord) {
//
//        let recordName = privateRecord["publicRecordName"] as! String?;
//
//        if let recordNameUnwrapped = recordName{
//
//            let recordID = CKRecordID(recordName: recordNameUnwrapped)
//            sharedInstance.publicDB.delete(withRecordID: recordID, completionHandler: {(results, error) -> Void in
//                if(error==nil){
//                    print("Removed public crumb " + recordNameUnwrapped)
//
//                    sharedInstance.delegate?.CrumbDeleted(results!)
//
//                    privateRecord["publicRecordName"] = nil
//                    privateRecord["IsShared"] = 0 as CKRecordValue?
//                    do{
//                    try UpdatePath(Record: privateRecord)
//                    try fetchPathsForUser();
//                    } catch{
//
//                    }
//                } else{
//                    sharedInstance.delegate?.errorSavingData(error!)
//                }
//
//            })
//        }
//    }
//
//    class func addPublicRecord(_ record: CKRecord){
//        let newRecord = CKRecord(recordType: "Paths");
//        for key in record.allKeys(){
//            newRecord[key] = record[key];
//        }
//
//        sharedInstance.publicDB.save(newRecord, completionHandler:  {(results, error) -> Void in
//            if(error==nil){
//                print("Saved crumb "+record.recordID.recordName);
//
//                sharedInstance.delegate?.CrumbSaved(results!.recordID)
//                do{
//                    record["publicRecordName"] = results!.recordID.recordName as CKRecordValue?;
//                    record["IsShared"] = 1 as CKRecordValue?
//                    try UpdatePath(Record: record)
//                    try fetchPathsForUser();
//                } catch{
//
//                }
//            } else{
//                sharedInstance.delegate?.errorSavingData(error!)
//            }
//        })
//
//    }
//
//
//    class func GetICloudAvailable() throws{
//        if(AccountStatus != CKAccountStatus.available){
//            throw ICloudStatusError.NoAccount;
//        }
//    }
//
//    class func GetICloudAccountStatus(Callback: @escaping (CKAccountStatus) -> Void) {
//        CKContainer.default().accountStatus { (accountStatus, error) in
//            if let statuserror = error {
//                print(statuserror.localizedDescription);
//            } else{
//                AccountStatus = accountStatus;
//            }
//            Callback(accountStatus);
//        }
//    }
//
//}

