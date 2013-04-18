//
//  ViewController.h
//  progressTest
//
//  Created by Hilen on 13-4-2.
//  Copyright (c) 2013年 lai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASINetworkQueue.h"
#import "TKProgressBarView.h"

@interface ViewController : UIViewController<ASIHTTPRequestDelegate,ASIProgressDelegate>{
	ASINetworkQueue *networkQueue;
	float contentLengthOfFile;

}
@property (nonatomic,strong) TKProgressBarView *progressBar;
@property (retain, nonatomic) IBOutlet UILabel *percent;
- (IBAction)download:(id)sender;
- (IBAction)stop:(id)sender;

@property (retain, nonatomic) IBOutlet UISwitch *switchTest;

@end
