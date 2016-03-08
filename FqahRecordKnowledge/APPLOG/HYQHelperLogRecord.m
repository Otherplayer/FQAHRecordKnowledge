//
//   /\_/\
//   \_ _/
//    / \ not
//    \_/
//
//  Created by __无邪_ on 3/8/16.
//  Copyright © 2016 fqah. All rights reserved.
//

#import "HYQHelperLogRecord.h"

NSString *const LOGFILENAME = @"APPLOG";

@implementation HYQHelperLogRecord

+ (instancetype)sharedInstance{
    static HYQHelperLogRecord *logManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logManager = [[HYQHelperLogRecord alloc] init];
    });
    return logManager;
}


- (instancetype)init{
    self = [super init];
    if (self) {
        [self installLog];
    }
    return self;
}

#pragma mark - initialization

- (void)installLog{
    if (DEBUG) {
        [self redirectNSlogToDocumentFolder];
    }
}

#pragma mark - public

- (void)installLogRecord{}


- (void)redirectNSlogToDocumentFolder{
    
    //如果已经连接Xcode调试则不输出到文件
//    if(isatty(STDOUT_FILENO)) {
//        return;
//    }
//    
//    UIDevice *device = [UIDevice currentDevice];
//    if([[device name] hasSuffix:@"Simulator"]){ //在模拟器不保存到文件中
//        return;
//    }
    
    NSString *logFilePath = [self logFilePath:[self logName]];
    
    // 将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    
    //未捕获的Objective-C异常日志
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
}


void UncaughtExceptionHandler(NSException* exception){
    
    NSString *name = [exception name];
    NSString *reason = [exception reason];
    NSArray *symbols = [exception callStackSymbols]; // 异常发生时的调用栈
    NSMutableString* strSymbols = [[NSMutableString alloc] init]; //将调用栈拼成输出日志的字符串
    for (NSString* item in symbols){
        [strSymbols appendString:item];
        [strSymbols appendString: @"\r\n" ];
    }
    
    //将crash日志保存到Document目录下的Log文件夹下
    NSString *logFilePath = [[[HYQHelperLogRecord alloc] init] logFilePath:@"UncaughtException.log"];
    NSString *dateStr = FQAHStringFromDate(@"yyyyMMddHHmmss", [NSDate date]);
    
    NSString *crashString = [NSString stringWithFormat:@"<- %@ ->[ Uncaught Exception ]\r\nName: %@, Reason: %@\r\n[ Fe Symbols Start ]\r\n%@[ Fe Symbols End ]\r\n\r\n", dateStr, name, reason, strSymbols];
    //把错误日志写到文件中
    writeDataToFile(logFilePath,crashString);
}

void writeDataToFile(NSString *logFilePath, NSString *string){
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *logDirectory = [paths[0] stringByAppendingPathComponent:LOGFILENAME];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:logDirectory]) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //把错误日志写到文件中
    
    if (![fileManager fileExistsAtPath:logFilePath]) {
        [string writeToFile:logFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }else{
        NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
        [outFile seekToEndOfFile];
        [outFile writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
        [outFile closeFile];
    }
}



#pragma mark - private

- (NSString *)logFilePath:(NSString *)logName{

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:LOGFILENAME];
    
    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:logName];
    if (![fileManager fileExistsAtPath:logFilePath]) {
        [fileManager createDirectoryAtPath:documentDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return logFilePath;
}

- (NSString *)logName{
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* appName = [infoDict objectForKey:@"CFBundleDisplayName"];
    if (!appName) {appName = LOGFILENAME;}
    appName = [appName stringByAppendingString:FQAHStringFromDate(@"yyyyMMddHHmmss", [NSDate date])];
    NSString *fileName = [NSString stringWithFormat:@"%@.log",appName];
    return fileName;
}


#pragma mark - dateFormatter

static inline NSString *FQAHStringFromDate(NSString *dateFormat, NSDate *date) {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:dateFormat];
    return [dateFormatter stringFromDate:date];
}

@end
