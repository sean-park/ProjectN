//
//  ViewController.h
//  MrPill
//
//  Created by SungHyun Suh on 6/18/16.
//  Copyright © 2016 SungHyun Suh. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreBluetooth;

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate>


@end

