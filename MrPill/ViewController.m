//
//  ViewController.m
//  MrPill
//
//  Created by SungHyun Suh on 6/18/16.
//  Copyright © 2016 SungHyun Suh. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

#define Arduino_UUID @"19810001-E8F2-537E-4F6C-D104768A1214";
@property (strong, nonatomic) IBOutlet UILabel *colorBox;
@property (strong, nonatomic) IBOutlet UIButton *colorSelectButton;
@property (strong, nonatomic) IBOutlet UIButton *send;
@property (strong, nonatomic) IBOutlet UITableView *colorList;
@property (strong, nonatomic) IBOutlet UIView *BLEConnect;
@property (strong, nonatomic) NSArray *colors;
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) NSString *UUID;
@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic *transferCharacteristic;
@property (strong, nonatomic) NSData *data;
@property (nonatomic, readwrite) NSInteger sendDataIndex;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.UUID = [[NSUUID UUID] UUIDString];
    self.colors = [NSArray arrayWithObjects:@"Red", @"Green", @"Blue", nil];
    //self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:self.UUID]]}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/***** BLE Peripheral *****/
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state != CBPeripheralManagerStatePoweredOn)
    {
        return;
    }
    
    if (peripheral.state == CBPeripheralManagerStatePoweredOn)
    {
        self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:self.UUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
        
        CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:self.UUID] primary:YES];
        
        transferService.characteristics = @[self.transferCharacteristic];
        
        [self.peripheralManager addService:transferService];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    //self.data = [_textView.text dataUsingEncoding:NSUTF8StringEncoding];
    
    self.sendDataIndex = 0;
    
    [self sendData];
}

- (void)sendData
{
    if ([self.colorBox.text isEqualToString:@"Red"])
    {
        NSLog(@"#FF0000");
        self.data = [@"#FF0000" dataUsingEncoding:NSUTF8StringEncoding];
    }
    else if ([self.colorBox.text isEqualToString:@"Green"])
    {
        NSLog(@"#00FF00");
        self.data = [@"#00FF00" dataUsingEncoding:NSUTF8StringEncoding];
    }
    else if ([self.colorBox.text isEqualToString:@"Blue"])
    {
        NSLog(@"#0000FF");
        self.data = [@"#0000FF" dataUsingEncoding:NSUTF8StringEncoding];
    }
    [self.peripheralManager updateValue:self.data forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    [self sendData];
}
/**************************/

/***** BLE Central Manager *****/
//- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
//{
//    NSLog(@"Connected");
//    
//    [self.centralManager stopScan];
//    NSLog(@"Scanning stopped");
//    
//    peripheral.delegate = self;
//    
//    [peripheral discoverServices:@[[CBUUID UUIDWithString:self.UUID]]];
//}
//
//- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
//{
//    NSLog(@"Discovered: %@ at %@", peripheral.name, RSSI);
//    if (self.peripheral != peripheral)
//    {
//        self.peripheral = peripheral;
//        NSLog(@"Connecting: %@", peripheral);
//        [self.centralManager connectPeripheral:peripheral options:nil];
//    }
//}
//
//- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
//{
//    NSLog(@"Failed to connect");
//    [self cleanup];
//}
//
//- (void)cleanup
//{
//    if (self.peripheral.services != nil)
//    {
//        for (CBService *service in self.peripheral.services)
//        {
//            if (service.characteristics != nil)
//            {
//                for (CBCharacteristic *characteristic in service.characteristics)
//                {
//                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:self.UUID]])
//                    {
//                        if (characteristic.isNotifying)
//                        {
//                            [self.peripheral setNotifyValue:NO forCharacteristic:characteristic];
//                            return;
//                        }
//                    }
//                }
//            }
//        }
//    }
//    [self.centralManager cancelPeripheralConnection:self.peripheral];
//}
//
//- (void)centralManagerDidUpdateState:(CBCentralManager *)central
//{
//    if (central.state != CBCentralManagerStatePoweredOn)
//    {
//        return;
//    }
//    if (central.state == CBCentralManagerStatePoweredOn)
//    {
//        [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:self.UUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
//    }
//}
/*******************************/

- (IBAction)send:(UIButton *)sender
{
    if ([self.colorBox.text isEqualToString:@"Red"])
    {
        NSLog(@"#FF0000");
    }
    else if ([self.colorBox.text isEqualToString:@"Green"])
    {
        NSLog(@"#00FF00");
    }
    else if ([self.colorBox.text isEqualToString:@"Blue"])
    {
        NSLog(@"#0000FF");
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.colors count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *simpleIdentifier = @"SimpleIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleIdentifier];
    }
    cell.textLabel.text = self.colors[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        self.colorBox.text = @"Red";
    }
    else if (indexPath.row == 1)
    {
        self.colorBox.text = @"Green";
    }
    else if (indexPath.row == 2)
    {
        self.colorBox.text = @"Blue";
    }
    [self.colorList setHidden:YES];
}

- (IBAction)colorSelectButton:(UIButton *)sender
{
    if (self.colorList.hidden == YES)
    {
        [self.colorList setHidden:NO];
    }
    else if (self.colorList.hidden == NO)
    {
        [self.colorList setHidden:YES];
    }
}

@end
