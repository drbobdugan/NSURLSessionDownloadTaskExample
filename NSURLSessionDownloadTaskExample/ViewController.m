//
//  ViewController.m
//  NSURLSessionDownloadTaskExample
//
//  Created by Bob Dugan on 10/16/15.
//  Copyright © 2015 Bob Dugan. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "BackgroundTimeRemainingUtility.h"

@interface ViewController ()

@end

@implementation ViewController 

//
// From UIViewController
//
- (void)viewDidLoad {
    [super viewDidLoad];
}

//
// From UIViewController
//
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//
// From UIViewController
//
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

//
// Start Button UI event handler
//
- (IBAction)buttonPressed:(id)sender
{
    static Boolean first=TRUE;
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Initialize start time to compute duration later
    _startTime = [NSDate date];
    
    // Initialize UI fields
    self.state.text = @"Downloading";
    self.time.text = @"0";
    self.downloadPercentage.text = @"0";
    
    // Execute this initialization code one time only
    if (first)
    {
        first = FALSE;
        
        // Initialize session by constructing a NSURLSessionConfiguration
        NSURLSessionConfiguration *configuration =  [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"stonehill.edu.NSURLSessionDownloadTaskExample"];
        
        configuration.allowsCellularAccess = NO;
        configuration.timeoutIntervalForRequest = 30.0;
        configuration.timeoutIntervalForResource = 60.0;
        configuration.HTTPMaximumConnectionsPerHost = 1;
        configuration.sessionSendsLaunchEvents = YES;
        configuration.discretionary = YES;
        
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
        
    // Start a download task for the file located in the UI URL text box using the newly configured session
    NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:self.URL.text]];
    [downloadTask resume];
}


//
// Delegate of NSURLSessionDownloadDelegate
//
// Method will be called periodically when application is in the foreground and then it MAY be called
// a few times once the application is moved to the background.  Once the application is in the background
// a good way to get feedback about the progress of the download task is to use a proxy on your desktop
// and a packet sniffing tool like Wireshark.
//
//
-(void)URLSession:(NSURLSession *)session
     downloadTask:(NSURLSessionDownloadTask *)downloadTask
     didWriteData:(int64_t)bytesWritten
totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    // Compute progress percentage
    float progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    
    // Compute time executed so far
    NSDate *stopTime = [NSDate date];
    NSTimeInterval executionTime = [stopTime timeIntervalSinceDate:_startTime];
    
    // Send info to console
    NSLog(@"%s bytesWritten = %lld, totalBytesWritten: %lld, expectedTotalBytes: %lld, progress %.3f, time (s): %.1f", __PRETTY_FUNCTION__, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite, progress*100, executionTime);
    
    // Update UI
    dispatch_block_t work_to_do = ^{
        self.downloadPercentage.text = [NSString stringWithFormat:@"%.3f", progress*100];
        self.time.text = [NSString stringWithFormat:@"%.1f",executionTime];
    };
    
    if ([NSThread isMainThread])
    {
        work_to_do();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), work_to_do);
    }
        
    // If we are not in the "active" or foreground then log some background information to the console
    if (UIApplication.sharedApplication.applicationState != UIApplicationStateActive)
    {
        [BackgroundTimeRemainingUtility NSLog];
    }
}

//
// Delegate of NSURLSessionDelegate
//
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.backgroundCompletionHandler) {
        appDelegate.backgroundCompletionHandler();
        appDelegate.backgroundCompletionHandler = nil;
    }
}

//
// Delegate of NSURLSessionTaskDelegate
//
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (error) {
        NSLog(@"%@ failed: %@", task.originalRequest.URL, error);
    }
}

//
// Delegate of NSURLSessionDownloadDelegate
//
- (void)connectionDidResumeDownloading:(NSURLConnection *)connection
                     totalBytesWritten:(long long)totalBytesWritten
                    expectedTotalBytes:(long long)expectedTotalBytes
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [BackgroundTimeRemainingUtility NSLog];
}

//
// Delegate of NSURLSessionDownloadDelegate
//
-(void)        URLSession:(NSURLSession *)session
             downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)sourceURL
{
    // Prepare destination URL string
    NSArray *parts = [_URL.text componentsSeparatedByString:@"/"];
    NSString *filename = [parts lastObject];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    NSURL *destinationURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"file:///private/%@/%@", basePath, filename]];
    
    // Move file from downloadTask cache to destinationURL
    NSError *error;
    if ([[NSFileManager defaultManager] moveItemAtURL:sourceURL toURL:destinationURL error:&error])
    {
        NSLog(@"Error during file move to Documents folder... %@",[error localizedDescription]);
    }
    
    // Get current time & compute total execution time
    NSDate *stopTime = [NSDate date];
    NSTimeInterval executionTime = [stopTime timeIntervalSinceDate:_startTime];

    // Update UI
    dispatch_block_t work_to_do = ^{
        self.state.text = @"Done";
        self.downloadPercentage.text = [NSString stringWithFormat:@"%.3f", 100.0];
        self.time.text = [NSString stringWithFormat:@"%.1f",executionTime];
    };
    
    if ([NSThread isMainThread])
    {
        work_to_do();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), work_to_do);
    }
    
    
    // Log to console in case we are in background
    NSLog(@"%s download took %.1fs and finished moving item at %@ to %@", __PRETTY_FUNCTION__, executionTime, destinationURL, destinationURL);
    [BackgroundTimeRemainingUtility NSLog];
}
@end