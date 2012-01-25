//
//  TextViewController.m
//  Untitled
//
//  Created by Edwin Zuydendorp on 6/25/10.
//  Copyright 2010 OSDN. All rights reserved.
//

#import "TextViewController.h"
#import "StringTools.h"
//#import "myButtonPlayer.h"
#import "LanguagePickerController.h"
#import "NewWordsTable.h"

#define radius 10

@implementation TextViewController
@synthesize array;
@synthesize arrayCount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self  = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
                                                   initWithTitle:NSLocalizedString(@"Parse text", @"") style:UIBarButtonItemStyleBordered 
                                                   target:self 
                                                   action:@selector(showTable)] autorelease];
        [self createMenu];
    }
    return self;
}


-(id) initWithTabBar {
	if ([self init]) {
		//метка на кнопке собственно вкладки
		self.title = @"Text translate";
		//добавьте к проекту любое изображение
		self.tabBarItem.image = [UIImage imageNamed:@"40-inbox.png"];
	}
	return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    myTextView.layer.cornerRadius = radius;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createMenu];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"grnd.png"]];
    [myTextView setFont:FONT_TEXT];
	myTextView.text = [self loadText];

}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void) back{
    [self saveText];
	[super back];
}

- (IBAction) showTable{
	[self saveText];
	NewWordsTable *table = [[NewWordsTable alloc] initWithNibName:@"NewWordsTable" bundle:nil];
    [self.navigationController pushViewController:table animated:YES];
    [table loadDataWithString:myTextView.text];
}

#pragma mark MyRecognize functions

- (IBAction) showVoiceRecordView{
	MyRecognizerViewController *voiceView = [[MyRecognizerViewController alloc] initWithDelegate:self];
    [self.navigationController presentModalViewController:voiceView animated:YES];
    [voiceView release];
}

- (IBAction)selectAll:(id)sender {
    [myTextView selectAll:self];
    [[UIMenuController sharedMenuController] setIsAccessibilityElement:NO];
//    [UIMenuController can]
//    [UIMenuController sharedMenuController].menuVisible = YES;
//    [myTextView setSelectedRange:NSRangeFromString(myTextView.text)];
}

- (IBAction)clearAll:(id)sender {
    [myTextView setText:@""];
}

#pragma mark MyRecognize delegate

-(void)didRecognizeText:(NSString*)text languageCode:(NSString*)textLanguageCode{
    NSArray *languageCode = [textLanguageCode componentsSeparatedByString:@"-"];
    [self setCurrentTextLanguage:[[languageCode objectAtIndex:0] lowercaseString]];
    [myTextView setText:text];
}

- (NSString *) loadText{
	NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[[[NSBundle mainBundle] infoDictionary] objectForKey: @"myResource"]];
	path = [path stringByAppendingPathComponent:@"myText.doc"];
    NSError *error = nil;
	NSString *_str = [NSString stringWithContentsOfFile:(NSString *)path encoding:NSUTF8StringEncoding error:(NSError **)error];
	if (error)
	{
		NSLog(@"Error writing file at path: %@; error was %@", path, error);
		return [NSString stringWithFormat:@"Error writing file at path: %@; error was %@", path, error];
	}
    return _str;
}
					 
- (void) saveText{
	NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[[[NSBundle mainBundle] infoDictionary] objectForKey: @"myResource"]];
    path = [path stringByAppendingPathComponent:@"myText.doc"];
    NSString *plist = myTextView.text;
    NSError *error = nil;
    [plist writeToFile:path
            atomically:YES
              encoding:NSUTF8StringEncoding
                 error:&error];
    
    [[NSUserDefaults standardUserDefaults] setValue:currentTextLanguage forKey:@"lastTextLanguageInTextParseView"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (error)
    {
        NSLog(@"Error writing file at path: %@; error was %@", path, error);
    }
}

