//
//  ViewController.m
//  SocketDemo
//
//  Created by Morris on 2021/9/23.
//

#import "ViewController.h"
#import "MMAsyncSocket.h"

@interface ViewController ()<MMAsyncSocketDelegate>

@property (nonatomic, strong) MMAsyncSocket *socket;

@property (weak, nonatomic) IBOutlet UITextField *ipTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (weak, nonatomic) IBOutlet UITextField *connetTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.socket = [MMAsyncSocket sharedInstance];
    [self.socket addDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.ipTextField.text = @"127.0.0.1";
    self.portTextField.text = @"123";
}

- (IBAction)connectClick:(UIButton *)sender {
    // 未连接，进行连接
    if (self.socket.status == MMSocketConnectStatusDisconnect) {
        NSString *ip = self.ipTextField.text;
        int port = [self.portTextField.text intValue];
        if (ip && ip.length && port & (port > 0)) {
            NSError *error = nil;
            BOOL result = [self.socket connectToHost:ip onPort:port error:&error];
            if (result) {
                [self.connectBtn setTitle:@"断开" forState:UIControlStateNormal];
            } else {
                NSLog(@"连接失败!");
            }
        }
    }
    // 已连接或正在连接，断开
    else {
        [self.socket disconnect];
        [self.connectBtn setTitle:@"连接" forState:UIControlStateNormal];
    }
}

- (IBAction)sendClick:(UIButton *)sender {
    // 发送文本消息
    [self.socket sendMsg:self.connetTextField.text];
    
    // 发送图片
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"button_production@2x" ofType:@".png"];
//    [self.socket sendPicture:[NSURL fileURLWithPath:filePath]];
}


#pragma mark MMAsyncSocketDelegate

- (void)mmAsyncSocket:(MMAsyncSocket *)socket connectStatusDidChanged:(MMSocketConnectStatus)status {
    switch (status) {
        case MMSocketConnectStatusDisconnect:
            [self.connectBtn setTitle:@"连接" forState:UIControlStateNormal];
            break;
        case MMSocketConnectStatusConnecting:
            [self.connectBtn setTitle:@"断开" forState:UIControlStateNormal];
            break;
        case MMSocketConnectStatusConnected:
            [self.connectBtn setTitle:@"断开" forState:UIControlStateNormal];
            break;
    }
    NSLog(@"连接状态：%ld",(long)status);
}

@end
