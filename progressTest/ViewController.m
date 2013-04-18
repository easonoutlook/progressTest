//
//  ViewController.m
//  progressTest
//
//  Created by Hilen on 13-4-2.
//  Copyright (c) 2013年 lai. All rights reserved.
//

#import "ViewController.h"
#import "ASIHTTPRequest.h"
#import "ZipArchive.h"
#import "RegexKitLite.h"

#define documentsFolder	   [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define tempFolder	   [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/temp"]
#define cacheFolder [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"]

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    if (!networkQueue) {
        networkQueue = [[ASINetworkQueue alloc]init];
    }
    [networkQueue reset];
    [networkQueue setShowAccurateProgress:YES];
    [self download:nil];
    [networkQueue go];
    [self.progressBar setProgress:0];
	[self.view addSubview:self.progressBar];
}

- (IBAction)download:(id)sender {
    [self manageFile];
    ASIHTTPRequest *request;
    //NSString *url = @"http://upupyoyoyo.net/COFFdD0xMzY0OTEwNzg2Jmk9MTI0LjIwMi4xOTEuMjA1JnU9U29uZ3MvdjIvZmFpbnRRQy84ZS9kYS9lMzc2YzI5MmI3MjFiYzk0YjYyOWZkYTZlNjMwZGE4ZS5tcDMmbT04OTVmMGQ2NWY5NjJiMTBjYmZhMTJkYmJhZDRlYWM2NiZ2PWRvd24mbj3B+r7tt+cmcz3W3L3cwtcmcD1u.mp3";
    NSString *url = @"http://ftp.luoo.net/radio/radio198/03.mp3?&key=BB9B221DBA457DF7A2B5D4EBE65180D2";
    request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    NSString *filename = [self getFileName:url];
    NSString *savePath = [cacheFolder stringByAppendingPathComponent:filename];
	NSString *tempPath = [tempFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.temp",filename]];
    [request setDownloadDestinationPath:savePath];      //下载路径
    [request setTemporaryFileDownloadPath:tempPath];    //临时路径
    [request setUserInfo:[NSDictionary dictionaryWithObject:filename forKey:@"name"]];  //设置基本信息
    [request setAllowResumeForFileDownloads:_switchTest.isOn];//支持断点下载
    [request setDownloadProgressDelegate:self.progressBar];   //设置下载进度条
    [request setDelegate:self];                     //设置代理
    [request setDownloadProgressDelegate:self]; 	//设置进度条代理
    [networkQueue addOperation:request];
}

- (IBAction)stop:(id)sender {
    for (ASIHTTPRequest *request in [networkQueue operations]) {
        [request clearDelegatesAndCancel];
        [request setDelegate: nil];
        [request setDidFinishSelector: nil];
	}
}

- (void)unzipFile{
	NSString *filePath = [cacheFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"book.zip"]];
	NSString *unZipPath = [cacheFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"book"]];
	ZipArchive *unzip = [[ZipArchive alloc] init];
	if ([unzip UnzipOpenFile:filePath]) {
		BOOL result = [unzip UnzipFileTo:unZipPath overWrite:YES];//解压文件
		if (!result) {
			NSLog(@"解压成功");
		}else {
			NSLog(@"解压失败");
		}
		[unzip UnzipCloseFile];//关闭
	}
    [unzip release]; unzip = nil;

}

#pragma mark -
#pragma mark --ASIHTTPRequestDelegate method--
//下载之前获取信息的方法,主要获取下载内容的大小
-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
    NSLog(@"下载之前获取信息-资源的大小：%f mb",request.contentLength/1024.0/1024.0);
    contentLengthOfFile = request.contentLength/1024.0/1024.0;
}

//下载完成
-(void)requestFinished:(ASIHTTPRequest *)request{
    NSLog(@"下载完成:%@",cacheFolder);
}

//下载失败
- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"下载失败:%@",cacheFolder);
}

#pragma mark -
#pragma mark --ASIProgressDelegate method--
- (void)setProgress:(float)newProgress {//进度条的代理
    NSLog(@"走进度--%f/%fM",contentLengthOfFile*newProgress,contentLengthOfFile);
    _progressBar.progress = newProgress;
    _percent.text=[NSString stringWithFormat:@"%0.f%%",newProgress*100];
}

- (TKProgressBarView *) progressBar{
	if(_progressBar) return _progressBar;
	_progressBar = [[TKProgressBarView alloc] initWithStyle:TKProgressBarViewStyleLong];
	_progressBar.center = CGPointMake(self.view.bounds.size.width/2, 150);
	return _progressBar;
}


//创建文件夹
-(void)manageFile{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:cacheFolder] || ![fileManager fileExistsAtPath:tempFolder]) {
        NSError *error;
        [fileManager createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error];
        
        NSError *error2 = nil;
        [fileManager createDirectoryAtPath:tempFolder withIntermediateDirectories:YES attributes:nil error:&error2];
    }
}

//获取文件名
- (NSString *)getFileName:(NSString *)url{
    NSString *name = [url lastPathComponent];
    return name;
}

//获取文件类型
- (NSString *)getFileType:(NSString *)url{
    NSString *type = [url pathExtension];
    if ([type rangeOfString:@"?" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        NSArray *urlArray = [type componentsSeparatedByString:@"?"];
        type = [NSString stringWithFormat:@"%@",[urlArray objectAtIndex:[urlArray count]-1]];
    }
    return type;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_percent release];
    [networkQueue reset];
    [_switchTest release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setPercent:nil];
    [self setSwitchTest:nil];
    [super viewDidUnload];
}

@end
