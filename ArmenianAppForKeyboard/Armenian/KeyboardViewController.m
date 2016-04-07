//
//  KeyboardViewController.m
//  Armenian
//
//  Created by Levon Poghosyan on 3/30/16.
//  Copyright © 2016 Levon Poghosyan. All rights reserved.
//

#import "KeyboardViewController.h"
#import "Alpha.h"
#import "PredictiveBar.h"
#import "Colors.h"

// Height sizes for iPhone modes
#define kiPhonePortraitHeight       286; //251 + 35;
#define kiPhoneLandscapeHeight      247; //212 + 35;

// Height sizes for iPad modes
#define kiPadPortraitHeight       224;
#define kiPadLandscapeHeight      206;

// Define the tags for the UI components
#define kAlpha      1234
#define kPredBar    4321


@interface KeyboardViewController ()

// Height constraint
@property (nonatomic) NSLayoutConstraint *heightConstraint;

// Helper variables
@property (nonatomic) BOOL isLandscape;

// Variables for storing keyboard height on landscape and portrait modes
@property (nonatomic) CGFloat portraitHeight;
@property (nonatomic) CGFloat landscapeHeight;

@end

@implementation KeyboardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Perform custom initialization work here
        self.portraitHeight = kiPhonePortraitHeight;
        self.landscapeHeight = kiPhoneLandscapeHeight;
        
        // Instantiate currently typed word container
        currentWord = [[NSString alloc] init];
    }
    return self;
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    // Add custom view sizing constraints here
    if (self.view.frame.size.width == 0 || self.view.frame.size.height == 0)
        return;
    
    // If height constraint is not initialized do not continue
    if (self.heightConstraint == nil)
        return;
    
    [self.view removeConstraint:self.heightConstraint];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenH = screenSize.height;
    CGFloat screenW = screenSize.width;
    BOOL isLandscape =  !(self.view.frame.size.width ==
                          (screenW*(screenW<screenH))+(screenH*(screenW>screenH)));
    NSLog(isLandscape ? @"Screen: Landscape" : @"Screen: Potriaint");
    self.isLandscape = isLandscape;
    if (isLandscape) {
        NSLog(@"%f", self.landscapeHeight);
        self.heightConstraint.constant = self.landscapeHeight;
        [self.view addConstraint:self.heightConstraint];
    } else {
        NSLog(@"%f", self.portraitHeight);
        self.heightConstraint.constant = self.portraitHeight;
        [self.view addConstraint:self.heightConstraint];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add alpha keyboard
    [self addAlphaKeyboard];
    
    // Add prediction bar
    [self addPredictionBar];
    
    // Setup the colors manager
    [[Colors sharedManager] setTextDocumentProxy:self.textDocumentProxy];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:0.0
                                                          constant:self.portraitHeight];
    self.heightConstraint.priority = UILayoutPriorityRequired - 1; // This will eliminate the constraint conflict warning.
    [self.view addConstraint: self.heightConstraint];
    
    // Load spellchecker dictionary
    [bar loadDictionary];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)textWillChange:(id<UITextInput>)textInput
{
}

- (void) addAlphaKeyboard
{
    // Add alpha layout
    Alpha* alpha = [[Alpha alloc] init];
    
    // Register for numeric input
    alpha.delegate = self;
    
    // Set a unique tag
    alpha.tag = kAlpha;
    [self.view addSubview:alpha];
    
    // Add size constraints
    alpha.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Left constraint
    NSLayoutConstraint *alphaKeyboardButtonLeftConstraint = [NSLayoutConstraint constraintWithItem:alpha
                                                                                         attribute:NSLayoutAttributeLeft
                                                                                         relatedBy:NSLayoutRelationEqual
                                                                                            toItem:self.view
                                                                                         attribute:NSLayoutAttributeLeft
                                                                                        multiplier:1.0 constant:0.0];
    
    [self.view addConstraint:alphaKeyboardButtonLeftConstraint];
    
    // Right constraint
    NSLayoutConstraint *alphaKeyboardButtonRightConstraint = [NSLayoutConstraint constraintWithItem:alpha
                                                                                          attribute:NSLayoutAttributeRight
                                                                                          relatedBy:NSLayoutRelationEqual
                                                                                             toItem:self.view
                                                                                          attribute:NSLayoutAttributeRight
                                                                                         multiplier:1.0 constant:0.0];
    
    [self.view addConstraint:alphaKeyboardButtonRightConstraint];
    
    // Bottom constraint
    NSLayoutConstraint *alphaKeyboardButtonBottomConstraint = [NSLayoutConstraint constraintWithItem:alpha
                                                                                           attribute:NSLayoutAttributeBottom
                                                                                           relatedBy:NSLayoutRelationEqual
                                                                                              toItem:self.view
                                                                                           attribute:NSLayoutAttributeBottom
                                                                                          multiplier:1.0 constant:0.0];
    
    [self.view addConstraint:alphaKeyboardButtonBottomConstraint];
    
    // Width constraint
    NSLayoutConstraint *alphaKeyboardButtonTopConstraint = [NSLayoutConstraint constraintWithItem:alpha
                                                                                        attribute:NSLayoutAttributeHeight
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:self.view
                                                                                        attribute:NSLayoutAttributeHeight
                                                                                       multiplier:0.83 constant:0.0];
    
    [self.view addConstraint:alphaKeyboardButtonTopConstraint];
}

