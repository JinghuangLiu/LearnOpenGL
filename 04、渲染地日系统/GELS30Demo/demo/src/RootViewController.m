//
//  RootViewController.m
//  ECoreEngineDemo
//
//  Created by migu on 2022/2/7.
//

#import "RootViewController.h"
#import "GLESDemoController.h"

#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@interface RootViewController ()
{
    UISwitch* _switchCam;
    UISwitch* _switchMic;
    UISwitch* _switchAlbum;
}

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect bounds = self.view.bounds;
    
    float top = (bounds.size.height - 300) / 2;
    float padding = 20;
    float margin = 10;
    float separator = (bounds.size.width-2*padding) * 0.8f;
    
    UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(padding, top, bounds.size.width-2*padding, 40)];
    title.font = [UIFont systemFontOfSize:22];
    title.text = @"需要下列授权：";
    title.textColor = [UIColor systemBlueColor];
    title.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:title];
    top += 40;
    top += margin;
    
    {
        UILabel* titleCamera = [[UILabel alloc] initWithFrame:CGRectMake(padding, top, separator, 30)];
        titleCamera.textColor = [UIColor systemBlueColor];
        titleCamera.font = [UIFont systemFontOfSize:18];
        titleCamera.text = @"摄像头";
        titleCamera.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:titleCamera];
        
        _switchCam = [[UISwitch alloc] initWithFrame:CGRectMake(padding + separator, top, 60, 30)];
        [_switchCam addTarget:self action:@selector(onSwitchCamAction:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:_switchCam];
        
        top += 30;
        top += margin;
    }
    
    {
        UILabel* titleMic = [[UILabel alloc] initWithFrame:CGRectMake(padding, top, separator, 30)];
        titleMic.textColor = [UIColor systemBlueColor];
        titleMic.font = [UIFont systemFontOfSize:18];
        titleMic.text = @"麦克风";
        titleMic.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:titleMic];
        
        _switchMic = [[UISwitch alloc] initWithFrame:CGRectMake(padding + separator, top, 60, 30)];
        [_switchMic addTarget:self action:@selector(onSwitchMicAction:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:_switchMic];
        
        top += 30;
        top += margin;
    }
    
    {
        UILabel* titleAlbum = [[UILabel alloc] initWithFrame:CGRectMake(padding, top, separator, 30)];
        titleAlbum.textColor = [UIColor systemBlueColor];
        titleAlbum.font = [UIFont systemFontOfSize:18];
        titleAlbum.text = @"相册";
        titleAlbum.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:titleAlbum];
        
        _switchAlbum = [[UISwitch alloc] initWithFrame:CGRectMake(padding + separator, top, 60, 30)];
        [_switchAlbum addTarget:self action:@selector(onSwitchAlbumAction:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:_switchAlbum];
        
        top += 30;
        top += margin;
    }
    
    top += 2*margin;
    
    UIButton* startup = [UIButton buttonWithType: UIButtonTypeSystem];
    startup.frame = CGRectMake((bounds.size.width-120)/2, top, 120, 50);
    startup.backgroundColor = [UIColor systemGreenColor];
    startup.titleLabel.font = [UIFont systemFontOfSize:22];
    [startup setTitle:@"开始" forState:UIControlStateNormal];
    [startup setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [startup addTarget:self action:@selector(onStartupAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startup];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self refreshRequiredPermissions];
}

- (void) refreshRequiredPermissions
{
    AVAuthorizationStatus statusCam = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    _switchCam.on = (statusCam == AVAuthorizationStatusAuthorized);
    
    AVAuthorizationStatus statusMic = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    _switchMic.on = (statusMic == AVAuthorizationStatusAuthorized);
    
    PHAuthorizationStatus statusAlbum = [PHPhotoLibrary authorizationStatus];
    _switchAlbum.on = (statusAlbum == PHAuthorizationStatusAuthorized);
}

- (void) onSwitchCamAction:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf performSelectorOnMainThread:@selector(refreshRequiredPermissions) withObject:nil waitUntilDone:false];
    }];
}

- (void) onSwitchMicAction:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf performSelectorOnMainThread:@selector(refreshRequiredPermissions) withObject:nil waitUntilDone:false];
    }];
}

- (void) onSwitchAlbumAction:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf performSelectorOnMainThread:@selector(refreshRequiredPermissions) withObject:nil waitUntilDone:false];
    }];
}

- (void) onStartupAction:(id)sender
{
    if(!(_switchCam.on && _switchMic.on && _switchAlbum.on))
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"程序需要所有权限" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    GLESDemoController *vc = [[GLESDemoController alloc] init];
    vc.title = @"GLES30";
    [self.navigationController pushViewController:vc animated:YES];
}

@end
