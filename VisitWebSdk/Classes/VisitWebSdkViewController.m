//
//  VisitWebSdk.m
//  VisitWebSdk
//
//  Created by Yash on 16/11/22.
//

#import "VisitWebSdkViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface VisitWebSdkViewController () <CLLocationManagerDelegate>
@end

API_AVAILABLE(ios(13.0))
@implementation VisitWebSdkViewController

- (instancetype)initWithFrame:(CGRect)frame{
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.preferences.javaScriptEnabled = YES;
    [config.userContentController
              addScriptMessageHandler:self name:@"visitIosView"];
    self = [super initWithFrame:CGRectZero configuration:config];
    [self.scrollView setScrollEnabled:NO];
    [self.scrollView setMultipleTouchEnabled:NO];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder{
    return [super initWithCoder:coder];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]) {
        if(self.estimatedProgress>0.99){
            [activityIndicator stopAnimating];
            [sbViewController dismissViewControllerAnimated:NO completion:^{
                NSLog(@"Storyboard dismissed");
            }];
        }
    }
}

- (void)closeAddDependentView:(UIButton*)button
   {
       [addDependentViewController dismissViewControllerAnimated:NO completion:^{
           NSLog(@"dependent view dismissed");
       }];
  }

- (UIViewController *)currentTopViewController {
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

- (void)loadVisitWebUrl:(NSString*) magicLink{
    NSBundle* podBundle = [NSBundle bundleForClass:[self class]];
    NSURL* bundleUrl = [podBundle URLForResource:@"VisitWebSdk" withExtension:@"bundle"];
    NSBundle* bundle = [NSBundle bundleWithURL:bundleUrl];
    
    storyboard = [UIStoryboard storyboardWithName:@"Loader" bundle:bundle];
    sbViewController = [storyboard instantiateInitialViewController];
    sbViewController.modalPresentationStyle = 0;
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    activityIndicator.color = UIColor.systemPurpleColor;
    activityIndicator.center = sbViewController.view.center;
    [sbViewController.view addSubview:activityIndicator];
    [activityIndicator startAnimating];

    currentTopVC = [self currentTopViewController];
    [currentTopVC presentViewController:sbViewController animated:false completion:nil];

    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:NSKeyValueObservingOptionNew context:NULL];
    
    NSLog(@"loadVisitWebUrl is called ===>>> %@", magicLink);
    NSURL *url = [NSURL URLWithString:magicLink];
    NSURLRequest* request = [NSURLRequest requestWithURL: url];
    [super loadRequest:request];
}

-(void) injectJavascript:(NSString *) javascript{
//    NSLog(@"javascript to be injected %@",javascript);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self evaluateJavaScript:javascript completionHandler:^(NSString *result, NSError *error) {
            if(error != nil) {
                NSLog(@"injectJavascript Error: %@",error);
                return;
            }
//            NSLog(@"SomeFunction Success %@",result);
        }];
    });
}

-(void) openDependentLink:(NSURL *) url{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *btnImage = [UIImage systemImageNamed:@"chevron.left"];
    [button setImage:btnImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeAddDependentView:)
    forControlEvents:UIControlEventTouchUpInside];
    [button setTintColor: UIColor.blackColor];
    button.frame = CGRectMake(0.0, 60.0, 50.0, 40.0);
    
    addDependentViewController = [[UIViewController alloc] init];
    addDependentViewController.modalPresentationStyle = 0;
    [addDependentViewController.view addSubview:button];
    addDependentViewController.view.frame = CGRectMake(0.0, 100.0, self.frame.size.width, self.frame.size.height-100.0);
    [currentTopVC presentViewController:addDependentViewController animated:false completion:nil];

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    WKWebView *addDependentView = [[WKWebView alloc] initWithFrame:addDependentViewController.view.frame configuration:config];
    NSURLRequest* request = [NSURLRequest requestWithURL: url];
    [addDependentView loadRequest:request];
    [addDependentViewController.view addSubview:addDependentView];
}

