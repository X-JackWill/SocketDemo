//
//  MMAsyncSocket.h
//  SocketDemo
//
//  Created by Morris on 2021/9/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MMSocketConnectStatus) {
    MMSocketConnectStatusDisconnect,
    MMSocketConnectStatusConnecting,
    MMSocketConnectStatusConnected,
};

@class MMAsyncSocket;

@protocol MMAsyncSocketDelegate <NSObject>

/// 连接状态回调
- (void)mmAsyncSocket:(MMAsyncSocket *)socket connectStatusDidChanged:(MMSocketConnectStatus)status;
/// 发送成功回调
- (void)mmAsyncSocket:(MMAsyncSocket *)sock didWriteDataWithTag:(long)tag;
/// 发送消息超时回调
- (void)mmAsyncSocket:(MMAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag;
/// 收到消息回调
// Code...

@end

@interface MMAsyncSocket : NSObject

/// 连接状态
@property (nonatomic, assign, readonly) MMSocketConnectStatus status;

/// 单例对象
+ (instancetype)sharedInstance;

/// 连接/断开
- (BOOL)connectToHost:(NSString *)host onPort:(uint16_t)port error:(NSError **)errPtr;
- (void)disconnect;

/// 发送文本消息
- (void)sendMsg:(NSString *)msg;
/// 发送图片
- (void)sendPicture:(NSURL *)fileURL;


/// 添加/移除代理
- (void)addDelegate:(id<MMAsyncSocketDelegate>)delegate;
- (void)removeDelegate:(id<MMAsyncSocketDelegate>)delegate;


@end

NS_ASSUME_NONNULL_END
