//
//  RRPDFViewController.m
//  RSSReader
//
//  Created by rochefort on 2013/11/02.
//  Copyright (c) 2013年 rochefort. All rights reserved.
//

#import "RRPDFViewController.h"
#import "AFNetworking.h"
#import "ReaderViewController.h"

#import "ReaderMainToolbar.h"

@interface RRPDFViewController () <ReaderViewControllerDelegate>
{
    UIProgressView *progressBar;
    UILabel *percentLabel;
    ReaderViewController *readerViewController;
    RRDataManager *dataManager;
    
    NSString *pdfName;
    NSString *pdfPath;
}
@property (nonatomic) UIDocumentInteractionController *diController;
@property (nonatomic) UIImageView *captureView;

@end

NSString *const kBaseURL = @"https://developer.apple.com/jp/devcenter/ios/library/";

@implementation RRPDFViewController

- (void)viewDidLoad
{
    LOG_METHOD
    [super viewDidLoad];
    
    LOG(@"entity:%@", self.documentEntity)
    dataManager = [RRDataManager sharedManager];
    [self setupProgress];
    [self setupPdf];
    [self setupOpenIn];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)setupPdf
{
    if ([self isDownloaded]) {
        [self displayPdf];
    } else {
        [self downloadPdf];
    }
}

- (void)setupOpenIn
{
    self.captureView = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.captureView.hidden = YES;
    [self.view addSubview:self.captureView];
}

- (BOOL)isDownloaded
{
    NSString *dir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    if ([self.documentEntity.download_status intValue] != DocumentDownloadStatusDone) {
        return NO;
    }
    
    if ([[self.documentEntity sortedDownloads] count] == 0) {
        return NO;
    }
    
    DownloadEntity *download = [self.documentEntity sortedDownloads][0];
    pdfName = download.pdf_name;
    pdfPath = [dir stringByAppendingPathComponent:pdfName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    return [fileManager fileExistsAtPath:pdfPath];
}

- (void)displayPdf
{
    assert(pdfPath != nil);
    ReaderDocument *document = [ReaderDocument withDocumentFilePath:pdfPath password:nil];
    if (document) {
        readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
        readerViewController.delegate = self;
        readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        // Reader Customize
        // forward button
        FAKIcon *forwardIcon = [FAKFontAwesome shareSquareOIconWithSize:20];
        UIImage *fowardImage = [forwardIcon imageWithSize:CGSizeMake(40, 40)];
        UIButton *fowardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        fowardButton.frame = CGRectMake(45, 4, 40, 40);
        [fowardButton setImage:fowardImage forState:UIControlStateNormal];
        [fowardButton addTarget:self action:@selector(forwardPdf:) forControlEvents:UIControlEventTouchUpInside];
        
        // back button image
        FAKIcon *backIcon = [FAKIonIcons ios7ArrowBackIconWithSize:27];
        UIImage *backImage = [backIcon imageWithSize:CGSizeMake(40, 40)];
        for (UIView *view in readerViewController.view.subviews) {
            if ([view isKindOfClass:[ReaderMainToolbar class]]) {
                for (UIButton *subview in view.subviews) {
                    if ([subview isKindOfClass:[UIButton class]]) {
                        UIButton *button = (UIButton *)subview;
                        if ([button.titleLabel.text isEqualToString:@"Done"]) {
                            [button setImage:backImage forState:UIControlStateNormal];
                            [button setTitle:@"" forState:UIControlStateNormal];
                        }
                        [subview setBackgroundImage:nil forState:UIControlStateHighlighted];
                        [subview setBackgroundImage:nil forState:UIControlStateNormal];
                        [subview setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
                    }
                }
                [view addSubview:fowardButton];
            }
        }
        [self presentViewController:readerViewController animated:YES completion:NULL];
    }
}

- (void)downloadPdf
{
    LOG_METHOD
    NSURL *pdfURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseURL, self.documentEntity.link_jp]];
    NSURLRequest *request = [NSURLRequest requestWithURL:pdfURL];
    
    // PDFの保存場所
    NSString *dir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    pdfName = [pdfURL lastPathComponent];
    pdfPath = [dir stringByAppendingPathComponent:pdfName];
    __weak typeof(self) weakSelf = self;
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.outputStream = [NSOutputStream outputStreamToFileAtPath:pdfPath append:NO];
    [op setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        CGFloat percentDone = ((float)((int)totalBytesRead) / (float)((int)totalBytesExpectedToRead));
        [weakSelf showProgress:(CGFloat) percentDone];
        // LOG(@"Sent %lld of %lld bytes", totalBytesRead, totalBytesExpectedToRead);
    }];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [dataManager deleteOldDocuments:self.documentEntity];
        [weakSelf updateDocuments];
        [weakSelf hideProgress];
        [weakSelf displayPdf];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ネットワークエラー"
                                                        message:@"インターネットに接続してください"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }];
    [op start];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - CoreData

