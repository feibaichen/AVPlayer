//原文地址:https://www.jianshu.com/p/c8033bba1b60

本文主要列举并介绍AVPlayer在播放音频时所用到的接口。

#1.AVPlayer的初始化
```
NSURL* url = [[NSURL alloc] initFileURLWithPath:@"/Users/ben_gao/Desktop/1.mp3"];

//方法一、通过url进行初始化
self.player = [[AVPlayer alloc] initWithURL:url];
self.player = [AVPlayer playerWithURL:url];
            
//方法二、通过AVPlayerItem进行初始化
AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
self.player = [AVPlayer playerWithPlayerItem:item];
self.player = [[AVPlayer alloc] initWithPlayerItem:item];
```

#2.播放、暂停、快进
通过rate属性来判断当前是否处于播放状态，rate为0，停止播放，rate>0，
```
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

//快进（从10s开始进行播放）
double nextTime = 10;
[self.player seekToTime:CMTimeMakeWithSeconds(nextTime, NSEC_PER_SEC)];

```
#3.监听播放进度
通过设定一个时间来轮询监听播放进度

```
//每隔1秒执行一次代码块
CMTime tm = CMTimeMakeWithSeconds(1, NSEC_PER_SEC);
__weak typeof(self) weakSelf = self;
[self.player addPeriodicTimeObserverForInterval:tm queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
//获取当前播放时间
double currentTime = CMTimeGetSeconds(weakSelf.player.currentTime);
}];
```
#4.“鸡肋”的KVO监听事件
使用AVPlayer不支持类型的音频初始化AVplayer后，其状态仍然是“AVPlayerStatusReadyToPlay”状态，它不会跳转到“AVPlayerStatusFailed”状态。
```
//添加状态改变监听
[self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];

//相对应代码
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
```
#5.额外福利1-AVPlayer不支持的音频格式
从官方文档上并没有找到相关内容，因此我花了大量时间搜集不同的音频文件，测试结果如下表格。
|音频类型|是否支持|
|-|-|
|.mp3|支持|
|.m4a|支持|
|.wav|支持|
|.flac|支持|
|.m4r|支持|
|.wma|不支持|
|.midi|不支持|
|.ogg|不支持|

#6.额外福利2-AVPlayer Demo地址
通过上述的接口，我实现了一个及其简易的播放器，可实现快进功能。
https://github.com/gaoxiaodiao/AVPlayer.git
