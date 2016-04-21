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
        defer{
            if let controller = safariController {
               removeHiddenSafariViewController(controller)
            }
        }
        let url = notification.object as? NSURL
        
        print("scheme :\(url?.scheme),query: \(url?.query)")
        lblStatus.text = url?.query
        guard let code = extractCode(url?.query) else {
            return
        }
        
        requestAccessToken(code) { (inner) in
            do{
                let accessToken = try inner()
                print(accessToken)
            }catch let error as NSError{
                print(error.localizedDescription)
            }
            
            
        }
        
        
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
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * seconds))
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

extension ViewController{
    func extractCode(query:String?) -> String? {
        guard let query = query else {
            return nil
        }
        return query.componentsSeparatedByString("=").last
    }
    
    func requestAccessToken(code:String,completion:(inner:()throws ->String)->()){
        let manager = Manager.sharedInstance
        let params = ["client_id":kClientId,
                      "client_secret":kClientSerectId,
                      "grant_type": "authorization_code",
                      "redirect_uri":kRedirectURI,
                      "code":code]
        manager.request(.POST,
            APIType.RequestAccessToken.URLRequest,
            parameters: params).response
            { (_, _, data, error) in
                
            guard let data = data else{
                completion(inner: {throw  NSError(domain: "com.test", code: 7548, userInfo: [NSLocalizedDescriptionKey:"No Data!!!"])})
                return
            }
            
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                print(json)
                
                guard let accessToken = json["access_token"] as? String else {
                    throw NSError(domain: "com.test", code: 564, userInfo: [NSLocalizedDescriptionKey:"No Access Token"])
                }
                
                completion(inner: {return accessToken})
                
            }catch let error as NSError{
                completion(inner: {throw error})
            }
        }

    }
    
    
}

