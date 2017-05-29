//
//  Path.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/26/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import MapKit
import CloudKit

class PathsType{

   // var UserId:Int;
    //  var Title:String;
  //  var Description:String;
//    var Points:Array<CLLocation>;
    public var Record:CKRecord?;
    
    init(){
    //    self.UserId = UserId;
//        self.Title = Title;
//        self.Description = Description
//        self.Points = Points;
        
    }
    
    init(record:CKRecord, database:CKDatabase){
       // UserId = Int64(record.objectForKey("UserId"));
       // record.allKeys();
   //     UserId = record["UserId"] as! Int;
//        Title = record["Title"] as! String;
//        Description = record["Description"] as! String;
//        Points = record["Points"] as! Array<CLLocation>;
        Record = record;
    }
    
     func GetUserID() -> Int?{
        return Record!["UserId"] as! Int?;
    }
    
    func GetUserName() -> String?{
        return Record!["UserName"] as! String?;
    }
    
    func GetPoints() -> Array<CLLocation>?{
        return Record!["Points"] as! Array<CLLocation>?;
    }
    
    func GetTitle() -> String?{
        return Record!["Title"] as! String?;
    }
    
    func GetDescription() -> String?{
        return Record!["Description"] as! String?;
    }
    internal func ToCrumb() -> Crumb{
        let crumb = Crumb();
        
        crumb.Description = Record?["Description"] as! String
        crumb.Path = Record?["Points"] as! Array<CLLocation>;

        crumb.Title = Record?["Title"] as! String
        crumb.RecordId = Record?["UserId"] as? CKRecordID;
        
        return crumb;
    }
    
    func SetDescription(Desc: String){
        Record?["Description"] = Desc as CKRecordValue;
    }
    
    func SetTitle(Title: String){
        Record?["Title"] = Title as CKRecordValue;
    }
    
    func SetPoints(Points: Array<CLLocation>){
        Record?["Points"] = Points as CKRecordValue;
    }
    
    func SetUserID(UserID: Int){
        Record?["UserID"] = UserID as CKRecordValue;
    }
    
    func SetUserName(UserName: String) {
        Record?["UserName"] = UserName as CKRecordValue;
    }
    
    
}
