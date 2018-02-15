import Foundation
import UIKit
import Photos
import RxSwift
import RxCocoa

class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var crumbsManager = CrumbsManager.shared
    var disposeBag = DisposeBag()
    fileprivate let imageManager = PHCachingImageManager()
    var fetchResult: PHFetchResult<PHAsset>!
    var hasPermission = Variable<Bool>(false)
    var hasPermissionDriver : Driver<Bool>?
    var collectionViewLayout : UICollectionViewLayout?

    private var thumbnailSize: CGSize = CGSize(width: 50, height: 50)
    private lazy var imageViewController : ImageViewController? = {
        return storyboard?.instantiateViewController(withIdentifier: "ImageView") as! ImageViewController?
    }()
    
    private lazy var emptyLabel : UILabel = {
        let emptyLabel = UILabel(frame: CGRect(x:0, y:0, width: self.collectionView.bounds.size.width, height: self.view.bounds.size.height))
        emptyLabel.textAlignment = NSTextAlignment.center
        emptyLabel.numberOfLines = 0
        emptyLabel.text          = "Please allow this app to access Photos."
        emptyLabel.font          = emptyLabel.font.withSize(10)
        return emptyLabel
    }()
    
    lazy var albumAlert : UIAlertController = {
        let alert = UIAlertController(title: "Import Photo Album", message: "", preferredStyle: UIAlertControllerStyle.alert)
        let actionExisting = UIAlertAction.init(title: "Choose an Existing Album", style: UIAlertActionStyle.default, handler: { [weak self] _ in
            self?.showPhotoLibrary()
        })
        alert.addAction(actionExisting)
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        return alert
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetCachedAssets()
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        crumbsManager?.currentAlbumDriver.drive(onNext: { [weak self] assetcollection in
            guard assetcollection != nil
                else{ return }
            
//            self?.title = self?.crumbsManager?.currentAlbumTitle
            self?.fetchResult = PHAsset.fetchAssets(in: assetcollection!, options: nil)
            self?.collectionView?.reloadData()
        }).disposed(by: disposeBag)
        
        hasPermissionDriver = hasPermission.asObservable().asDriver(onErrorJustReturn: true)
        hasPermissionDriver?.drive(onNext: { [unowned self] (hasPermission) in
            if hasPermission {
                self.collectionView.backgroundView = nil
            }
            else {
                self.collectionView.backgroundView = self.emptyLabel
            }
            self.collectionView.reloadData()
        }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Get size of the collectionView cell for thumbnail image
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            let cellSize = layout.itemSize
            self.thumbnailSize = CGSize(width: cellSize.width, height: cellSize.height)
        }
        
        let photoAuth = PHPhotoLibrary.authorizationStatus()
        
        if photoAuth != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ [weak self] (status) in
                if status == PHAuthorizationStatus.authorized{
                    self?.hasPermission.value = true
                } else{
                    self?.hasPermission.value = false
                }
            })
        } else {
            hasPermission.value = true
        }
        
        updateItemSize()
        
        self.parent?.navigationItem.setRightBarButton(UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(showAdd)), animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateItemSize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    override func viewWillDisappear(_ animated: Bool) {
        (self.parent as? PageViewController)?.resetNavigationItem()
    }
    
    @objc func showAdd(){
        present(albumAlert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if hasPermission.value {
            return 1
        } else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return self.assets?.count ?? 0 + 1
        if self.fetchResult == nil
        {
            return 0
        }
        return self.fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = fetchResult.object(at: indexPath.item)
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cameraCell", for: indexPath) as? ImageCollectionViewCell
            else { fatalError("bad cell") }
        
        cell.representedAssetIdentifier = asset.localIdentifier
        
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier && image != nil {
                cell.imageView.image = image
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
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = fetchResult.object(at: indexPath.item)
        showFull(asset)
    }
    
    func showFull(_ asset: PHAsset) {
        if let imageViewController = imageViewController{
            imageViewController.asset = asset
            //photovc.assetCollection = assetCollection
            self.parent?.navigationController?.pushViewController(imageViewController, animated: true)
        }
    }
    
    public func showPhotoLibrary() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Albums") {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        // The preheat window is twice the height of the visible rect.
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        
        // Store the preheat rect to compare against in the future.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
    private func updateItemSize() {
        
        let viewWidth = view.bounds.size.width
        
        let desiredItemWidth: CGFloat = 100
        let columns: CGFloat = max(floor(viewWidth / desiredItemWidth), 4)
        let padding: CGFloat = 1
        let itemWidth = floor((viewWidth - (columns - 1) * padding) / columns)
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = itemSize
            layout.minimumInteritemSpacing = padding
            layout.minimumLineSpacing = padding
        }
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: itemSize.width * scale, height: itemSize.height * scale)
    }
    fileprivate var previousPreheatRect = CGRect.zero
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
}

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}
