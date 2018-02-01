//
//  PathDetail2VC.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 1/30/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import MapKit
import UIKit

public class PathDetailViewController : UIViewController {
    private weak var crumbsManager : CrumbsManager?
    private weak var path : Path?
    private var mapManager : MapViewManager?
    
    @IBOutlet weak var ivTop: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    weak var btnEditTop: UIBarButtonItem!
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var tvNotes: UITextView!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblSteps: UILabel!
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        crumbsManager = CrumbsManager.shared
        //        mapManager = MapViewManager(map: mapView)
        //        mapView.isUserInteractionEnabled = true
        //
        //        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onMapViewClicked)))
        
        btnEditTop = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPath))
        self.navigationItem.setRightBarButton(btnEditTop, animated: true)
        
        ivTop.setRounded()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
        
        loadModel()
        
        if let photosVC = childViewControllers.first as? PhotosViewController, let photos = path?.albumData
        {
            photosVC.assetCollection = photos.collection
            
            let layout = photosVC.collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = CGSize.init(width: 64.0, height: photosVC.view.frame.height)
            layout.scrollDirection = .horizontal
        }
    }
    
    private func setup(){ }
    
    private func loadModel(){
        path = crumbsManager?.currentPath
        
        self.title = path?.title
        
        guard path != nil else{
            print("error: currentPath is nil")
            return
        }
        
        mapManager?.LoadCrumb(path: path!)
        
        lblDate.text = "\(path?.startdate?.string ?? "") - \(path?.enddate?.string ?? "")"
        lblTitle.text = path?.title
        tvNotes.text = "\(path?.startdate?.string ?? "") - \(path?.notes ?? "")"
        lblSteps.text = path?.stepcount.formatted
        lblDistance.text = path?.distance.formatted
        lblDuration.text = path?.duration.formatted
    }
    
    @objc func editPath(){
        self.navigationController?.pushViewController(EditPathViewController(), animated: true)
    }
    
    @objc func onMapViewClicked(){
        if path != nil, let vc = storyboard?.instantiateViewController(withIdentifier: "MapVC") as? MapViewController {
            self.navigationController?.pushViewController(vc, animated: true)
            vc.path = path
        }
    }
}

