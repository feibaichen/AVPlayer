//
//  ViewController.m
//  AVPlayer
//
//  Created by Ben Gao (RD-CN) on 22/8/2018.
//  Copyright © 2018 Ben Gao (RD-CN). All rights reserved.
//

#import "ViewController.h"

@interface ViewController()

@property (weak) IBOutlet NSSlider *slider;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.slider.maxValue = 1;
    self.slider.minValue = 0;
    self.slider.doubleValue = 0;
}

//播放
- (IBAction)btn_play:(NSButton *)sender {
    if(self.player.rate == 0.0){
        [self.player play];
        //self.player.rate = 1.0;   //正常播放，等同于play
        //self.player.rate = 2.0;   //二倍速播放
        
    }
}

//暂停
- (IBAction)btn_pause:(NSButton *)sender {
    if(self.player.rate != 0.0){
        [self.player pause];
        //self.player.rate = 0.0;   //等同于pause
        //self.player.rate = -1.0;  //一倍速反向播放
    }
}

- (IBAction)btn_load:(NSButton *)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        if(returnCode){
            NSURL *url =openPanel.URL;
            //NSURL* url = [[NSURL alloc] initFileURLWithPath:@"/Users/ben_gao/Desktop/1.mp3"];
            //方法一、通过url进行初始化
            self.player = [[AVPlayer alloc] initWithURL:url];
            //self.player = [AVPlayer playerWithURL:url];
            
            //方法二、通过AVPlayerItem进行初始化
            //AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
            //self.player = [AVPlayer playerWithPlayerItem:item];
            //self.player = [[AVPlayer alloc] initWithPlayerItem:item];
            
            //添加状态改变监听
            [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];

           
        }
    }];

}

- (IBAction)slider_clicked:(NSSlider *)sender {
    double tmp = sender.doubleValue;
     double duration = CMTimeGetSeconds(self.player.currentItem.duration);
    double nextTime = duration*tmp;
    [self.player seekToTime:CMTimeMakeWithSeconds(nextTime, NSEC_PER_SEC)];
}



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.player.status) {
            case AVPlayerStatusUnknown:
                NSLog(@"未知状态");
                break;
            case AVPlayerStatusReadyToPlay:{
                CMTime tm = CMTimeMakeWithSeconds(1, NSEC_PER_SEC);
                __weak typeof(self) weakSelf = self;
                [self.player addPeriodicTimeObserverForInterval:tm queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                    double currentTime = CMTimeGetSeconds(weakSelf.player.currentTime);
                    double duration = CMTimeGetSeconds(weakSelf.player.currentItem.duration);
                    weakSelf.slider.doubleValue = currentTime/duration;
                }];
                NSLog(@"准备播放");
                break;
            }
            case AVPlayerStatusFailed:
                NSLog(@"加载失败");
                break;
            default:
                break;
        }
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
