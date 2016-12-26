//
//  ViewController.m
//  BlemedBlueTooth
//
//  Created by JalynnXi on 8/9/16.
//  Copyright © 2016年 JalynnXi. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "dataModel.h"
#import "FSLineChart.h"
//#import "LineViewController.h"
#import "UIColor+FSPalette.h"
#define deviceName  @"RELEV"
#define pointCount 10
//static NSMutableArray *numArr;
static NSMutableArray *xjxArr ;

@interface ViewController ()
@property(nonatomic,strong)UIButton *sendBtn;
@property(nonatomic,strong)UIButton *scanBtn;
@property(nonatomic,strong)UIButton *lineBtn;
@property(nonatomic,strong)UITextView *resultTextView;
@property(nonatomic,strong)UITextField *dataTextField;
@property(assign) int count;
@property(nonatomic,strong)CBCentralManager *manager;
@property(nonatomic,strong)CBPeripheral *peripheral;
@property(nonatomic,strong)CBCharacteristic *writeCharacteristic;
@property(nonatomic,strong)CBCharacteristic *notifyCharacteristic;
@property(nonatomic,strong)CBCharacteristic *dataService;
@property(nonatomic,strong)NSData* newdata;
@property(nonatomic,strong)NSMutableArray *dataArr;
@property(nonatomic, assign)double voltage;
@property(nonatomic,strong) NSMutableArray *numArr;
@property(nonatomic,strong)FSLineChart *chartWithDates;
@property(nonatomic,strong)NSMutableArray *xAlix;
@end

@implementation ViewController
+ (CBUUID *)dataService
{
    return [CBUUID UUIDWithString:@"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"];
}

+ (CBUUID *)writeCharacter
{
    return [CBUUID UUIDWithString:@"6E400002-B5A3-F393-E0A9-E50E24DCCA9E"];
}

+ (CBUUID *)notifyCharacter
{
    return [CBUUID UUIDWithString:@"6E400003-B5A3-F393-E0A9-E50E24DCCA9E"];
}

-(double)voltage{
    if (!_voltage) {
        _voltage  = 0.00;
    }
    return _voltage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    xjxArr= [NSMutableArray array];
    self.view.backgroundColor = [UIColor colorWithRed:150/255.0 green:191/255.0 blue:209/255.0 alpha:1];
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [self CreateUI];
//    [self loadChartWithDates];
}


-(void)CreateUI{
    _dataTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 40, self.view.bounds.size.width-20,40 )];
    _dataTextField.placeholder = @"输入文字";
    _dataTextField.backgroundColor = [UIColor whiteColor];
    self.dataTextField.delegate = self;
    [self.view addSubview:_dataTextField];
    _sendBtn =[[UIButton alloc]initWithFrame:CGRectMake(40, 90, 100, 40)];
    _sendBtn.backgroundColor=[UIColor whiteColor];
    [_sendBtn setTitle:@"发送数据" forState:UIControlStateNormal];
    [_sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [_sendBtn addTarget:self action:@selector(sendbtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_sendBtn];
    
    _scanBtn =[[UIButton alloc]initWithFrame:CGRectMake(200, 90, 100, 40)];
    _scanBtn.backgroundColor=[UIColor whiteColor];
    [_scanBtn setTitle:@"扫描外设" forState:UIControlStateNormal];
    [_scanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [_scanBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_scanBtn];
    
    self.resultTextView =[[UITextView alloc]initWithFrame:CGRectMake(20, 140,[UIScreen mainScreen].bounds.size.width-40, 250)];
    self.resultTextView.delegate = self;
    [self.view addSubview:self.resultTextView];
 
    
    
    _chartWithDates = [[FSLineChart alloc]initWithFrame:CGRectMake(20, 395, [UIScreen mainScreen].bounds.size.width-40, 250)];
    _chartWithDates.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_chartWithDates];
    

    
    _lineBtn =[[UIButton alloc]initWithFrame:CGRectMake(50, 600,250, 40)];
    _lineBtn.backgroundColor=[UIColor whiteColor];
    [_lineBtn setTitle:@"波形图" forState:UIControlStateNormal];
    [_lineBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_lineBtn addTarget:self action:@selector(lineChart) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_lineBtn];
}


-(void)lineChart{
}

-(void)sendbtnClick:(UIButton *)btn{
    if (_peripheral.state == CBPeripheralStateConnected) {
        NSData *myD2 = [_dataTextField.text dataUsingEncoding:NSUTF8StringEncoding];
        Byte byte[] = {0x01,0x10};
        NSData *adata = [[NSData alloc] initWithBytes:byte length:2];
        NSMutableData * data=[[NSMutableData alloc]init];
        [data appendData:myD2];
        [data appendData:adata];
    //发送数据
       [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithoutResponse];

    }else
    {
        NSLog(@"不是连接状态");
        [self updateLog:@"处于断开连接状态，不能发送数据"];
    }
}


-(void)btnClick:(UIButton *)btn
{
    //扫描外设
    [self.manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    NSLog(@"扫描外设");
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)updateLog:(NSString*)s{
    [self.resultTextView setText:[NSString stringWithFormat:@"[ %d ]  %@\r\n%@",_count,s,self.resultTextView.text]];
    _count++;
}

//检测蓝牙状态
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            [self updateLog:@"蓝牙已经打开，开始扫描外设"];
            //扫描外设
            NSLog(@"蓝牙已经打开");
            [self.manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
            break;
            
        default:
            NSLog(@"Central Manager did change state");
            
            [self updateLog:@"蓝牙没有打开，请先打开蓝牙"];
            break;
    }
}


//外设被发现
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSString *UUID = [peripheral.identifier UUIDString];
//    NSLog(@"搜索到外设");
    
    //deviceName：设备名称
    if ([peripheral.name isEqualToString:deviceName]) {
        [self.manager stopScan];
        NSLog(@"🐢🐢🐢🐢%@",peripheral);
        if (self.peripheral != peripheral) {
            self.peripheral = peripheral;
            [self updateLog:[NSString stringWithFormat:@"扫描到外设的UUID:%@",UUID]];
            [self updateLog:[NSString stringWithFormat:@"已发现 peripheral: %@ rssi: %@, UUID: %@ advertisementData: %@ ", peripheral, RSSI, peripheral.identifier, advertisementData]];
            [self updateLog:[NSString stringWithFormat:@"连接到的外设名称:%@", peripheral.name]];
            [self.manager connectPeripheral:peripheral options:nil];
            
        }
    }
//    [self.manager stopScan];
   
}

