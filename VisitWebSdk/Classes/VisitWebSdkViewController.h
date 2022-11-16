//
//  VisitWebSdkViewController.h
//  Pods
//
//  Created by Yash on 16/11/22.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface VisitWebSdkViewController : WKWebView<WKScriptMessageHandler>{
    // Member variables go here.
    UIStoryboard* storyboard;
    UIViewController * sbViewController;
    UIViewController *currentTopVC;
    UIViewController * addDependentViewController;
    UIActivityIndicatorView *activityIndicator;
}

- (void) loadVisitWebUrl:(NSString*) magicLink;

@end

