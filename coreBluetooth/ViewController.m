//
//  ViewController.m
//  coreBluetooth
//
//  Created by Joyce on 17/7/10.
//  Copyright © 2017年 Joyce. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "ZQBlueToothMachineDetailViewController.h"

@interface ViewController () <CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDataSource, UITableViewDelegate>
#define CHAR_RX_UUID @"D44BC439-ABFD-45A2-B575-925416129600"
#define CHAR_NO_UUID @"D44BC439-ABFD-45A2-B575-925416129601"
// Quintic BLEFCAEB2

/** 中心管理者 */
@property(nonatomic, strong)CBCentralManager *cMgr;
/** 外设 */
@property(nonatomic, strong)CBPeripheral *peripheral;
@property (nonatomic, strong) NSMutableArray *peripherals;
/** tableview */
@property(nonatomic, strong)UITableView *tableview;
/** cha */
@property(nonatomic, strong)CBCharacteristic *cha;

@end

@implementation ViewController

/** 懒加载 */
- (CBCentralManager *)cMgr {

    if (!_cMgr) {
        _cMgr = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:nil];
    }
    return _cMgr;
}

- (NSMutableArray *)peripherals
{
    if (!_peripherals) {
        self.peripherals = [NSMutableArray array];
    }
    return _peripherals;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 300)];
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    [self.view addSubview:self.tableview];
    
    [self cMgr];
}

#pragma mark ------------------
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.peripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * ID = @"UITableViewCell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    CBPeripheral * per = self.peripherals[indexPath.row];
    cell.textLabel.text = per.name;
    cell.detailTextLabel.text = per.state == CBPeripheralStateConnected?@"已连接":@"未连接";
    return cell;
}

#pragma mark ------------------
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.cMgr connectPeripheral:self.peripherals[indexPath.row] options:nil];
    
    
}

#pragma mark ------------------
#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {

    switch (central.state) {
        case CBCentralManagerStateUnknown:
            NSLog(@"CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@"CBCentralManagerStatePoweredOff");
            break;
        case CBCentralManagerStatePoweredOn:
        {
            NSLog(@"CBCentralManagerStatePoweredOn");
            
            // 扫描所有的外设
            [self.cMgr scanForPeripheralsWithServices:nil options:nil];
            // 扫描服务UUID 为0000FEE9-0000-1000-8000-00805F9B34FB 的外设
//            [self.cMgr scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"0000FEE9-0000-1000-8000-00805F9B34FB"]] options:nil];
            
        }
            break;
            
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSLog(@"%s, line = %d, cetral = %@,peripheral = %@, advertisementData = %@, RSSI = %@", __FUNCTION__, __LINE__, central, peripheral, advertisementData, RSSI);
    // 添加外围设备
    if (![self.peripherals containsObject:peripheral]) {
        // 设置外设的代理
        peripheral.delegate = self;
        [self.peripherals addObject:peripheral];
        [self.tableview reloadData];
    }
    
//    self.peripheral = peripheral;
//    [self.cMgr connectPeripheral:self.peripheral options:nil];
//    // 扫描到设备之后停止扫描
//    [self.cMgr stopScan];
//    [self presentViewController:[[ZQBlueToothMachineDetailViewController alloc] init] animated:YES completion:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
//    NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
//    NSLog(@">>>连接到名称为（%@）的设备-成功",peripheral.name);
//    NSLog(@"%@",peripheral.services.firstObject.UUID);
    
    peripheral.delegate = self;
    
    [peripheral discoverServices:nil];
    
    [self.tableview reloadData];
    
//    [self.cMgr stopScan];
}

#pragma mark ------------------
#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {

    if (error) {
        
//        NSLog(@"%s, line = %d, error = %@", __FUNCTION__, __LINE__, error.localizedDescription);
        return;
    }
    
    for (CBService *service in peripheral.services) {
//        NSLog(@"service.UUID = %@", service.UUID);
//        [peripheral discoverCharacteristics:nil forService:service];
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"0000FEE9-0000-1000-8000-00805F9B34FB"]]) {
                    [peripheral discoverCharacteristics:nil forService:service];
            break;
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
//    NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
    if (error)
    {
//        NSLog(@"error Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }
    
    for (CBCharacteristic *cha in service.characteristics) {
        [peripheral discoverDescriptorsForCharacteristic:cha];
        [peripheral setNotifyValue:YES forCharacteristic:cha];
        
        if ([cha.UUID isEqual:[CBUUID UUIDWithString:CHAR_RX_UUID]]) {
            
            if (cha.properties & CBCharacteristicPropertyWrite) {
                NSData* dataString = [@"B" dataUsingEncoding:NSUTF8StringEncoding];
                [peripheral writeValue:dataString // 写入的数据
                     forCharacteristic:cha // 写给哪个特征
                                  type:CBCharacteristicWriteWithResponse];// 通过此响应记录是否成功写入
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {

    if (error)
    {
//        NSLog(@"characteristic.UUID:%@ didUpdateValueForCharacteristic error : %@", characteristic.UUID, error.localizedDescription);
        return;
    }
    
    if (characteristic.isNotifying)
    {
        [peripheral readValueForCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error){
        
//        NSLog(@"--------error---------");
//        NSLog(@"didWriteValueForCharacteristic error：%@",[error localizedDescription]);
        return;
    }else {
//        NSLog(@"--------noerror---------");
        [peripheral readValueForCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (error)
    {
//        NSLog(@"characteristic.UUID%@ didUpdateValueForCharacteristic error : %@", characteristic.UUID, error.localizedDescription);
        return;
    }
    
//    NSLog(@"%s, line = %d, characteristic.UUID:%@  value:%@", __FUNCTION__, __LINE__, characteristic.UUID, characteristic.value);
    NSLog(@"收到返回数据：%@", characteristic.value);
    
//    NSString *value = [[NSString alloc] initWithData:characteristic.value encoding:NSASCIIStringEncoding];
//    NSLog(@"蓝牙给我们发的数据-value:%@",value);//这个就蓝牙给我们发的数据；
//    NSLog(@"蓝牙给我们发的数据-characteristic.value:%@",characteristic.value);
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
//    NSLog(@"%s, line = %d, descriptor.UUID:%@ value:%@", __FUNCTION__, __LINE__, descriptor.UUID, descriptor.value);

    // 这里当描述的值更新的时候,直接调用此方法即可
    [peripheral readValueForDescriptor:descriptor];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error
{
//    NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
    
    // 在此处读取描述即可
    for (CBDescriptor *descriptor in characteristic.descriptors) {
        // 它会触发
        [peripheral readValueForDescriptor:descriptor];
    }
}
@end
