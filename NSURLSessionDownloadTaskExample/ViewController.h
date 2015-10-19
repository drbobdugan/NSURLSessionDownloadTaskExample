//
//  ViewController.h
//  NSURLSessionDownloadTaskExample
//
//  Created by Bob Dugan on 10/16/15.
//  Copyright © 2015 Bob Dugan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSURLSessionDelegate, NSURLSessionTaskDelegate,
NSURLSessionDownloadDelegate, UITextFieldDelegate>

// State information
@property (nonatomic, weak) NSURLSession *session;
@property (nonatomic, strong) NSDate *startTime;

// Linked to UI components
@property (weak, nonatomic) IBOutlet UITextView *URL;
@property (weak, nonatomic) IBOutlet UILabel *state;
@property (weak, nonatomic) IBOutlet UILabel *downloadPercentage;
@property (weak, nonatomic) IBOutlet UILabel *time;
- (IBAction)buttonPressed:(id)sender;

@end

