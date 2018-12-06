//
//  ViewController.m
//  IVoice
//
//  Created by Geeks_Chen on 2018/12/3.
//  Copyright © 2018年 Geeks_Chen. All rights reserved.
//

#import "ViewController.h"
#import <iflyMSC/iflyMSC.h>
#import "ISRDataHelper.h"
#import "IATConfig.h"
#import "LCVoice.h"
#import "UIColor+GC.h"
#import "UIImage+GC.h"

@interface ViewController ()<IFlySpeechSynthesizerDelegate,IFlySpeechRecognizerDelegate>

@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;//不带界面的识别对象
@property (nonatomic, strong) LCVoice * voice;
@property (strong, nonatomic) UIButton *collectVoiceBtn;
@property (strong, nonatomic) UITextView *contentLabel;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage gc_createImageWithColor:[UIColor gc_colorWithHexString:@"#FFFFFF"]] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage gc_createImageWithColor:[UIColor gc_colorWithHexString:@"#FFFFFF"]]];
    
    self.navigationController.navigationBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0, 5);
    self.navigationController.navigationBar.layer.shadowOpacity = 0.1;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.title = @"iVoice";
    
    [self setUpContentView];
    
    [self setUpVoiceView];

    [self setUpBottomView];
    
}

- (void)setUpContentView{
    
    self.contentLabel = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, self.view.frame.size.height - 100 - 100)];
    self.contentLabel.backgroundColor = [UIColor gc_colorWithHexString:@"#f8f8f8"];
    self.contentLabel.font = [UIFont fontWithName:@"Heiti SC" size:20];
    self.contentLabel.textColor = [UIColor gc_colorWithHexString:@"#4a4a4a"];
    self.contentLabel.userInteractionEnabled = NO;
    self.contentLabel.text = @"您可以按住底部按钮,开始讲话.当前版本支持粤语、普通话、河南话、英文";
    self.contentLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.contentLabel];
    
}

- (void)setUpVoiceView{
    
    self.voice = [[LCVoice alloc] init];
}

- (void)setUpBottomView{
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 100 - 64, self.view.frame.size.width, 100)];
    bottomView.backgroundColor = [UIColor redColor];
    [self.view addSubview:bottomView];
    
    //绘制圆角 要设置的圆角 使用“|”来组合
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bottomView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    //设置大小
    maskLayer.frame = bottomView.bounds;
    //设置图形样子
    maskLayer.path = maskPath.CGPath;
    bottomView.layer.mask = maskLayer;
    
    UIButton *collectVoiceBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [collectVoiceBtn setTitle:@"按住讲话" forState:(UIControlStateNormal)];
    [collectVoiceBtn setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
    [collectVoiceBtn setBackgroundColor:[UIColor whiteColor]];
    collectVoiceBtn.frame = CGRectMake(10, 30,self.view.frame.size.width- 20,50);
    collectVoiceBtn.layer.masksToBounds = YES;
    collectVoiceBtn.layer.cornerRadius = 25;
    
    // Set record start action for UIControlEventTouchDown
    [collectVoiceBtn addTarget:self action:@selector(recordStart) forControlEvents:UIControlEventTouchDown];
    // Set record end action for UIControlEventTouchUpInside
    [collectVoiceBtn addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchUpInside];
    // Set record cancel action for UIControlEventTouchUpOutside
    [collectVoiceBtn addTarget:self action:@selector(recordCancel) forControlEvents:UIControlEventTouchUpOutside];
    
    [bottomView addSubview:collectVoiceBtn];
    self.collectVoiceBtn = collectVoiceBtn;
    
}
-(void)initIfly{
    
    //单例模式，无UI的实例
    if (_iFlySpeechRecognizer == nil) {
        _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
        
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        
        //设置听写模式
        [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    }
    _iFlySpeechRecognizer.delegate = self;
    
    if (_iFlySpeechRecognizer != nil) {
        IATConfig *instance = [IATConfig sharedInstance];
        //设置最长录音时间
        [_iFlySpeechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        //设置后端点
        [_iFlySpeechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
        //设置前端点
        [_iFlySpeechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
        //网络等待时间
        [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
        
        //设置采样率，推荐使用16K
        [_iFlySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
        
        if ([instance.language isEqualToString:[IATConfig chinese]]) {
            //设置语言
            [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            //设置方言
            [_iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
        }else if ([instance.language isEqualToString:[IATConfig english]]) {
            [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
        }
        //设置是否返回标点符号
        [_iFlySpeechRecognizer setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
    }
    
}
#pragma mark -- 无界面的语音合成代理方法
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast{
    
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [results objectAtIndex:0];
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
    NSString * resu = [ISRDataHelper stringFromJson:result];
    self.contentLabel.text = [NSString stringWithFormat:@"%@%@",self.contentLabel.text,resu];
    NSLog(@"=====%@",self.contentLabel.text);
    
}

#pragma mark - ControlEvents
-(void) recordStart
{
    [self.voice startRecordWithPath:[NSString stringWithFormat:@"%@/Documents/MySound.caf", NSHomeDirectory()]];
    
    [self.collectVoiceBtn setTitle:@"正在讲话" forState:(UIControlStateNormal)];

    [self startVoiceToTxt];
}

-(void) recordEnd
{
    [self.collectVoiceBtn setTitle:@"正在合成" forState:(UIControlStateNormal)];

    [self.voice stopRecordWithCompletionBlock:^{

        [self.collectVoiceBtn setTitle:@"按住讲话" forState:(UIControlStateNormal)];

        [_iFlySpeechRecognizer stopListening];
    }];
}

-(void) recordCancel
{
    [self.collectVoiceBtn setTitle:@"按住讲话" forState:(UIControlStateNormal)];

    [self.voice cancelled];
}
#pragma mark 语音转文字
- (void)startVoiceToTxt{
    
    self.contentLabel.text = nil;
    
    if(_iFlySpeechRecognizer == nil)
    {
        [self initIfly];
    }
    
    [_iFlySpeechRecognizer cancel];
    
    //设置音频来源为麦克风
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    
    //设置听写结果格式为json
    [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    
    //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
    [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    
    [_iFlySpeechRecognizer setDelegate:self];
    
    BOOL ret = [_iFlySpeechRecognizer startListening];
    if (ret) {
        NSLog(@"startListening");
    }else{
        NSLog(@"失败");
    }
}

@end
