//
//  ViewController.swift
//  PhotoByYou
//
//  Created by Dung Vu on 4/21/16.
//  Copyright © 2016 Dung Vu. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices

let kCloseSafariViewControllerNotification = "kCloseSafariViewControllerNotification"

class ViewController: UIViewController {

    weak var safariController:SFSafariViewController?
    @IBOutlet weak var lblStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        lblStatus.text = "Not Login!!!"
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(ViewController.safariLogin(_:)),
                                                         name: kCloseSafariViewControllerNotification,
                                                         object: nil)
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func tapByLogin(sender: AnyObject) {
        lblStatus.text = "Prepare Login......"
        callWebToLogin()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController:SFSafariViewControllerDelegate{
    func callWebToLogin(){
        let controller = SFSafariViewController(URL: APIType.Login.URLRequest.URL!)
        controller.delegate = self
        safariController = controller
        safariController?.view.layer.anchorPoint = CGPointMake(0, 0)
        showHiddenSafariViewController(controller)
        
    }
    
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        lblStatus.text = "Not Login!!!"
        removeHiddenSafariViewController(controller)
    }
    
    func safariLogin(notification:NSNotification){
        let url = notification.object as? NSURL
        
        print("scheme :\(url?.scheme),query: \(url?.query)")
        lblStatus.text = url?.query
        guard let controller = safariController else {
            return
        }
        
        removeHiddenSafariViewController(controller)
        
    }
    
    func safariViewController(controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        print("Did Complete Load")
        delay(0.5) { [weak self] in
            self?.safariController?.view.layer.addAnimation(self!.animationLogin(true), forKey: nil)
        }
        
    }
    
    func animationLogin(isPresent:Bool) -> CAAnimationGroup {
        
        let animationTranslation = CABasicAnimation(keyPath: "position.y")
        animationTranslation.fromValue = isPresent ? view.bounds.height : 0
        animationTranslation.toValue = isPresent ? 0 : view.bounds.height
        
        let animationFade = CABasicAnimation(keyPath: "opacity")
        animationFade.fromValue = isPresent ? 0 : 1
        animationFade.toValue = isPresent ? 1 : 0
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 0.3
        animationGroup.delegate = self
        animationGroup.setValue(isPresent ? "present" : "dismiss", forKey: "name")
        animationGroup.animations = [animationTranslation,animationFade]
        animationGroup.fillMode = kCAFillModeBoth
        animationGroup.removedOnCompletion = false
        
        return animationGroup
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        guard let value = anim.valueForKey("name") as? String where value == "dismiss" else{
            safariController?.view.alpha = 1
            return
        }
        self.removeSafariController()
    }
    
    func delay(seconds:Double,block:()->()) {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * UInt64(seconds)))
        dispatch_after(time, dispatch_get_main_queue(), block)
        
    }
    
    private func removeSafariController()
    {
        safariController?.willMoveToParentViewController(nil)
        safariController?.view.removeFromSuperview()
        safariController?.removeFromParentViewController()
    }
    
    private func showHiddenSafariViewController(controller:SFSafariViewController) {
        controller.view.alpha = 0.0
        self.addChildViewController(controller)
        self.view.addSubview(controller.view)
        controller.didMoveToParentViewController(self)
        controller.view.frame = view.bounds
    }
    
    private func removeHiddenSafariViewController(controller:SFSafariViewController) {
        if controller.view.alpha > 0 {
            controller.view.layer.addAnimation(animationLogin(false), forKey: nil)
        }else{
            self.removeSafariController()
        }
    }
}

