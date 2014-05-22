//
//  ViewController.h
//  OSCTutorial
//
//  Created by  dkobayashi on 2014/05/07.
//  Copyright (c) 2014年  dkobayashi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreMotion/CoreMotion.h"

@interface ViewController : UIViewController<UIAccelerometerDelegate>
{
}
@property (weak, nonatomic) IBOutlet UILabel *accelerDataXLabel;
@property (weak, nonatomic) IBOutlet UILabel *accelerDataYLabel;
@property (weak, nonatomic) IBOutlet UILabel *accelerDataZLabel;
@property (weak, nonatomic) IBOutlet UILabel *oscRecieveLabel;

@end
