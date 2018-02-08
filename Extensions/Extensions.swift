//
//  UIImageExtension.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 5/23/17.
//

import UIKit
import CoreGraphics
import RxSwift
import RxCocoa
import RxDataSources

extension UIImage {
    class func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        
        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: rect)
        
        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }
    
}

extension UIImageView {
    
    func setRounded() {
        let radius = self.frame.width / 2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}


extension UIViewController {
    func setClearNav(tintColor: UIColor = UIColor.HYP_LinkBlue){
        //        let color = UIColor.HYP_LinkBlue
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = tintColor
        self.navigationController?.navigationBar.backgroundColor = .clear
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:tintColor]
        self.navigationItem.leftBarButtonItem?.tintColor = tintColor
        self.navigationItem.rightBarButtonItem?.tintColor = tintColor
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
}

extension UIColor {
    static let HYP_Green : UIColor = UIColor.init(rgb:0x00AB84)
    static let HYP_GreenDark : UIColor = UIColor.init(rgb:0x009a77)
    
    static let HYP_DarkGray : UIColor = UIColor.init(rgb: 0x666666)
    static let HYP_MidGray : UIColor = UIColor.init(rgb: 0x999999)
    static let HYP_LightGray : UIColor = UIColor.init(rgb: 0xcccccc)
    static let HYP_OffWhite: UIColor = UIColor.init(rgb: 0xe6e6e6)
    static let HYP_White: UIColor = UIColor.init(rgb: 0xf2f2f2)
    
    static let HYP_BtnGray : UIColor = UIColor.init(rgb:0xc1c1c1)
    static let HYP_BtnGrayDark : UIColor = UIColor.init(rgb:0xbbbbbb)
    
    static let HYP_Red : UIColor = UIColor.init(rgb:0xC62325)
    static let HYP_LinkBlue : UIColor = UIColor.init(rgb: 0x0952E4)
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
}
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

extension UINavigationController {
    public func presentTransparentNavigationBar() {
//        UINavigationBar.appearance().barTintColor = primarycolor
//        UINavigationBar.appearance().tintColor = secondarycolor
//        UINavigationBar.appearance().backgroundColor = primarycolor
//        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: secondarycolor]
//
        navigationBar.barTintColor = UIColor.clear
        //navigationBar.tintColor = UIColor.clear
        navigationBar.backgroundColor = UIColor.clear
        
        navigationBar.setBackgroundImage(UIImage(), for:UIBarMetrics.default)
        navigationBar.isTranslucent = true
        navigationBar.shadowImage = UIImage()
        setNavigationBarHidden(false, animated:true)
        
    }
    
    public func hideTransparentNavigationBar() {
        setNavigationBarHidden(false, animated:false)
        
        navigationBar.setBackgroundImage(UINavigationBar.appearance().backgroundImage(for: UIBarMetrics.default), for: UIBarMetrics.default)
        navigationBar.isTranslucent = UINavigationBar.appearance().isTranslucent
        navigationBar.shadowImage = UINavigationBar.appearance().shadowImage
       
        navigationBar.barTintColor = UINavigationBar.appearance().barTintColor
        //navigationBar.tintColor = UINavigationBar.appearance().tintColor
        navigationBar.backgroundColor = UINavigationBar.appearance().backgroundColor
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor(rgb: 0xFFFC79) //yellow

        }
        UIApplication.shared.statusBarStyle = .lightContent
    }
}


