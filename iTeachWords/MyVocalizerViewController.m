//
//  MyVocalizerViewController.m
//  iTeachWords
//
//  Created by Edwin Zuydendorp on 1/26/12.
//  Copyright (c) 2012 OSDN. All rights reserved.
//

#import "MyVocalizerViewController.h"
#import "MyUIViewClass.h"

@implementation MyVocalizerViewController

@synthesize caller;

- (id)initWithDelegate:(id)_caller{
    self = [super initWithNibName:@"MyVocalizerViewController" bundle:nil];
    if(self){
        self.caller = _caller;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)loadView{
    [super loadView];
    //    [recordButton setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
//    [helpBtn setTitle:NSLocalizedString(@"Settings", @"") forState:UIControlStateNormal];
    NSString *nativeCountry = [[NSUserDefaults standardUserDefaults] stringForKey:@"nativeCountry"];
    NSString *translateCountry = [[NSUserDefaults standardUserDefaults] stringForKey:@"translateCountry"];
    
//    [languageCodeLbl setText:NSLocalizedString(@"Language Code", @"")];
    [languageType setTitle:[NSString stringWithFormat:@"%@",translateCountry] forSegmentAtIndex:0];
    [languageType setTitle:[NSString stringWithFormat:@"%@",nativeCountry] forSegmentAtIndex:1];  
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [messageLbl setText:NSLocalizedString(@"Tap to play...", @"")];
    [majorView setBackgroundColor:[UIColor clearColor]];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    self.caller = nil;
    [majorView release];
    majorView = nil;
    [toolsView release];
    toolsView = nil;
    [helpBtn release];
    helpBtn = nil;
    [exitBtn release];
    exitBtn = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // grab an image of our parent view    
    // For iOS 5 you need to use presentingViewController:
    UIView *parentView;
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0) {
        parentView = self.presentingViewController.view;
    }else{
        parentView = self.parentViewController.view;
    }
    
    UIGraphicsBeginImageContext(parentView.bounds.size);
    [parentView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *parentViewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // insert an image view with a picture of the parent view at the back of our view's subview stack...
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -20, parentView.bounds.size.width, parentView.bounds.size.height)];
    imageView.image = parentViewImage;
    [self.view insertSubview:imageView atIndex:0];
    [imageView setHidden:YES];
    [imageView release];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[[self.view subviews] objectAtIndex:0] setHidden:NO];
    [languageType setSelectedSegmentIndex:([NATIVE_LANGUAGE_CODE isEqualToString:[languageCode uppercaseString]])?1:0];
    [speakButton setImage:[UIImage imageNamed:@"right.png"] forState:UIControlStateNormal];
    if ([speakString length]>0) {
        [self speakOrStopAction:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[[self.view subviews] objectAtIndex:0] removeFromSuperview];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [majorView release];
    [toolsView release];
    [helpBtn release];
    [exitBtn release];
    [super dealloc];
}

- (IBAction)close:(id)sender {
    if (isSpeaking) {
        [vocalizer cancel];
        isSpeaking = NO;
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)showToolsView:(id)sender {
    [self showHideToolsView];
}

- (void)showHideToolsView{
    CGRect majorViewFrame = [self getFrameForMajorView];
    CGRect exitBtnFrame = exitBtn.frame;
    exitBtnFrame.origin.y = majorViewFrame.origin.y-exitBtn.frame.size.height/2;
    
    //make button animation
    [UIView beginAnimations:@"SaveButtonAnimation" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [majorView setFrame:majorViewFrame];
    [exitBtn setFrame:exitBtnFrame];
    [UIView commitAnimations];
    if (!isToolsViewShowing) {
        [majorView performSelector:@selector(addSubview:) withObject:toolsView afterDelay:.3];
        [majorView sendSubviewToBack:toolsView];
    }else{
        [toolsView performSelector:@selector(removeFromSuperview)withObject:nil afterDelay:0.1];
    }
    CGRect toolsViewFrame = [self getFrameForToolsView];
    [toolsView setFrame:toolsViewFrame];
    isToolsViewShowing = !isToolsViewShowing;    
    [majorView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES ];

}

- (CGRect)getFrameForMajorView{
    CGRect frame;
    static CGRect majorViewOriginFrame;
    static CGRect majorViewExtendedFrame;
    if (CGRectIsEmpty(majorViewOriginFrame)) {
        majorViewOriginFrame = majorView.frame;
    }
    majorViewExtendedFrame = CGRectMake(majorViewOriginFrame.origin.x, majorViewOriginFrame.origin.y-toolsView.frame.size.height/2, 
                                        majorViewOriginFrame.size.width, majorViewOriginFrame.size.height + toolsView.frame.size.height);
    frame = (!isToolsViewShowing)?majorViewExtendedFrame:majorViewOriginFrame;
    return frame;
}

- (CGRect)getFrameForToolsView{
    static CGRect toolsViewOriginFrame;
    if (CGRectIsEmpty(toolsViewOriginFrame)) {
        toolsViewOriginFrame = CGRectMake(0, 173, majorView.frame.size.width, toolsView.frame.size.height);//toolsView.frame;
        
    }
    return toolsViewOriginFrame;
}

- (NSString*)getLangType{
    NSString* langType;
    
    switch (languageType.selectedSegmentIndex) {
        case 0:{
            NSDictionary *translateCountryInfo = TRANSLATE_COUNTRY_INFO;
            NSString *code =[[translateCountryInfo objectForKey:@"code"] lowercaseString];
            NSString *subCode =[[translateCountryInfo objectForKey:@"firstCode"] lowercaseString];
            NSLog(@"%@",translateCountryInfo);
            langType = [NSString stringWithFormat:@"%@_%@",code,subCode];//@"en_US";
        }
            break;
        case 1:{
            NSDictionary *nativeCountryInfo = NATIVE_COUNTRY_INFO;
            NSString *code =[[nativeCountryInfo objectForKey:@"code"] lowercaseString];
            NSString *subCode =[[nativeCountryInfo objectForKey:@"firstCode"] lowercaseString];
            NSLog(@"%@",nativeCountryInfo);
            langType = [NSString stringWithFormat:@"%@_%@",code,subCode] ;//@"en_US";
        }
            break;
    }
    NSLog(@"%@",langType);
    return langType;
}


- (void)setText:(NSString*)_text withLanguageCode:(NSString*)_languageCode{
    self.speakString = _text;
    self.languageCode = _languageCode;
    [textToRead setText:speakString];
    NSLog(@"%@",_languageCode);
    [languageType setSelectedSegmentIndex:([NATIVE_LANGUAGE_CODE isEqualToString:[languageCode uppercaseString]])?1:0];
}

@end