//外设连接成功
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    [self updateLog:[NSString stringWithFormat:@"成功连接 peripheral: %@ with UUID: %@",peripheral,peripheral.identifier]];
    [self.peripheral setDelegate:self];
    [self.peripheral discoverServices:nil];
    [self updateLog:@"扫描服务"];
    
}

//连接外设失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error{
    [self updateLog:@"连接外设失败"];
    [self updateLog:[NSString stringWithFormat:@"连接结果，输出错误信息：%@",error]];
}

//已发现服务
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    [self updateLog:@"发现服务"];
    int i = 0;
    for (CBService *service in peripheral.services) {
        [self updateLog:[NSString stringWithFormat:@"%d :服务 UUID: %@(%@)",i,service.UUID.data,service.UUID]];
        i++;
        NSLog(@"Discovering characteristics for service %@", service);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

//已经搜索到特征值
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error) {
        NSLog(@"特征值获取错误：%@",[error localizedDescription]);
        [self updateLog:[NSString stringWithFormat:@"Error discovering characteristic: %@", [error localizedDescription]]];
        
        return;
    }
    [self updateLog:[NSString stringWithFormat:@"发现特征的服务:%@ (%@)",service.UUID.data ,service.UUID]];
    for (CBCharacteristic *characteristic in service.characteristics) {
        [self updateLog:[NSString stringWithFormat:@"特征 UUID: %@ (%@)",characteristic.UUID.data,characteristic.UUID]];
        if ([[characteristic UUID] isEqual:self.class.writeCharacter]) {
            _writeCharacteristic = characteristic;
        } else if ([[characteristic UUID] isEqual:self.class.notifyCharacter]) {
            _notifyCharacteristic = characteristic;
            [peripheral setNotifyValue:YES forCharacteristic:_notifyCharacteristic];
            [peripheral readValueForCharacteristic:characteristic];
        }
        
    }
    
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    [self updateLog:[NSString stringWithFormat:@"已断开与设备:[%@]的连接", peripheral.name]];
    
}

//获取外设发来的数据，订阅和read，获取的数据都是从这个方法中读取
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error{
    NSData *data  = characteristic.value;
 
    self.dataArr = [[NSMutableArray alloc]init];
    NSString *xjx = [[NSString stringWithFormat:@"%@",data] substringWithRange:NSMakeRange(1, 4)];
//    NSString *xjx = [NSString stringWithFormat:@"%@",data];
    int dian = [[NSString stringWithFormat:@"%lu", strtoul([xjx UTF8String],0,16)] intValue];
    _voltage = (double)dian/1024 *3.6;
    NSNumber *volatilenum = [NSNumber numberWithDouble:_voltage];
    [self.numArr addObject:volatilenum];
    
    if ([xjxArr count]<300) {
        [xjxArr addObject:volatilenum];
    }else{
        [xjxArr removeAllObjects];
    }
    [self loadChartWithDates];
}



- (void)loadChartWithDates {
    // Generating some dummy data
    
    NSMutableArray* chartData = [NSMutableArray arrayWithCapacity:xjxArr.count];
    for(int i=0;i<xjxArr.count;i++) {
        chartData[i] = xjxArr[i];
    }
    _chartWithDates.verticalGridStep = 3;
    _chartWithDates.horizontalGridStep = 10;
    _chartWithDates.fillColor = nil;
    
    _chartWithDates.displayDataPoint = YES;
    _chartWithDates.dataPointColor = [UIColor fsOrange];
    _chartWithDates.dataPointBackgroundColor = [UIColor fsOrange];
    _chartWithDates.dataPointRadius = 2;
    _chartWithDates.color = [_chartWithDates.dataPointColor colorWithAlphaComponent:0.3];
    _chartWithDates.valueLabelPosition = ValueLabelLeftMirrored;
    
    
    //x轴赋值
//    _chartWithDates.labelForIndex = ^(NSUInteger item) {
//        return _xAlix[item];
//    };
    
    _chartWithDates.labelForValue = ^(CGFloat value) {
        return [NSString stringWithFormat:@"%.02f", value];
    };
    
    [_chartWithDates setChartData:chartData];
    
}



//用于检测中心向外设写数据是否成功
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        
        NSLog(@"错误信息：%@",error.userInfo);
        NSLog(@"发送数据失败");
        
        [self updateLog:@"发送数据失败"];
        [self updateLog:[NSString stringWithFormat:@"错误信息：%@",error.userInfo]];
        
    }else{
        
        NSLog(@"发送数据成功");
        [self updateLog:@"发送数据成功"];
    }
    
    /* When a write occurs, need to set off a re-read of the local CBCharacteristic to update its value */
    [peripheral readValueForCharacteristic:characteristic];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
