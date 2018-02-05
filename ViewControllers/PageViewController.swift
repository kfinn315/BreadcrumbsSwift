//
//  PageViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 2/1/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import UIKit

class PageViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    lazy var pages : [UIViewController?] = []
    var currentIndex = 0
    
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        let vc0 = storyboard?.instantiateViewController(withIdentifier: "Detail")
        let vc1 = storyboard?.instantiateViewController(withIdentifier: "MapVC")
        let vc2 = storyboard?.instantiateViewController(withIdentifier: "Photos Table")
        pages = [vc0,vc1,vc2]
        
        self.dataSource = self
        self.setViewControllers([pages[0]!], direction: .forward, animated: true, completion: nil)
        
        self.delegate = self
        
       // btnEdit.action = #selector(editPath)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews {
            if view is UIScrollView {
                view.frame = UIScreen.main.bounds
            } else if view is UIPageControl {
                view.backgroundColor = UIColor.clear
            }
        }
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController is MapViewController {
            return pages[0]
        }
        
        if viewController is PhotosViewController {
            return pages[1]
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController is PathDetailViewController {
            return pages[1]
        }

        if viewController is MapViewController {
            return pages[2]
        }
        
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentIndex
    }
    

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if pendingViewControllers.first is PathDetailViewController {
            currentIndex = 0
        }
        
        if pendingViewControllers.first is MapViewController {
            currentIndex = 1
        }
        
        if pendingViewControllers.first is PhotosViewController {
            currentIndex = 2
        }
    }
    
    @objc func editPath(){
        self.navigationController?.pushViewController(EditPathViewController(), animated: true)
    }
}
