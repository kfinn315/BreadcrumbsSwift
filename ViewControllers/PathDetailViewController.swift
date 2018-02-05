//
//  PathDetail2VC.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 1/30/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import MapKit
import UIKit
import RxSwift
import RxCocoa

public class PathDetailViewController : UIViewController {
    private weak var crumbsManager = CrumbsManager.shared
    //private var mapManager : MapViewManager?
    var disposeBag = DisposeBag()
    weak var btnEditTop: UIBarButtonItem!
    
    @IBOutlet weak var ivTop: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var tvNotes: UITextView!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblSteps: UILabel!
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        ivTop.setRounded()
                
        crumbsManager?.currentPath.asObservable().subscribe(onNext: {[weak self] path in
            self?.title = path?.title
            
            guard path != nil else{
                print("error: currentPath is nil")
                return
            }
            
            DispatchQueue.main.async {
                self?.lblDate.text = "\(path?.startdate?.string ?? "") - \(path?.enddate?.string ?? "")"
                self?.lblTitle.text = path?.title
                self?.tvNotes.text = "\(path?.notes ?? "")"
                self?.lblSteps.text = path?.stepcount.formatted
                self?.lblDistance.text = path?.distance.formatted
                self?.lblDuration.text = path?.duration.formatted
            }
        }).disposed(by: disposeBag)
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
    }
}

