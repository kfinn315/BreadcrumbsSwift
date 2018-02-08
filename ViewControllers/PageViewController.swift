//
//  PageViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 2/1/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import UIKit

class PageViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        if let storyboard = self.storyboard {
            return [storyboard.instantiateViewController(withIdentifier: "Detail"),
                    storyboard.instantiateViewController(withIdentifier: "MapVC"),
                    storyboard.instantiateViewController(withIdentifier: "Photos Table")]
        }
        
        return []
    }()
    
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        self.title = ""
        
        self.dataSource = self
        self.delegate = self
        self.orderedViewControllers[0].view.tag = 0
        self.orderedViewControllers[1].view.tag = 1
        self.orderedViewControllers[2].view.tag = 2

        if let vc = orderedViewControllers.first {
            self.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
        }
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
        let nextindex = viewController.view.tag - 1
      
        if nextindex >= 0 {
            return orderedViewControllers[nextindex]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let nextindex = viewController.view.tag + 1
        
        if nextindex < orderedViewControllers.count {
            return orderedViewControllers[nextindex]
        }
        
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return pageViewController.viewControllers?.first?.view?.tag ?? 0
    }

    @objc func editPath(){
        self.navigationController?.pushViewController(EditPathViewController(), animated: true)
    }
}
