//
//  ViewController.m
//  OSCTutorial
//
//  Created by  dkobayashi on 2014/05/07.
//  Copyright (c) 2014年  dkobayashi. All rights reserved.
//

#import "ViewController.h"
#import "VVOSC/include/VVOSC.h"

@interface ViewController ()
@property(nonatomic, retain) CMMotionManager *motionManager;
@property(nonatomic, retain) OSCManager *oscManager;
@property(nonatomic, retain) OSCOutPort *outport;
@property(nonatomic, retain) OSCInPort *inport;


@end

@implementation ViewController

NSInteger v;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //周波数
    int frequency = 50;
    self.motionManager = [[CMMotionManager alloc] init];

    //OSC
    //Send 送信先IPとPORTを設定
    self.oscManager = [[OSCManager alloc] init];
    self.oscManager.delegate = self;
    self.outport = [self.oscManager createNewOutputToAddress:@"10.0.0.7" atPort:7777];
    
    //Receive 受信PORTを設定
    self.inport = [self.oscManager createNewInputForPort:6666];
    
    
    [self startCMAccelerometerData:frequency];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    if(self.motionManager.accelerometerActive){
        [self.motionManager stopAccelerometerUpdates];
    }
    
    self.motionManager = nil;
    
    self.accelerDataXLabel = nil;
    self.accelerDataYLabel = nil;
    self.accelerDataZLabel = nil;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark OSCRecive Delegate
//#OSC受信したら呼ばれるデリゲート
-(void)receivedOSCMessage:(OSCMessage *)m
{
    NSString *address = m.address;
    OSCValue *value = m.value;

    
    
    if([address isEqualToString:@"/receive"])
    {
        v = value.intValue;

        NSLog(@"%d", v);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.oscRecieveLabel.text = [NSString stringWithFormat:@"%d", v];
        });
        

    }
    self.oscRecieveLabel.text = @"test";
}

#pragma mark -
#pragma mark CoreMotion setup methods
//#OSC受信したら呼ばれるデリゲート 加速度センサーを
-(void)startCMAccelerometerData:(int)frequency
{
    if(self.motionManager.accelerometerAvailable){
        //更新間隔の指定
        self.motionManager.accelerometerUpdateInterval = 1/frequency;
        
        //ハンドラ
        CMAccelerometerHandler handler = ^(CMAccelerometerData *data, NSError *error){
            double degyz = -atan2(data.acceleration.y , data.acceleration.z) * 180.0 / M_PI;
            double degzx = atan2(data.acceleration.x , data.acceleration.z) * 180.0 / M_PI;
            double degyx = atan2(data.acceleration.y , data.acceleration.x) * 180.0 / M_PI;
            
            self.accelerDataXLabel.text = [NSString stringWithFormat:@"%lf", degyz];
            self.accelerDataYLabel.text = [NSString stringWithFormat:@"%lf", degzx];
            self.accelerDataZLabel.text = [NSString stringWithFormat:@"%lf", degyx];

            OSCMessage *message = [OSCMessage createWithAddress:@"/test"];
            [message addFloat:degyz];
            [message addFloat:degzx];
            [message addFloat:degyx];

            [self.outport sendThisPacket:[OSCPacket createWithContent:message]];
        };
        
        //センサーの利用開始
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:handler];
    }
}

@end