-(void) closePWA{
    [self postNotification:@"ClosePWAEvent"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VisitEventType" object:nil];
    [self.configuration.userContentController removeAllUserScripts];
    [self removeFromSuperview];
    self.navigationDelegate = nil;
    self.scrollView.delegate = nil;
    [self stopLoading];
}

-(void) postNotification:(NSString *) event{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VisitEventType" object:nil userInfo:@{
        @"event":event
    }];
}

-(void) postNotification:(NSString *) event value:(NSString*)value{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VisitEventType" object:nil userInfo:@{
        @"event":event,
        @"value1":value
    }];
}

-(void) postHraQuestionAnsweredNotification:(NSString*)value total:(NSString*)total{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VisitEventType" object:nil userInfo:@{
        @"event":@"HRAQuestionAnswered",
        @"current":value,
        @"total":total
    }];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [self injectJavascript:@"window.checkTheGpsPermission(true);"];
    } else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location Permission"
                                                                       message:@"Location access is required. Please enable it in Settings."
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Open Settings"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action) {
            NSURL *settingsUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:settingsUrl]) {
                [[UIApplication sharedApplication] openURL:settingsUrl options:@{} completionHandler:nil];
            }
        }];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];

        [alert addAction:cancelAction];
        [alert addAction:settingsAction];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self->currentTopVC presentViewController:alert animated:YES completion:nil];
        });
    }
}

- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    NSData *data = [message.body dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *methodName = [json valueForKey:@"method"];
    NSLog(@"json is %@",[json description]);
    if([methodName isEqualToString:@"inHraEndPage"]){
        NSString *javascript = [NSString stringWithFormat:@"isIosUser(true)"];
        [self injectJavascript:javascript];
    }else if([methodName isEqualToString:@"hraQuestionAnswered"]){
        NSString* current = [json valueForKey:@"current"];
        NSString* total = [json valueForKey:@"total"];
        [self postHraQuestionAnsweredNotification:current total:total];
    }else if([methodName isEqualToString:@"hraCompleted"]){
        [self postNotification:@"HRA_Completed"];
    }else if([methodName isEqualToString:@"closeView"]){
        [self closePWA];
    }else if([methodName isEqualToString:@"openPDF"]){
        NSString *link = [json valueForKey:@"url"];
        NSURL *url = [NSURL URLWithString:link];
        NSData *pdfData = [NSData dataWithContentsOfURL:url];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[pdfData] applicationActivities:nil];
        activityViewController.excludedActivityTypes = @[
            UIActivityTypeCopyToPasteboard,
            UIActivityTypePrint,
            UIActivityTypeMarkupAsPDF,
        ];
        [currentTopVC presentViewController:activityViewController animated:YES completion:nil];
    }else if([methodName isEqualToString:@"mailTo"]){
        NSString *email = [json valueForKey:@"email"];
        NSString *subject = [json valueForKey:@"subject"];
        NSString *mail = [NSString stringWithFormat: @"mailto:%@?subject=%@", email, subject];
        mail = [mail stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *url = [NSURL URLWithString:mail];
        if([[UIApplication sharedApplication] canOpenURL:url]){
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }else{
            NSLog(@"Cannot open url");
        }
    }else if([methodName isEqualToString:@"openDependentLink"]){
        NSString* link = [[json valueForKey:@"link"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *url = [NSURL URLWithString:link];
        [self openDependentLink:url];
    }else if([methodName isEqualToString:@"pendingHraUpdation"]){
        NSString *javascript = [NSString stringWithFormat:@"updateHraToAig()"];
        [self injectJavascript:javascript];
    }else if([methodName isEqualToString:@"getLocationPermissions"]){
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];

    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;

    if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    } else {
        [self locationManager:self.locationManager didChangeAuthorizationStatus:status];
    }
}
}

@end
