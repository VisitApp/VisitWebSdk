//
//  VisitWebSdkViewController.h
//  Pods
//
//  Created by Yash on 16/11/22.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <CoreLocation/CoreLocation.h>

@interface VisitWebSdkViewController : WKWebView<WKScriptMessageHandler>{
    // Member variables go here.
    UIStoryboard* storyboard;
    UIViewController * sbViewController;
    UIViewController *currentTopVC;
    UIViewController * addDependentViewController;
    UIActivityIndicatorView *activityIndicator;
}

// Property to retain CLLocationManager
@property (nonatomic, strong) CLLocationManager *locationManager;

- (void) loadVisitWebUrl:(NSString*) magicLink;

@end

