
#import "SNCPreviewViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioServices.h>
#import "NMRangeSlider.h"


@interface SNCPreviewViewController ()

@property UIImageView* imageView;
@property UIButton* saveButton;
@property NMRangeSlider* soundSlider;

@end

@implementation SNCPreviewViewController
{
    AVAudioPlayer *audioPlayer;
}

- (CGRect) soundSliderFrame
{
    return CGRectMake(10.0, 500.0, 300.0, 20.0);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self initializeImageView];
    [self initializeSoundSlider];
    
    UIGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(play)];
    [self.view addGestureRecognizer:tapGesture];
    
    if(self.sonic != nil){
        [self configureViews];
    }
    
    UIBarButtonItem* rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone    target:self action:@selector(doneEdit)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
   
}

- (void) doneEdit
{
    [self.sonic sonicFromCroppingFrom:self.soundSlider.minimumValue to:self.soundSlider.maximumValue withCompletionHandler:^(Sonic *sonic, NSError *error) {
        if(sonic){
            SNCPreviewViewController* preview = [[SNCPreviewViewController alloc] init];
            [self.navigationController pushViewController:preview animated:YES];
            [preview setSonic:sonic];
        } else {
            NSLog(@"error: %@",error);
        }
    }];
}

- (void) initializeImageView
{
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 50.0 + self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.width)];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.imageView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.imageView.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    [self.imageView.layer setShadowOpacity:0.5];
    [self.imageView.layer setShadowRadius:5.0];
    [self.view addSubview:self.imageView];
}

- (void) initializeSoundSlider
{
    self.soundSlider = [[NMRangeSlider alloc] initWithFrame:[self soundSliderFrame]];
    [self.soundSlider setMinimumValue:0.0];
    [self.soundSlider setLowerValue:0.0];
    [self.soundSlider setUpperValue:1.0];
    [self.soundSlider setMaximumValue:1.0];
    [self.soundSlider setMinimumRange:1.0];
    [self.view addSubview:self.soundSlider];
}

- (void) play
{
    if(self.sonic != nil){
        [audioPlayer setVolume:1.0];
        audioPlayer.delegate = self;
        [audioPlayer play];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self play];
}

- (void) configureViews
{
    [self.imageView setImage:self.sonic.image];    [self.soundSlider setMaximumValue:audioPlayer.duration];
    [self.soundSlider setUpperValue:audioPlayer.duration];
    
}

- (void)setSonic:(Sonic *)sonic
{
    _sonic = sonic;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:NULL];
    audioPlayer = [[AVAudioPlayer alloc] initWithData:self.sonic.sound error:nil];
    if([self isViewLoaded]){
        [self configureViews];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
