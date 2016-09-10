//
//  GCVoiceViewController.m
//  GCVoice
//
//  Created by 陈潇 on 16/9/10.
//  Copyright © 2016年 Geeks_Chen. All rights reserved.
//

#import "GCVoiceViewController.h"

typedef NS_OPTIONS(NSInteger, SynthesizeType) {
    NomalType           = 5,//普通合成
    UriType             = 6, //uri合成
};


@interface GCVoiceViewController ()<IFlyRecognizerViewDelegate,IFlySpeechSynthesizerDelegate,IFlySpeechRecognizerDelegate>

@property (nonatomic, strong) IFlyRecognizerView *iflyRecognizerView;//带界面的识别对象
@property (nonatomic, strong) IFlySpeechSynthesizer * iFlySpeechSynthesizer;//语音合成对象
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;//不带界面的识别对象


@property (nonatomic, strong) PcmPlayer *audioPlayer;//用于播放音频的
@property (nonatomic, assign) SynthesizeType synType;//是何种合成方式
@property (nonatomic, assign) BOOL hasError;//将诶西过程中是否出现错误


@property (nonatomic,strong)UITextView *textView;
@property (nonatomic,strong)UILabel *label;
@property (nonatomic,strong)UIView *bottomView;


@end

@implementation GCVoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"科大讯飞测试";
 
    [self setUpUI];
    