- (void)updateDocuments
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attrs = [fileManager attributesOfItemAtPath: pdfPath error: NULL];
    long long size = [attrs fileSize];
    
    NSDictionary *downloadDict = @{@"pdf_name":      pdfName,
                                   @"download_date": [NSDate date],
                                   @"size"           : @(size)
                                   };
    
    NSDictionary *documentDict = @{@"title_jp":        self.documentEntity.title_jp,
                                   @"status":          @(DocumentStatusUnread),
                                   @"status":          @(DocumentStatusUnread),
                                   @"download_status": @(DocumentDownloadStatusDone)
                                   };
    [dataManager replaceDocument:documentDict downloadDict:downloadDict];
}

#pragma mark - progress

- (void)setupProgress
{
    CGRect frame = self.view.frame;
    // progress bar
    CGFloat barWidth = frame.size.width * 0.7;
    CGFloat barY = frame.size.height * 0.45;
    progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progressBar.frame =CGRectMake((frame.size.width - barWidth) / 2, barY, barWidth, 2);
    progressBar.hidden = YES;
    [self.view addSubview:progressBar];
    
    // progress percentage
    CGFloat labelWidth = 60;
    CGFloat labelHeight = 40;
    CGFloat labelX = (frame.size.width - labelWidth) / 2;
    CGFloat labelY = progressBar.frame.origin.y - labelHeight;
    percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelWidth, labelHeight)];
    percentLabel.textAlignment = NSTextAlignmentRight;
    percentLabel.textColor = self.view.tintColor;
    percentLabel.font = [UIFont boldSystemFontOfSize:20];
    percentLabel.hidden = YES;
    [self.view addSubview:percentLabel];
}

- (void)showProgress:(CGFloat) percentDone
{
    progressBar.progress = percentDone;
    progressBar.hidden = NO;
    NSInteger percentage = (int)(percentDone * 100);
    percentLabel.hidden = (percentage == 0);
    percentLabel.text = [NSString stringWithFormat:@"%ld%%", (long)percentage];
}

- (void)hideProgress
{
    progressBar.hidden = YES;
    percentLabel.hidden = YES;
}

#pragma mark - Open In

- (void)forwardPdf:(id)sender
{
    LOG_METHOD
    assert(pdfPath != nil);
    [self showCaptureView];
    [self dismissViewControllerAnimated:NO completion:NULL];
    NSURL *url = [NSURL fileURLWithPath:pdfPath];
    if(!url) {
        return;
    }
    
    self.diController = [UIDocumentInteractionController interactionControllerWithURL:url];
    self.diController.delegate = self;
    [self.diController presentOptionsMenuFromRect:self.view.frame inView:self.view animated:YES];
}

- (void)showCaptureView
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, 0.0f);
    CGContextRef contexst = UIGraphicsGetCurrentContext();
    for (UIWindow *aWindow in [[UIApplication sharedApplication] windows]) {
        [aWindow.layer renderInContext:contexst];
    }
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.captureView.image = capturedImage;
    self.captureView.hidden = NO;
}

#pragma mark - ReaderViewControllerDelegate

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    LOG_METHOD
    [self dismissViewControllerAnimated:NO completion:NULL];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (void)documentInteractionControllerWillPresentOptionsMenu:(UIDocumentInteractionController *)controller
{
    LOG_METHOD
}

- (void)documentInteractionControllerDidDismissOptionsMenu:(UIDocumentInteractionController *)controller
{
    LOG_METHOD
    self.captureView.hidden = YES;
    self.captureView.image = nil;
    [self presentViewController:readerViewController animated:NO completion:NULL];
}

- (BOOL) documentInteractionController: (UIDocumentInteractionController *) controller canPerformAction: (SEL) action
{
    LOG_METHOD
    return NO;
}

- (BOOL)documentInteractionController:(UIDocumentInteractionController *)controller performAction:(SEL)action
{
    LOG_METHOD
    return YES;
}

@end
