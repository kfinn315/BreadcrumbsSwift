import UIKit
import Photos

class PhotosViewController: UICollectionViewController {    
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult<AnyObject>!
    var assetThumbnailSize: CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Get size of the collectionView cell for thumbnail image
        if let layout = self.collectionViewLayout as? UICollectionViewFlowLayout{
            let cellSize = layout.itemSize
            
            self.assetThumbnailSize = CGSize(width: cellSize.width, height: cellSize.height)
        }
        
        guard assetCollection != nil else {
            print("Asset collection is nil")
            return
        }
        //fetch the photos from collection
        self.photosAsset = (PHAsset.fetchAssets(in: self.assetCollection, options: nil) as AnyObject!) as! PHFetchResult<AnyObject>!
        
        
        self.collectionView!.reloadData()
            navigationItem.setRightBarButton(UIBarButtonItem.init(barButtonSystemItem: .trash, target: self, action: #selector(removeAlbum)), animated: true)
    }
    
    func removeAlbum(){
        if var vcs = self.navigationController?.viewControllers {
            _ = vcs.popLast()
            if let detailvc = vcs.last as? PathDetailViewController {
                detailvc.path?.albumData = nil
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
        var count: Int = 0
        
        if(self.photosAsset != nil){
            count = self.photosAsset.count
        }
        
        return count;
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cameraCell", for: indexPath as IndexPath) as! ImageCollectionViewCell
        
        //Modify the cell
        let asset: PHAsset = self.photosAsset[indexPath.item] as! PHAsset
        
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
}
