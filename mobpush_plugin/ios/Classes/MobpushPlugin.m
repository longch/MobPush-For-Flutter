#import "MobpushPlugin.h"
#import <MobPush/MobPush.h>
#import <MobPush/MobPush+Test.h>
#import <MobPush/MPushNotificationConfiguration.h>
#import <MOBFoundation/MOBFoundation.h>

@interface MobpushPlugin()<FlutterStreamHandler>
// 是否是生产环境
@property (nonatomic, assign) BOOL isPro;
// 事件回调
@property (nonatomic, copy) void (^callBack) (id _Nullable event);

@end

@implementation MobpushPlugin

static NSString *const receiverStr = @"mobpush_receiver";

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"mobpush_plugin" binaryMessenger:[registrar messenger]];
    MobpushPlugin* instance = [[MobpushPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    
    FlutterEventChannel* e_channel = [FlutterEventChannel eventChannelWithName:receiverStr binaryMessenger:[registrar messenger]];
    [e_channel setStreamHandler:instance];
    
    [instance addObserver];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    }
    else if ([@"getSDKVersion" isEqualToString:call.method])
    {
        //TODO: SDK 添加获取版本号接口
//        [MobPush sdkVersion];
        result(@"v1.7.4");
    }
    else if ([@"getRegistrationId" isEqualToString:call.method]) {
        [MobPush getRegistrationID:^(NSString *registrationID, NSError *error) {
            if (error) {
                result(nil);
            }
            else
            {
                if (result)
                {
                    result(registrationID);
                }
            }
        }];
    }
    else if ([@"stopPush" isEqualToString:call.method])
    {
        [MobPush stopPush];
    }
    else if ([@"restartPush" isEqualToString:call.method])
    {
        [MobPush restartPush];
    }
    else if ([@"isPushStopped" isEqualToString:call.method])
    {
        if (result)
        {
            result(@([MobPush isPushStopped]));
        }
    }
    else if ([@"setAlias" isEqualToString:call.method])
    {
        NSDictionary *arguments = (NSDictionary *)call.arguments;
        if (arguments && arguments[@"alias"])
        {
            [MobPush setAlias:arguments[@"alias"] result:^(NSError *error) {
                NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:4];
                [resultDict setObject:@(4) forKey:@"action"]; // action = 4 ，操作 alias
                [resultDict setObject:@(1) forKey:@"operation"]; // operation = 1 设置
                if (error)
                {
                    [resultDict setObject:@(error.code) forKey:@"errorCode"];
                    [resultDict setObject:error.description forKey:@"errorDesc"];
                }
                else
                {
                    [resultDict setObject:@(0) forKey:@"errorCode"];
                    [resultDict setObject:@"success" forKey:@"errorDesc"];
                }
                if (self.callBack)
                {
                    self.callBack(resultDict);
                }
            }];
        }
        else
        {
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:4];
            [resultDict setObject:@(4) forKey:@"action"]; // action = 4 ，操作 alias
            [resultDict setObject:@(1) forKey:@"operation"]; // operation = 1 设置
            [resultDict setObject:@(9999) forKey:@"errorCode"];
            [resultDict setObject:@"Arguments Invaild." forKey:@"errorDesc"];
            if (self.callBack)
            {
                self.callBack(resultDict);
            }
        }
    }
    else if ([@"getAlias" isEqualToString:call.method])
    {
        [MobPush getAliasWithResult:^(NSString *alias, NSError *error) {
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:5];
            [resultDict setObject:@(4) forKey:@"action"]; // action = 4 ，操作 alias
            [resultDict setObject:@(0) forKey:@"operation"]; // operation = 0 获取
            if (error)
            {
                [resultDict setObject:@(error.code) forKey:@"errorCode"];
                [resultDict setObject:error.description forKey:@"errorDesc"];
            } else
            {
                [resultDict setObject:alias.length > 0 ? alias : @"" forKey:@"alias"];
                [resultDict setObject:@(0) forKey:@"errorCode"];
                [resultDict setObject:@"success" forKey:@"errorDesc"];
            }
            if (self.callBack)
            {
                self.callBack(resultDict);
            }
        }];
    }
    else if ([@"deleteAlias" isEqualToString:call.method])
    {
        [MobPush deleteAlias:^(NSError *error) {
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:4];
            [resultDict setObject:@(4) forKey:@"action"]; // action = 4 ，操作 alias
            [resultDict setObject:@(2) forKey:@"operation"]; // operation = 2 删除
            if (error)
            {
                [resultDict setObject:@(error.code) forKey:@"errorCode"];
                [resultDict setObject:error.description forKey:@"errorDesc"];
            }
            else
            {
                [resultDict setObject:@(0) forKey:@"errorCode"];
                [resultDict setObject:@"success" forKey:@"errorDesc"];
            }
            if (self.callBack)
            {
                self.callBack(resultDict);
            }
        }];
    }
    else if ([@"addTags" isEqualToString:call.method])
    {
        NSDictionary *arguments = (NSDictionary *)call.arguments;
        if (arguments && arguments[@"tags"]) {
            [MobPush addTags:arguments[@"tags"] result:^(NSError *error) {
                NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:4];
                [resultDict setObject:@(3) forKey:@"action"]; // action = 3 ，操作 tag
                [resultDict setObject:@(1) forKey:@"operation"]; // operation = 1 设置
                if (error)
                {
                    [resultDict setObject:@(error.code) forKey:@"errorCode"];
                    [resultDict setObject:error.description forKey:@"errorDesc"];
                }
                else
                {
                    [resultDict setObject:@(0) forKey:@"errorCode"];
                    [resultDict setObject:@"success" forKey:@"errorDesc"];
                }
                if (self.callBack)
                {
                    self.callBack(resultDict);
                }
            }];
        }
        else
        {
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:4];
            [resultDict setObject:@(3) forKey:@"action"]; // action = 3 ，操作 tag
            [resultDict setObject:@(1) forKey:@"operation"]; // operation = 1 设置
            [resultDict setObject:@(9999) forKey:@"errorCode"];
            [resultDict setObject:@"Arguments Invaild." forKey:@"errorDesc"];
            if (self.callBack)
            {
                self.callBack(resultDict);
            }
        }
        
    }
    else if ([@"getTags" isEqualToString:call.method])
    {
        [MobPush getTagsWithResult:^(NSArray *tags, NSError *error) {
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:5];
            [resultDict setObject:@(3) forKey:@"action"]; // action = 3 ，操作 tag
            [resultDict setObject:@(0) forKey:@"operation"]; // operation = 0 获取
            if (error)
            {
                [resultDict setObject:@(error.code) forKey:@"errorCode"];
                [resultDict setObject:error.description forKey:@"errorDesc"];
            }
            else
            {
                if (tags.count > 0)
                {
                    NSString *tagStr = [tags componentsJoinedByString:@","];
                    [resultDict setObject:tagStr forKey:@"tags"];
                }
                else
                {
                    [resultDict setObject:@"" forKey:@"tags"];
                }
                [resultDict setObject:@(0) forKey:@"errorCode"];
                [resultDict setObject:@"success" forKey:@"errorDesc"];
            }
            if (self.callBack)
            {
                self.callBack(resultDict);
            }
        }];
    }
    else if ([@"deleteTags" isEqualToString:call.method])
    {
        NSDictionary *arguments = (NSDictionary *)call.arguments;
        if (arguments && arguments[@"tags"]) {
            [MobPush deleteTags:arguments[@"tags"] result:^(NSError *error) {
                NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:4];
                [resultDict setObject:@(3) forKey:@"action"]; // action = 3 ，操作 tag
                [resultDict setObject:@(2) forKey:@"operation"]; // operation = 2 删除
                if (error)
                {
                    [resultDict setObject:@(error.code) forKey:@"errorCode"];
                    [resultDict setObject:error.description forKey:@"errorDesc"];
                }
                else
                {
                    [resultDict setObject:@(0) forKey:@"errorCode"];
                    [resultDict setObject:@"success" forKey:@"errorDesc"];
                }
                
                if (self.callBack)
                {
                    self.callBack(resultDict);
                }
            }];
        }
        else
        {
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:4];
            [resultDict setObject:@(3) forKey:@"action"]; // action = 3 ，操作 tag
            [resultDict setObject:@(2) forKey:@"operation"]; // operation = 2 删除
            [resultDict setObject:@(9999) forKey:@"errorCode"];
            [resultDict setObject:@"Arguments Invaild." forKey:@"errorDesc"];
            if (self.callBack)
            {
                self.callBack(resultDict);
            }
        }
    }
    else if ([@"cleanTags" isEqualToString:call.method])
    {
        [MobPush cleanAllTags:^(NSError *error) {
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:4];
            [resultDict setObject:@(3) forKey:@"action"]; // action = 3 ，操作 tag
            [resultDict setObject:@(3) forKey:@"operation"]; // operation = 3 清空
            if (error)
            {
                [resultDict setObject:@(error.code) forKey:@"errorCode"];
                [resultDict setObject:error.description forKey:@"errorDesc"];
            }
            else
            {
                [resultDict setObject:@(0) forKey:@"errorCode"];
                [resultDict setObject:@"success" forKey:@"errorDesc"];
            }
            if (self.callBack)
            {
                self.callBack(resultDict);
            }
        }];
    }
    else if ([@"addLocalNotification" isEqualToString:call.method])
    {
        NSDictionary *arguments = (NSDictionary *)call.arguments;
        if (arguments && arguments[@"localNotification"])
        {
            NSString *localStr = arguments[@"localNotification"];
            NSDictionary *eventParams = [MOBFJson objectFromJSONString:localStr];
            MPushMessage *message = [[MPushMessage alloc] init];
            message.messageType = MPushMessageTypeLocal;
            MPushNotification *noti = [[MPushNotification alloc] init];
            if (eventParams[@"title"] && ![eventParams[@"title"] isKindOfClass:[NSNull class]])
            {
                noti.title = eventParams[@"title"];
            }
            if (eventParams[@"content"] && ![eventParams[@"content"] isKindOfClass:[NSNull class]])
            {
                noti.body = eventParams[@"content"];
            }
            if (eventParams[@"sound"] && ![eventParams[@"sound"] isKindOfClass:[NSNull class]])
            {
                noti.sound = eventParams[@"sound"];
                
            }
            if (eventParams[@"badge"] && ![eventParams[@"badge"] isKindOfClass:[NSNull class]])
            {
                noti.badge = [eventParams[@"badge"] integerValue];
            }
            if (eventParams[@"subTitle"] && ![eventParams[@"subTitle"] isKindOfClass:[NSNull class]])
            {
                noti.subTitle = eventParams[@"subTitle"];
            }
            if (eventParams[@"timestamp"] && ![eventParams[@"timestamp"] isKindOfClass:[NSNull class]])
            {
                long timeStamp = [eventParams[@"timestamp"] longValue];
                if (timeStamp == 0)
                {
                    message.isInstantMessage = YES;
                }
                else
                {
                    NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:0];
                    NSTimeInterval nowtime = [currentDate timeIntervalSince1970] * 1000;
                    message.taskDate = nowtime + (NSTimeInterval)timeStamp;
                }
            }
            else
            {
                message.isInstantMessage = YES;
            }
            message.notification = noti;
            [MobPush addLocalNotification:message];
        }
    }
    else if ([@"bindPhoneNum" isEqualToString:call.method])
    {
        NSDictionary *arguments = (NSDictionary *)call.arguments;
        if (arguments && arguments[@"phoneNum"])
        {
            [MobPush bindPhoneNum:arguments[@"phoneNum"] result:^(NSError *error) {
                NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:3];
                [resultDict setObject:@(5) forKey:@"action"];
                if (error)
                {
                    [resultDict setObject:@(error.code) forKey:@"errorCode"];
                    [resultDict setObject:error.description forKey:@"errorDesc"];
                }
                else
                {
                    [resultDict setObject:@(0) forKey:@"errorCode"];
                    [resultDict setObject:@"success" forKey:@"errorDesc"];
                }
                if (self.callBack)
                {
                    self.callBack(resultDict);
                }
            }];
        }
        else
        {
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:3];
            [resultDict setObject:@(5) forKey:@"action"];
            [resultDict setObject:@(9999) forKey:@"errorCode"];
            [resultDict setObject:@"Arguments Invaild." forKey:@"errorDesc"];
            if (self.callBack)
            {
                self.callBack(resultDict);
            }
        }
    }
    else if ([@"send" isEqualToString:call.method])
    {
        NSDictionary *arguments = (NSDictionary *)call.arguments;
        if (arguments) {
            NSInteger type = [arguments[@"type"] integerValue];
            NSString *content = arguments[@"content"];
            NSNumber *space = arguments[@"space"];
            NSDictionary *extras = (NSDictionary *)arguments[@"extras"];
            [MobPush sendMessageWithMessageType:type
                                        content:content
                                          space:space
                        isProductionEnvironment:_isPro
                                         extras:extras
                                     linkScheme:nil
                                       linkData:nil
                                         result:^(NSError *error) {
                                             NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:3];
                                             [resultDict setObject:@(6) forKey:@"action"];
                                             if (error)
                                             {
                                                 [resultDict setObject:@(error.code) forKey:@"errorCode"];
                                                 [resultDict setObject:error.description forKey:@"errorDesc"];
                                             }
                                             else
                                             {
                                                 [resultDict setObject:@(0) forKey:@"errorCode"];
                                                 [resultDict setObject:@"success" forKey:@"errorDesc"];
                                             }
                                             if (self.callBack)
                                             {
                                                 self.callBack(resultDict);
                                             }
                                         }];
        }
        else
        {
            NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithCapacity:3];
            [resultDict setObject:@(6) forKey:@"action"];
            [resultDict setObject:@(9999) forKey:@"errorCode"];
            [resultDict setObject:@"Arguments Invaild." forKey:@"errorDesc"];
            if (self.callBack)
            {
                self.callBack(resultDict);
            }
        }
    }
    else if ([@"setAPNsForProduction" isEqualToString:call.method])
    {
        NSDictionary *arguments = (NSDictionary *)call.arguments;
        _isPro = [arguments[@"isPro"] boolValue];
        [MobPush setAPNsForProduction:_isPro];
    }
    else if ([@"setBadge" isEqualToString:call.method])
    {
        NSDictionary *arguments = (NSDictionary *)call.arguments;
        NSInteger badge = [arguments[@"badge"] integerValue];
        UIApplication.sharedApplication.applicationIconBadgeNumber = badge;
        [MobPush setBadge:badge];
    }
    else if ([@"clearBadge" isEqualToString:call.method])
    {
        [MobPush clearBadge];
    }
    else if ([@"setCustomNotification" isEqualToString:call.method])
    {
        MPushNotificationConfiguration *config = [[MPushNotificationConfiguration alloc] init];
        config.types = MPushAuthorizationOptionsSound | MPushAuthorizationOptionsBadge | MPushAuthorizationOptionsAlert;
        [MobPush setupNotification:config];
    }
    else
    {
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - FlutterStreamHandler Protocol

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events
{
    self.callBack = events;
    return nil;
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments
{
    return nil;
}

#pragma mark - 监听消息通知

- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessage:) name:MobPushDidReceiveMessageNotification object:nil];
}

