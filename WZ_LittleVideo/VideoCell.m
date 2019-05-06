//
//  VideoCell.m
//  WZ_LittleVideo
//
//  Created by 赵鹏飞 on 2019/5/5.
//  Copyright © 2019 赵鹏飞. All rights reserved.
//

#import "VideoCell.h"

#import "AVPlayerView.h"
#import "CTMediaModel.h"

@interface VideoCell () <AVPlayerUpdateDelegate>

@property (nonatomic, strong) UIView                   *container;
@property (nonatomic, strong) CAGradientLayer          *gradientLayer;
@property (nonatomic, strong) UITapGestureRecognizer   *singleTapGesture;

@property (nonatomic, strong) CTMediaModel *videoModel;

@property (nonatomic, strong) UIView                   *playerStatusBar;


@end

@implementation VideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = RGBA(0, 0, 0, 0.1f);
        [self initlizeSubViews];
    }
    return self;
}

-(void)prepareForReuse {
    [super prepareForReuse];
    
    self.isPlayerReady = NO;
    [self.playerView cancelLoading];
    
//    self.coverImageView.hidden = NO;
    
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.gradientLayer.frame = CGRectMake(0, SCREEN_H-500, SCREEN_W, 500);
    [CATransaction commit];
}

#pragma mark AVPlayerUpdateDelegate
-(void)onProgressUpdate:(CGFloat)current total:(CGFloat)total {
    //播放进度更新
}
-(void)onPlayItemStatusUpdate:(AVPlayerItemStatus)status {
    switch (status) {
        case AVPlayerItemStatusUnknown:
            [self startLoadingPlayItemAnim:YES];
            break;
        case AVPlayerItemStatusReadyToPlay:
            [self startLoadingPlayItemAnim:NO];
            
            _isPlayerReady = YES;
//            [_musicAlum startAnimation:_aweme.rate];
//            self.coverImageView.hidden = YES;
            if(_onPlayerReady) {
                _onPlayerReady();
            }
            break;
        case AVPlayerItemStatusFailed:
            [self startLoadingPlayItemAnim:NO];
            NSLog(@"加载失败");
            break;
        default:
            break;
    }
}

//加载动画
-(void)startLoadingPlayItemAnim:(BOOL)isStart {
    if (isStart) {
        self.playerStatusBar.backgroundColor = [UIColor whiteColor];
        [self.playerStatusBar setHidden:NO];
        [self.playerStatusBar.layer removeAllAnimations];
        
        CAAnimationGroup *animationGroup = [[CAAnimationGroup alloc]init];
        animationGroup.duration = 0.5;
        animationGroup.beginTime = CACurrentMediaTime() + 0.5;
        animationGroup.repeatCount = MAXFLOAT;
        animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        CABasicAnimation * scaleAnimation = [CABasicAnimation animation];
        scaleAnimation.keyPath = @"transform.scale.x";
        scaleAnimation.fromValue = @(1.0f);
        scaleAnimation.toValue = @(1.0f * SCREEN_W);
        
        CABasicAnimation * alphaAnimation = [CABasicAnimation animation];
        alphaAnimation.keyPath = @"opacity";
        alphaAnimation.fromValue = @(1.0f);
        alphaAnimation.toValue = @(0.5f);
        [animationGroup setAnimations:@[scaleAnimation, alphaAnimation]];
        [self.playerStatusBar.layer addAnimation:animationGroup forKey:nil];
    } else {
        [self.playerStatusBar.layer removeAllAnimations];
        [self.playerStatusBar setHidden:YES];
    }
    
}

-(void)cellWithModel:(CTMediaModel *)model {
    //填充cell
    self.videoModel = model;
//    [self.coverImageView setImageWithURL:[NSURL URLWithString:self.videoModel.goodsLogo]];
}

#pragma mark 懒加载
-(AVPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [AVPlayerView new];
        _playerView.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H);
    }
    return _playerView;
}

-(UIView *)container {
    if (!_container) {
        _container = [UIView new];
        _container.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H);
    }
    return _container;
}

-(CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor, (__bridge id)RGBA(0, 0, 0, 0.2f).CGColor, (__bridge id)RGBA(0, 0, 0, 0.4f).CGColor];
        _gradientLayer.locations = @[@0.3, @0.6, @1.0];
        _gradientLayer.startPoint = CGPointMake(0.0f, 0.0f);
        _gradientLayer.endPoint = CGPointMake(0.0f, 1.0f);
    }
    return _gradientLayer;
}

-(UITapGestureRecognizer *)singleTapGesture {
    if (!_singleTapGesture) {
        _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    }
    return _singleTapGesture;
}

-(UIView *)playerStatusBar {
    if (!_playerStatusBar) {
        _playerStatusBar = [[UIView alloc]init];
        _playerStatusBar.backgroundColor = [UIColor whiteColor];
        [_playerStatusBar setHidden:YES];
    }
    return _playerStatusBar;
}

-(void)initlizeSubViews {
    
    self.playerView.delegate = self;
    [self.contentView addSubview:self.playerView];
    
    
    [self.contentView addSubview:self.container];
    
    
    [self.container.layer addSublayer:self.gradientLayer];
    
    [self.container addGestureRecognizer:self.singleTapGesture];
    

    [self.container addSubview:self.playerStatusBar];
    
    [self.playerStatusBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).inset(49.5f + SafeAreaBottomHeight);
        make.width.mas_equalTo(1.0f);
        make.height.mas_equalTo(0.5f);
    }];
}

- (void)handleGesture:(UITapGestureRecognizer *)sender {
    NSLog(@"需要手势操作");
}

- (void)play {
    [self.playerView play];
//    [_pauseIcon setHidden:YES];
}

- (void)pause {
    [self.playerView pause];
//    [_pauseIcon setHidden:NO];
}

- (void)replay {
    [self.playerView replay];
//    [_pauseIcon setHidden:YES];
}

- (void)startDownloadBackgroundTask {
    NSString *playUrl = self.videoModel.url;
    [self.playerView setPlayerWithUrl:playUrl];
}

- (void)startDownloadHighPriorityTask {
    NSString *playUrl = self.videoModel.url;
    [self.playerView startDownloadTask:[[NSURL alloc] initWithString:playUrl] isBackground:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
