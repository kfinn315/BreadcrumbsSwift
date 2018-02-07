import UIKit
import Photos
import Foundation
import RxSwift
import RxCocoa

class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate
{
    @IBOutlet weak var collectionView: UICollectionView!
    var disposeBag = DisposeBag()
    
    private var assetThumbnailSize: CGSize?
    var AlbumAlert : UIAlertController?
    var crumbsManager = CrumbsManager.shared
    private var assets : [PHAsset]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        
        self.AlbumAlert = UIAlertController(title: "Import Photo Album", message: "", preferredStyle: UIAlertControllerStyle.alert)
        let actionExisting = UIAlertAction.init(title: "Choose an Existing Album", style: UIAlertActionStyle.default, handler: {[weak self] alert in self?.showPhotoLibrary()})
        self.AlbumAlert?.addAction(actionExisting)
        self.AlbumAlert?.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        crumbsManager.currentPathAlbum.asObservable().subscribe(onNext: { [weak self] assetcollection in
            self?.title = self?.crumbsManager.currentAlbumTitle
            self?.assets = assetcollection
            self?.refreshData()
        }).disposed(by: disposeBag)
        
        //self.collectionView?.contentInset = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 75.0, right: 5.0)
        
//        let flowLayout = UICollectionViewFlowLayout()
//        flowLayout.sectionInset = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)
//        self.collectionView?.collectionViewLayout = flowLayout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Get size of the collectionView cell for thumbnail image
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout{
            let cellSize = layout.itemSize
            self.assetThumbnailSize = CGSize(width: cellSize.width, height: cellSize.height)
        }
        
    }
    
    func refreshData(){
        self.collectionView?.reloadData()
    }
    
    //    func removeAlbum(){
    //        if var vcs = self.navigationController?.viewControllers {
    //            _ = vcs.popLast()
    //            if vcs.last as? PathDetailViewController != nil {
    //                CrumbsManager.shared.currentPath?.albumData = nil
    //            }
    //
    //            self.navigationController?.setViewControllers(vcs, animated: true)
    //        }
    //    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UICollectionViewDataSource
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        var count: Int = 1
        
        if(self.assets != nil){
            count = self.assets!.count + 1
        }
        
        return count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if self.assets == nil || indexPath.row == self.assets?.count { //last cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addPhoto", for: indexPath as IndexPath) as! AddPhotoCell
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cameraCell", for: indexPath as IndexPath) as! ImageCollectionViewCell
        
        //Modify the cell
        if assets?.count ?? 0 > indexPath.item, let asset = self.assets?[indexPath.item], let assetsize = assetThumbnailSize
        {
            PHImageManager.default().requestImage(for: asset, targetSize: assetsize, contentMode: .aspectFill, options: nil, resultHandler: {(result, info)in
                if result != nil {
                    cell.imageView.image = result
                }
            })
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout methods
    func collectionView(collectinView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    // UIImagePickerControllerDelegate Methods
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        if self.assets == nil || indexPath.row == self.assets?.count { //last cell
            present(AlbumAlert!, animated: true, completion: nil)
        } else{
            showFull(assets?[indexPath.row])
        }
    }    
    func showFull(_ asset: PHAsset?){
        guard asset != nil else{ return }
        
        let imageview = storyboard?.instantiateViewController(withIdentifier: "ImageView") as! ImageViewController
        imageview.asset = asset
        //photovc.assetCollection = assetCollection        
        self.parent?.navigationController?.pushViewController(imageview, animated: true)
    }
    public func createAnAlbum(){
        let crumbsManager = CrumbsManager.shared
        let path = crumbsManager.currentPath
        if let start = path.value?.startdate, let end = path.value?.enddate {
            PhotoManager.createTimespanAlbum(name: "\(path.value?.title ?? "breadcrumb") - \((start as Date).string)", start: start as Date, end: end as Date, completionHandler: {
                (collection, error) in
                if collection != nil {
                    _ = crumbsManager.UpdateCurrentAlbum(collection: collection!)
                    
                    DispatchQueue.main.async {
                        //self?.updateCells()
                    }
                }
                if error != nil {
                    print("error "+error!.localizedDescription)
                }
            })
        }
    }
    
    public func showPhotoLibrary()
    {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Albums")
        {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
