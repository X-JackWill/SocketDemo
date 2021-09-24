//
//  MMAsyncSocket.m
//  SocketDemo
//
//  Created by Morris on 2021/9/23.
//

#import "MMAsyncSocket.h"
#import "GCDAsyncSocket.h"

@interface MMAsyncSocket ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, assign, readwrite) MMSocketConnectStatus status;
@property (nonatomic, strong) NSHashTable *delegates;

@end

@implementation MMAsyncSocket

+ (instancetype)sharedInstance {
    static MMAsyncSocket *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[MMAsyncSocket alloc] init];
        _sharedInstance.status = MMSocketConnectStatusDisconnect;
    });
    return _sharedInstance;
}

- (GCDAsyncSocket *)socket {
    if (!_socket) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        [_socket setDelegate:self];
        [_socket setAutoDisconnectOnClosedReadStream:NO];
    }
    return _socket;
}

- (NSHashTable *)delegates {
    if (!_delegates) {
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return _delegates;
}

- (void)setStatus:(MMSocketConnectStatus)status {
    _status = status;
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(mmAsyncSocket:connectStatusDidChanged:)]) {
            [delegate mmAsyncSocket:self connectStatusDidChanged:_status];
        }
    }
}

#pragma mark public

- (BOOL)connectToHost:(NSString *)host onPort:(uint16_t)port error:(NSError **)errPtr {
    self.status = MMSocketConnectStatusConnecting;
    return [self.socket connectToHost:host onPort:port error:errPtr];
}
- (void)disconnect {
    self.socket.delegate = nil;
    [self.socket disconnect];
    self.socket = nil;
    self.status = MMSocketConnectStatusDisconnect;
}

- (void)sendMsg:(NSString *)msg {
    if (msg && _socket) {
        [_socket writeData:[msg dataUsingEncoding:NSUTF8StringEncoding] withTimeout:1 tag:1];
    }
}
- (void)sendPicture:(NSURL *)fileURL {
    if (fileURL && _socket) {
        /// 这样直接发送图片，在终端收到之后是一堆乱码。一般的发送图片，需要先上传图片到服务，之后再发一个上传成功的消息。
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            NSData *data = [NSData dataWithContentsOfURL:fileURL];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.socket writeData:data withTimeout:1 tag:1];
//            });
//        });
    }
}

- (void)addDelegate:(id<MMAsyncSocketDelegate>)delegate {
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
}
- (void)removeDelegate:(id<MMAsyncSocketDelegate>)delegate {
    if ([self.delegates containsObject:delegate]) {
        [self.delegates removeObject:delegate];
    }
}


#pragma mark GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    self.status = MMSocketConnectStatusConnected;
}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    // 收到消息后，对消息做解析，然后判断是哪种类型的消息，再回调出去。根据不同的业务做封装即可。
    // Code ...
}
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(mmAsyncSocket:didWriteDataWithTag:)]) {
            [delegate mmAsyncSocket:self didWriteDataWithTag:tag];
        }
    }
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err {
    self.status = MMSocketConnectStatusDisconnect;
}
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                                                                  elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length {
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(mmAsyncSocket:shouldTimeoutWriteWithTag:)]) {
            [delegate mmAsyncSocket:self shouldTimeoutWriteWithTag:tag];
        }
    }
    return -1;
}


@end