#pragma mark ------ 进行有界面的语音识别的初始化
    _iflyRecognizerView = [[IFlyRecognizerView alloc] initWithCenter:self.view.center];
    _iflyRecognizerView.delegate = self;
    [_iflyRecognizerView setParameter: @"iat" forKey: [IFlySpeechConstant IFLY_DOMAIN]];
    //asr_audio_path保存录音文件名，如不再需要，设置value为nil表示取消，默认目录是documents
    [_iflyRecognizerView setParameter:@"asrview.pcm " forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
#pragma mark ------ 进行无界面的语音识别的初始化
    [self initRecognizer];

#pragma mark ------进行语音合成对象的初始化
    [self initMakeVoice];
    
}
#pragma mark -- UI搭建
-(void)setUpUI{

    //上部分
    UIView *topView = [[UIView alloc]init];
    topView.backgroundColor = [UIColor redColor];
    [self.view addSubview:topView];
    
    UILabel *yytx = [[UILabel alloc]init];
    yytx.backgroundColor = [UIColor yellowColor];
    yytx.textAlignment = ALIGN_CENTER;
    yytx.text = @"语音听写";
    [topView addSubview:yytx];
    
    //文本框
    UITextView *textView = [[UITextView alloc]init];
    textView.backgroundColor = [UIColor whiteColor];
    [topView addSubview:textView];
    self.textView = textView;
    
    //按钮
    UIButton *btn1 = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btn1.backgroundColor = [UIColor greenColor];
    [btn1 setTitle:@"语音听写" forState:(UIControlStateNormal)];
    [btn1 addTarget:self action:@selector(btn1) forControlEvents:(UIControlEventTouchUpInside)];
    [topView addSubview:btn1];
    
    //下部分
    self.bottomView = [[UIView alloc]init];
    self.bottomView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.bottomView ];
    
    UILabel *yyhc = [[UILabel alloc]init];
    yyhc.backgroundColor = [UIColor redColor];
    yyhc.text = @"语音识别";
    yyhc.textAlignment = ALIGN_CENTER;
    [self.bottomView addSubview:yyhc];
    
    //展示label
    self.label = [[UILabel alloc]init];
    self.label.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.label];
    
    //按钮
    UIButton *btn2 = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btn2.backgroundColor = [UIColor greenColor];
    [btn2 addTarget:self action:@selector(btn2)  forControlEvents:(UIControlEventTouchUpInside)];
    [btn2 setTitle:@"语音合成有界面" forState:(UIControlStateNormal)];
    [self.bottomView addSubview:btn2];
    
    //按钮
    UIButton *btn3 = [UIButton buttonWithType:(UIButtonTypeCustom)];
    btn3.backgroundColor = [UIColor greenColor];
    [btn3 addTarget:self action:@selector(btn3)  forControlEvents:(UIControlEventTouchUpInside)];
    [btn3 setTitle:@"语音合成无界面" forState:(UIControlStateNormal)];
    [self.bottomView addSubview:btn3];
    
    
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(self.view.mas_height).multipliedBy(0.5);
    }];
    
    [yytx mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.topMargin.mas_equalTo(64);
        make.height.mas_equalTo(30);
    }];
    
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(yytx);
        make.top.mas_equalTo(yytx.mas_bottom);
        make.width.mas_equalTo(topView.mas_width).multipliedBy(0.7);
        make.bottom.mas_equalTo(topView);
    }];
    
    [btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(yytx);
        make.top.mas_equalTo(yytx.mas_bottom);
        make.bottom.mas_equalTo(topView);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topView.mas_bottom);
        make.leading.equalTo(topView);
        make.width.and.height.equalTo(topView);
    }];
    
    [yyhc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.bottomView);
        make.height.mas_equalTo(30);
    }];
    
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView);
        make.top.equalTo(yyhc.mas_bottom);
        make.width.equalTo(@150);
        make.height.equalTo(@100);
    }];
    
    [btn3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView);
        make.top.equalTo(yyhc.mas_bottom);
        make.width.equalTo(@150);
        make.height.equalTo(@100);
    }];
    
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.top.mas_equalTo(yyhc.mas_bottom);
        make.height.equalTo(@40);
    }];

}
#pragma mark --- 语音听写
-(void)btn1{
    NSLog(@"语音听写");
    
    if ([self.textView.text isEqualToString:@""]) {        return;
    }
    
    if (_audioPlayer != nil && _audioPlayer.isPlaying == YES) {
        [_audioPlayer stop];
    }
    
    _synType = NomalType;
    
    self.hasError = NO;
    [NSThread sleepForTimeInterval:0.05];
    _iFlySpeechSynthesizer.delegate = self;
    [_iFlySpeechSynthesizer startSpeaking:self.textView.text];

}
-(void)initMakeVoice{
    
    TTSConfig *instance = [TTSConfig sharedInstance];
    if (instance == nil) {
        return;
    }
    //合成服务单例
    if (_iFlySpeechSynthesizer == nil) {
        _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    }
    
    _iFlySpeechSynthesizer.delegate = self;
    
    //设置语速1-100
    [_iFlySpeechSynthesizer setParameter:instance.speed forKey:[IFlySpeechConstant SPEED]];
    
    //设置音量1-100
    [_iFlySpeechSynthesizer setParameter:instance.volume forKey:[IFlySpeechConstant VOLUME]];
    
    //设置音调1-100
    [_iFlySpeechSynthesizer setParameter:instance.pitch forKey:[IFlySpeechConstant PITCH]];
    
    //设置采样率
    [_iFlySpeechSynthesizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
    
    //设置发音人
    [_iFlySpeechSynthesizer setParameter:instance.vcnName forKey:[IFlySpeechConstant VOICE_NAME]];
    
}
#pragma mark --- 语音识别有界面
-(void)btn2{
    NSLog(@"语音识别");
    
    //启动识别服务
    [_iflyRecognizerView start];
    
}
#pragma mark -- 有界面的语音合成代理方法
- (void)onResult: (NSArray *)resultArray isLast:(BOOL) isLast
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
    NSString * resu = [ISRDataHelper stringFromJson:result];
    self.label.text = [NSString stringWithFormat:@"%@%@",self.label.text,resu];
    NSLog(@"----%@",self.label.text);
}
/*识别会话错误返回代理
 @ param  error 错误码
 */
- (void)onError: (IFlySpeechError *) error
{
    NSLog(@"------%@",error.errorDesc);
}
#pragma mark --- 语音合成无界面
-(void)btn3{
    NSLog(@"语音合成无界面");
    
    if(_iFlySpeechRecognizer == nil)
    {
        [self initRecognizer];
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
        NSLog(@"合成成功");
    }else{
        NSLog(@"合成失败");
    }
 
    
}
-(void)initRecognizer{
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
    self.label.text = [NSString stringWithFormat:@"%@%@",self.label.text,resu];
    NSLog(@"=====%@",self.label.text);
    
}

@end
