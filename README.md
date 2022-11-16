# VisitWebSdk

[![CI Status](https://img.shields.io/travis/81799742/VisitWebSdk.svg?style=flat)](https://travis-ci.org/81799742/VisitWebSdk)
[![Version](https://img.shields.io/cocoapods/v/VisitWebSdk.svg?style=flat)](https://cocoapods.org/pods/VisitWebSdk)
[![License](https://img.shields.io/cocoapods/l/VisitWebSdk.svg?style=flat)](https://cocoapods.org/pods/VisitWebSdk)
[![Platform](https://img.shields.io/cocoapods/p/VisitWebSdk.svg?style=flat)](https://cocoapods.org/pods/VisitWebSdk)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- Supports iOS version >=13.0
- The project needs to have cocoapods added to it. Please follow this [article](https://www.hackingwithswift.com/articles/95/how-to-add-cocoapods-to-your-project) to add cocoapods to your project.

## Installation

VisitWebSdk is available through [Visit private pod spec](https://github.com/VisitApp/visit-ios-pod-spec). To install
it, add the following lines to the top of your Podfile:

```ruby
source 'https://github.com/VisitApp/visit-ios-pod-spec.git'
source 'https://cdn.cocoapods.org/'
```

Then, add the following line within the target in your Podfile:


```ruby
pod 'VisitWebSdk'
```
## Usage

To use the SDK, you simply need to initialize VisitWebSdkViewController in your ViewController. Ensure that the initalized view is added to your main subview in viewDidLoad method. Once that is done call the loadVisitWebUrl method in viewDidAppear lifecycle method.

Here's an example code where the `VisitIosHealthController` is programmatically initialized -

```swift
import UIKit
import VisitWebSdk
extension Notification.Name {
    static let customNotificationName = Notification.Name("VisitEventType")
}

// extend VisitVideoCallDelegate if the video calling feature needs to be integrated otherwise UIViewController can be used
class ViewController: UIViewController {
    // required
    let visitHealthView = VisitWebSdkViewController.init()
    
    let button = UIButton(frame: CGRect(x: 20, y: 20, width: 200, height: 60))
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // show button programattically, in actual app this can be ignored
        self.showButton()
        
        // the notification observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: .customNotificationName, object: nil)
        
    }
    
    // show button programattically, in actual app this can be ignored
    @objc func showButton(){
        self.view.addSubview(button)
        button.center = CGPoint(x: view.frame.size.width  / 2, y: view.frame.size.height / 4)
        button.setTitle("Open Visit app", for: .normal)
        button.backgroundColor = .blue
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
        
    }
    
    // hide button programattically, in actual app this can be ignored
    @objc func hideButton(){
        button.removeFromSuperview()
    }
    
    // notification observer
    @objc func methodOfReceivedNotification(notification: Notification) {
        let event = notification.userInfo?["event"] as! String
        let current = notification.userInfo?["current"] ?? ""
        let total = notification.userInfo?["total"] ?? ""
        switch(event){
            case "HRA_Completed":
                print("hra completed")
            case "HRAQuestionAnswered":
                print("HRAQuestionAnswered,",current,"of",total)
                
            case "ClosePWAEvent":
                // show initial button again, in actual app this can be ignored
                self.showButton();

            default:
                print("nothing")
        }
        print("method Received Notification",event)
    }
    
    @objc func buttonTapped(sender : UIButton) {
        // since both UIs share same view the button needs to be hidden, in actual app this can be ignored
        self.hideButton()
        
        // all the below statements are required
        self.view.addSubview(visitHealthView)
        visitHealthView.translatesAutoresizingMaskIntoConstraints = false
        visitHealthView.loadVisitWebUrl("---magic-link---")
        let views = ["view" : visitHealthView]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[view]|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: views))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
```

## Author

81799742, yash-vardhan@hotmail.com

## License

VisitWebSdk is available under the MIT license. See the LICENSE file for more info.