- (void) addPredictionBar
{
    Alpha* view = nil;
    for (UIView *subUIView in self.view.subviews) {
        if ([subUIView isKindOfClass:[Alpha class]])
        {
            Alpha* tmp = (Alpha*)subUIView;
            // Check if we found the proper button
            BOOL properView = (tmp.tag == kAlpha);
            if (properView == YES)
            {
                view = tmp;
                break;
            }
        }
    }
    
    // Add prediction layout
    bar = [[PredictiveBar alloc] init];
    
    // Register input selection callback
    bar.delegate = self;
    
    // Set a unique tag
    bar.tag = kPredBar;
    [self.view addSubview:bar];
    
    // Add size constraints
    bar.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Left constraint
    NSLayoutConstraint *alphaKeyboardButtonLeftConstraint = [NSLayoutConstraint constraintWithItem:bar
                                                                                         attribute:NSLayoutAttributeLeft
                                                                                         relatedBy:NSLayoutRelationEqual
                                                                                            toItem:self.view
                                                                                         attribute:NSLayoutAttributeLeft
                                                                                        multiplier:1.0 constant:0.0];
    
    [self.view addConstraint:alphaKeyboardButtonLeftConstraint];
    
    // Right constraint
    NSLayoutConstraint *alphaKeyboardButtonRightConstraint = [NSLayoutConstraint constraintWithItem:bar
                                                                                          attribute:NSLayoutAttributeRight
                                                                                          relatedBy:NSLayoutRelationEqual
                                                                                             toItem:self.view
                                                                                          attribute:NSLayoutAttributeRight
                                                                                         multiplier:1.0 constant:0.0];
    
    [self.view addConstraint:alphaKeyboardButtonRightConstraint];
    
    // Bottom constraint
    NSLayoutConstraint *alphaKeyboardButtonBottomConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                                           attribute:NSLayoutAttributeTop
                                                                                           relatedBy:NSLayoutRelationEqual
                                                                                              toItem:bar
                                                                                           attribute:NSLayoutAttributeBottom
                                                                                          multiplier:1.0 constant:0.0];
    
    [self.view addConstraint:alphaKeyboardButtonBottomConstraint];
    
    // Top constraint
    NSLayoutConstraint *alphaKeyboardButtonTopConstraint = [NSLayoutConstraint constraintWithItem:bar
                                                                                        attribute:NSLayoutAttributeTop
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:self.view
                                                                                        attribute:NSLayoutAttributeTop
                                                                                       multiplier:1.0 constant:0.0];
    
    [self.view addConstraint:alphaKeyboardButtonTopConstraint];
}

-(void)updatePredictionInput
{
    // Update prediction input
    NSRange a = [currentWord rangeOfString:@" " options:NSBackwardsSearch];
    NSRange b = [currentWord rangeOfString:@"\n" options:NSBackwardsSearch];
    
    // Last word
    NSString* word = @"";
    
    if (a.location != NSNotFound && b.location != NSNotFound)
    {
        if (a.location < b.location)
            word = [NSString stringWithString:[currentWord substringFromIndex:b.location + 1]];
        else
            word = [NSString stringWithString:[currentWord substringFromIndex:a.location + 1]];
    }
    else if (a.location != NSNotFound)
    {
        word = [NSString stringWithString:[currentWord substringFromIndex:a.location + 1]];
    }
    else if(b.location != NSNotFound)
    {
        word = [NSString stringWithString:[currentWord substringFromIndex:b.location + 1]];
    }
    else
        word = [NSString stringWithString:currentWord];
    
    // Update prediction input
    [bar updateInputText:word];
}

#pragma mark AlphaInputDelegate

- (void) alphaSpecialKeyInputDelegateMethod:(NSInteger)tag
{
    if (tag == kAlphaGlobeButton)
        [self advanceToNextInputMode];
}

- (void) alphaInputDelegateMethod: (NSString *) key
{
    // Insert typed text
    [self.textDocumentProxy insertText:key];
    
    // Update currently typed word
    currentWord = [NSString stringWithFormat:@"%@%@", currentWord, key];
    
    // Update prediction input
    [self updatePredictionInput];
}

- (void) alhpaInputRemoveCharacter
{
    // Update currently typed word
    if (currentWord.length != 0)
    {
        currentWord = [currentWord substringToIndex:[currentWord length] - 1];
        
        // Update prediction input
        [self updatePredictionInput];
    }
    
    // Remove a character
    [self.textDocumentProxy deleteBackward];
}

#pragma mark PredictiveBarDelegate

- (void) spellerInputDelegateMethod:(NSString *)key Word:(NSString*)word;
{
    // Remove last word
    for(size_t i = 0; i < word.length; ++i)
    {
        [self.textDocumentProxy deleteBackward];
    }
    currentWord = [currentWord substringToIndex:[currentWord length] - word.length];
    
    // Add option key and space at the end
    [self.textDocumentProxy insertText:[NSString stringWithFormat:@"%@ ", key]];
    currentWord = [NSString stringWithFormat:@"%@%@ ", currentWord, key];
    
    // Update predictive option
    [self updatePredictionInput];
}

@end