- (void)didReceiveMessage:(NSNotification *)notification
{
    if (self.callBack && [notification.object isKindOfClass:[MPushMessage class]])
    {
        MPushMessage *message = (MPushMessage *)notification.object;
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
        NSMutableDictionary *reslut = [NSMutableDictionary dictionary];
        switch (message.messageType)
        {
            case MPushMessageTypeCustom:
            {// 自定义消息
                [resultDict setObject:@(0) forKey:@"action"];
                if (message.extraInfomation)
                {
                    [reslut setObject:message.extraInfomation forKey:@"extra"];
                }
                if (message.content)
                {
                    [reslut setObject:message.content forKey:@"content"];
                }
                if (message.messageID)
                {
                    [reslut setObject:message.messageID forKey:@"messageId"];
                }
                if (message.currentServerTimestamp)
                {
                    [reslut setObject:@(message.currentServerTimestamp) forKey:@"timeStamp"];
                }
            }
                break;
            case MPushMessageTypeAPNs:
            {// APNs 回调
                /*
                 {
                 1 = 2;
                 aps =     {
                 alert =         {
                 body = 1;
                 subtitle = 1;
                 title = 1;
                 };
                 "content-available" = 1;
                 "mutable-content" = 1;
                 };
                 mobpushMessageId = 159346875878223872;
                 }
                 */
                if (message.msgInfo)
                {
                    NSDictionary *aps = message.msgInfo[@"aps"];
                    if ([aps isKindOfClass:[NSDictionary class]])
                    {
                        NSDictionary *alert = aps[@"alert"];
                        if ([alert isKindOfClass:[NSDictionary class]])
                        {
                            NSString *body = alert[@"body"];
                            if (body)
                            {
                                [reslut setObject:body forKey:@"content"];
                            }
                            
                            NSString *subtitle = alert[@"subtitle"];
                            if (subtitle)
                            {
                                [reslut setObject:subtitle forKey:@"subtitle"];
                            }
                            
                            NSString *title = alert[@"title"];
                            if (title)
                            {
                                [reslut setObject:title forKey:@"title"];
                            }
                        }
                        NSString *sound = aps[@"sound"];
                        if (sound)
                        {
                            [reslut setObject:sound forKey:@"sound"];
                        }
                        NSInteger badge = [aps[@"badge"] integerValue];
                        if (badge)
                        {
                            [reslut setObject:@(badge) forKey:@"badge"];
                        }
                    }
                }
                
                NSString *messageId = message.msgInfo[@"mobpushMessageId"];
                if (messageId)
                {
                    [reslut setObject:messageId forKey:@"messageId"];
                }
                
                NSMutableDictionary *extra = [NSMutableDictionary dictionary];
                [message.msgInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if (![key isEqualToString:@"aps"] && ![key isEqualToString:@"mobpushMessageId"])
                    {
                        [extra setObject:obj forKey:key];
                    }
                }];
                
                if (extra.count)
                {
                    [reslut setObject:extra forKey:@"extra"];
                }
                
                [resultDict setObject:@(1) forKey:@"action"];
            }
                break;
            case MPushMessageTypeLocal:
            { // 本地通知回调
                NSString *body = message.notification.body;
                NSString *title = message.notification.title;
                NSString *subtitle = message.notification.subTitle;
                NSInteger badge = message.notification.badge;
                NSString *sound = message.notification.sound;
                if (body)
                {
                    [reslut setObject:body forKey:@"content"];
                }
                if (title)
                {
                    [reslut setObject:title forKey:@"title"];
                }
                if (subtitle)
                {
                    [reslut setObject:subtitle forKey:@"subtitle"];
                }
                if (badge)
                {
                    [reslut setObject:@(badge) forKey:@"badge"];
                }
                if (sound)
                {
                    [reslut setObject:sound forKey:@"sound"];
                }
                
                [resultDict setObject:@(1) forKey:@"action"];
            }
                break;
                
            case MPushMessageTypeClicked:
            {
                if (message.msgInfo)
                {
                    NSDictionary *aps = message.msgInfo[@"aps"];
                    if ([aps isKindOfClass:[NSDictionary class]])
                    {
                        NSDictionary *alert = aps[@"alert"];
                        if ([alert isKindOfClass:[NSDictionary class]])
                        {
                            NSString *body = alert[@"body"];
                            if (body)
                            {
                                [reslut setObject:body forKey:@"content"];
                            }
                            NSString *subtitle = alert[@"subtitle"];
                            if (subtitle)
                            {
                                [reslut setObject:subtitle forKey:@"subtitle"];
                            }
                            NSString *title = alert[@"title"];
                            if (title)
                            {
                                [reslut setObject:title forKey:@"title"];
                            }
                        }
                        NSString *sound = aps[@"sound"];
                        if (sound)
                        {
                            [reslut setObject:sound forKey:@"sound"];
                        }
                        NSInteger badge = [aps[@"badge"] integerValue];
                        if (badge)
                        {
                            [reslut setObject:@(badge) forKey:@"badge"];
                        }
                    }
                    
                    NSString *messageId = message.msgInfo[@"mobpushMessageId"];
                    if (messageId)
                    {
                        [reslut setObject:messageId forKey:@"messageId"];
                    }
                    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
                    [message.msgInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                        if (![key isEqualToString:@"aps"] && ![key isEqualToString:@"mobpushMessageId"])
                        {
                            [extra setObject:obj forKey:key];
                        }
                    }];
                    
                    if (extra.count)
                    {
                        [reslut setObject:extra forKey:@"extra"];
                    }
                    
                    [resultDict setObject:@(2) forKey:@"action"];
                }
                else
                {
                    NSString *body = message.notification.body;
                    NSString *title = message.notification.title;
                    NSString *subtitle = message.notification.subTitle;
                    NSInteger badge = message.notification.badge;
                    NSString *sound = message.notification.sound;
                    if (body)
                    {
                        [reslut setObject:body forKey:@"content"];
                    }
                    if (title)
                    {
                        [reslut setObject:title forKey:@"title"];
                    }
                    if (subtitle)
                    {
                        [reslut setObject:subtitle forKey:@"subtitle"];
                    }
                    if (badge)
                    {
                        [reslut setObject:@(badge) forKey:@"badge"];
                    }
                    if (sound)
                    {
                        [reslut setObject:sound forKey:@"sound"];
                    }
                    
                    [resultDict setObject:@(2) forKey:@"action"];
                }
            }
                break;
                
            default:
                break;
        }
        if (reslut.count > 0)
        {
            [resultDict setObject:reslut forKey:@"result"];
        }
        // 回调结果
        self.callBack(resultDict);
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
