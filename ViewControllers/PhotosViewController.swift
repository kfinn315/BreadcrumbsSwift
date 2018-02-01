import UIKit
import Photos
import Foundation

class PhotosViewController: UICollectionViewController {
    var assetCollection: PHAssetCollection! {
        didSet{
            refreshData()
        }
    }
    var photosAsset: PHFetchResult<AnyObject>?
    var assetThumbnailSize: CGSize!
    var AlbumAlert : UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.delegate = self
        
        self.AlbumAlert = UIAlertController(title: "Photo Album", message: "Would you like to create an album or choose an existing one?", preferredStyle: UIAlertControllerStyle.alert)
        let actionAlbum = UIAlertAction.init(title: "Create an Album", style: UIAlertActionStyle.default, handler: {[weak self] alert in self?.createAnAlbum()})
        let actionExisting = UIAlertAction.init(title: "Choose an Existing Album", style: UIAlertActionStyle.default, handler: {[weak self] alert in self?.showPhotoLibrary()})
        self.AlbumAlert?.addAction(actionAlbum)
        self.AlbumAlert?.addAction(actionExisting)
        self.AlbumAlert?.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Get size of the collectionView cell for thumbnail image
        if let layout = self.collectionViewLayout as? UICollectionViewFlowLayout{
            let cellSize = layout.itemSize
            
            self.assetThumbnailSize = CGSize(width: cellSize.width, height: cellSize.height)
        }
        
        refreshData()
       
        navigationItem.setRightBarButton(UIBarButtonItem.init(barButtonSystemItem: .trash, target: self, action: #selector(removeAlbum)), animated: true)
    }
    func refreshData(){
        guard assetCollection != nil else {
            print("Asset collection is nil")
            return
        }
        
        //fetch the photos from collection
        self.photosAsset = (PHAsset.fetchAssets(in: self.assetCollection, options: nil) as AnyObject!) as! PHFetchResult<AnyObject>!
        
        self.collectionView!.reloadData()
    }
    func removeAlbum(){
        if var vcs = self.navigationController?.viewControllers {
            _ = vcs.popLast()
            if vcs.last as? PathDetailViewController != nil {
                CrumbsManager.shared.currentPath?.albumData = nil
            }
            
            self.navigationController?.setViewControllers(vcs, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        var count: Int = 1
        
        if(self.photosAsset != nil){
            count = self.photosAsset!.count + 1
        }
        
        return count;
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if self.photosAsset == nil || indexPath.row == self.photosAsset?.count { //last cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addPhoto", for: indexPath as IndexPath) as! AddPhotoCell
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cameraCell", for: indexPath as IndexPath) as! ImageCollectionViewCell
        
        //Modify the cell
        let asset: PHAsset = self.photosAsset?[indexPath.item] as! PHAsset
        
        PHImageManager.default().requestImage(for: asset, targetSize: self.assetThumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: {(result, info)in
            if result != nil {
                cell.imageView.image = result
            }
        })
        
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        if self.photosAsset == nil || indexPath.row == self.photosAsset?.count { //last cell
            present(AlbumAlert!, animated: true, completion: nil)
        } else{
            showFull()
        }
    }
    
    func showFull(){
        let photovc = storyboard?.instantiateViewController(withIdentifier: "Photos Table") as! PhotosViewController
        photovc.assetCollection = assetCollection
        
        self.parent?.navigationController?.pushViewController(photovc, animated: true)
    }
    public func createAnAlbum(){
        let crumbsManager = CrumbsManager.shared
        let path = crumbsManager.currentPath
        if let start = path?.startdate, let end = path?.enddate {
            PhotoManager.createTimespanAlbum(name: "\(path?.title ?? "breadcrumb") - \((start as Date).datestring)", start: start as Date, end: end as Date, completionHandler: {
                [weak self] (collection, error) in
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