//- (void) createMenu{
//    [self becomeFirstResponder];
//    NSMutableArray *menuItemsMutableArray = [NSMutableArray new];
//    UIMenuItem *menuItem = [[[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Translate", @"")
//                                                       action:@selector(translateText)] autorelease];
//    [menuItemsMutableArray addObject:menuItem];
//    UIMenuController *menuController = [UIMenuController sharedMenuController];
//    [menuController setTargetRect: CGRectMake(0, 0, 320, 200)
//                           inView:self.view];
//    menuController.menuItems = menuItemsMutableArray;
//    [menuController setMenuVisible:YES
//                          animated:YES];
//    [[UIMenuController sharedMenuController] setMenuItems:menuItemsMutableArray];
//    [menuItemsMutableArray release];
//}
//
//-(void) translateText{
//    //[textView resignFirstResponder];
//    NSString *selectedText = [self getSelectedText];
//    if ([selectedText length] > 0) {
//        NSLog(@"%@",selectedText);
//        NSString *translate = [selectedText translateString];
//        if (translate) {
//            [UIAlertView displayMessage:translate];
//        }
//    }
//}

- (NSString *)getSelectedText{
    range = myTextView.selectedRange;
    NSMutableString *text = [NSMutableString stringWithString:myTextView.text];
    NSString *selectedText = [text substringWithRange:range];
    return selectedText;
}

-(void) translateText{
    NSString *selectedText = [self getSelectedText];
    if (selectedText.length > 0) {
        if (!currentTextLanguage) {
            [self setCurrentTextLanguage:[[NSUserDefaults standardUserDefaults] stringForKey:@"lastTextLanguageInTextParseView"]];
        }
        NSString *translateLangusgeCode = ([[[NSUserDefaults standardUserDefaults] objectForKey:NATIVE_COUNTRY_CODE] isEqualToString:[currentTextLanguage uppercaseString]])?[[NSUserDefaults standardUserDefaults] objectForKey:TRANSLATE_COUNTRY_CODE]:[[NSUserDefaults standardUserDefaults] objectForKey:NATIVE_COUNTRY_CODE];
        
        [wordsView.dataModel setDelegate:self];
        [wordsView.dataModel loadTranslateText:selectedText fromLanguageCode:currentTextLanguage toLanguageCode:translateLangusgeCode withDelegate:self];
//        NSString* translate = [selectedText translateStringWithLanguageCode:currentTextLanguage];
//        [UIAlertView displayMessage:translate];
    }
}


#pragma mark loadingTranslate delegate functions

- (void)translateDidLoad:(NSString *)translateText byLanguageCode:(NSString*)_activeTranslateLanguageCode{
//    if (translateText == nil) { 
//        return;
//    }
    [UIAlertView displayMessage:translateText];
}

#pragma mark textview delegate functions

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView.frame.size.height>195.0) {
        [UIView beginAnimations:@"Changing size of textView" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [myTextView setFrame:CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, 195.0)];
        [UIView commitAnimations];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.frame.size.height<395.0) {
        [UIView beginAnimations:@"Changing size of textView" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [myTextView setFrame:CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width,  332)];
        [UIView commitAnimations];
    }
}

- (BOOL)textView:(UITextView *)_textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [_textView resignFirstResponder];
        return NO;
    }
    [self setCurrentTextLanguage:[self detectCurrentTextLanguage]];
    return YES;
}

- (void)setCurrentTextLanguage:(NSString*)_textLanguage{
    if (_textLanguage != currentTextLanguage) {
        if (currentTextLanguage) {
            [currentTextLanguage release];
        }
        currentTextLanguage = [_textLanguage retain];
    }
}


- (NSString *)detectCurrentTextLanguage{
    NSLog(@"%@",[UITextInputMode activeInputModes]);
    NSLog(@"%@",[UITextInputMode currentInputMode]);
    if ([UITextInputMode currentInputMode] == nil) {
        return [[NSUserDefaults standardUserDefaults] stringForKey:TRANSLATE_COUNTRY_CODE];
    }
    NSArray *languageCode = [[[UITextInputMode currentInputMode] primaryLanguage] componentsSeparatedByString:@"-"];
    return [[languageCode objectAtIndex:0] lowercaseString];
}

//- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
//    return YES;
//}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)setText:(NSString*)text{
    [myTextView setText:text];
}

- (void)viewDidUnload
{
    [myTextView release];
    myTextView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [currentTextLanguage release];
    [myTextView release];
	[array release];
    [super dealloc];
}
@end
