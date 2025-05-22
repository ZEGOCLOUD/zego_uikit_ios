#import "LogManager.h"

static dispatch_once_t onceToken;
static id _instance;

@interface LogManager ()

@property (nonatomic, strong) NSFileHandle *logFileHandle;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) dispatch_queue_t logWriteQueue;
@property (nonatomic, strong) NSMutableArray *logCacheArray;

@end

@implementation LogManager

#define RETAIN_LOG_FILE_IN_X_DAYS   5
#define LOG_CACHE_UPPER_LIMIT       5

+ (instancetype)sharedInstance {
  dispatch_once(&onceToken, ^{
    _instance = [self new];
  });
  return _instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    self.dateFormatter = [NSDateFormatter new];
    self.logCacheArray = [NSMutableArray array];

    [self _createLogFile];
      
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_handleApplicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
  }
  return self;
}

- (void)_createLogFile {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *cacheDirectory = [paths objectAtIndex:0];
  NSString *folderPath = [cacheDirectory stringByAppendingPathComponent:@"zego_prebuilt"];
  
  // create zego_prebuilt folder
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if (NO == [fileManager fileExistsAtPath:folderPath]) {
    NSError *error = nil;
    BOOL success = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) {
      NSLog(@"Failed to create directory: %@", error);
      return;
    }
  }
  
  NSDate *currentDate = [NSDate date];
  [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];

  // Remove log files older than n days
  [self _removeExpiredLogFileWithFolderPath:folderPath];

  // create today logfile
  NSString *todayLogFileName = [NSString stringWithFormat:@"%@.log", [self.dateFormatter stringFromDate:currentDate]];
  NSString *filePath = [folderPath stringByAppendingPathComponent:todayLogFileName];
  self.logFileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
  
  // write first log of current process
  [self.dateFormatter setDateFormat:@"MMdd HH:mm:ss.SSS"];
  NSString *firstLog = [NSString stringWithFormat:@"\n%@ ==========PROCESS_START==========\n", [self.dateFormatter stringFromDate:currentDate]];
  NSData *dataToWrite = [firstLog dataUsingEncoding:NSUTF8StringEncoding];
  
  if (NULL == self.logFileHandle) {
    BOOL isWriteSucc = [dataToWrite writeToFile:filePath atomically:YES];
    self.logFileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [self.logFileHandle seekToEndOfFile];
  } else {
    [self.logFileHandle seekToEndOfFile];
    [self.logFileHandle writeData:dataToWrite];
  }
  
  NSString *threadName = [NSString stringWithFormat:@"%@.zego_prebuilt.logfilewriting", [NSBundle mainBundle].bundleIdentifier];
  self.logWriteQueue = dispatch_queue_create(threadName.UTF8String, DISPATCH_QUEUE_SERIAL);
}

- (void)_removeExpiredLogFileWithFolderPath: (NSString *)folderPath {
  NSMutableArray *keepFiles = [NSMutableArray array];
  
  NSDate *currentDate = [NSDate date];
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *components = [NSDateComponents new];
  for (int idx = 0; idx < RETAIN_LOG_FILE_IN_X_DAYS; idx++) {
    components.hour = -24*idx;
    NSDate *toKeepDate = [calendar dateByAddingComponents:components toDate:currentDate options:0];
    NSString *toKeepFileName = [NSString stringWithFormat:@"%@.log", [self.dateFormatter stringFromDate:toKeepDate]];
    [keepFiles addObject:toKeepFileName];
  }

  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSError *error = nil;
  NSArray *contents = [fileManager contentsOfDirectoryAtPath:folderPath error:&error];
  if (error) {
    NSLog(@"Error accessing directory: %@", error);
    return;
  }
  
  for (NSString *fileName in contents) {
    if (![fileName.pathExtension isEqualToString:@"log"] || ![fileName hasPrefix: @"20"]) {
      continue;
    }

    if ([keepFiles containsObject: fileName]) {
      continue;
    }
    
    NSString *toRemoveFilePath = [folderPath stringByAppendingPathComponent:fileName];
    if ([fileManager removeItemAtPath:toRemoveFilePath error:&error]) {
      [self write:[NSString stringWithFormat:@"Deleted file: %@ succeed.", fileName] appendTime:YES flush:NO];
    } else {
      [self write:[NSString stringWithFormat:@"Deleted file: %@ failed, error: %ld", fileName, error ? error.code : -1] appendTime:YES flush:NO];
    }
  }
}

- (void)write:(NSString *)content {
    [self write:content appendTime:YES flush:NO];
}

- (void)write:(NSString *)content flush:(BOOL)flushImmediately {
    [self write:content appendTime:YES flush:flushImmediately];
}

- (void)write:(NSString *)content appendTime:(BOOL)appendTime flush:(BOOL)flushImmediately {
  if (NULL == self.logFileHandle) {
    return;
  }
  
  NSString *logContent = NULL;
  if (appendTime) {
    NSDate *currentDate = [NSDate date];
    logContent = [NSString stringWithFormat:@"%@ %@\n", [self.dateFormatter stringFromDate:currentDate], content];
  } else {
    logContent = [NSString stringWithFormat:@"%@\n", content];
  }
  
  BOOL isNeedsWriteToFile = NO;
  NSArray *toWriteArray = NULL;
  @synchronized(self.logCacheArray) {
    [self.logCacheArray addObject:logContent];
    isNeedsWriteToFile = (self.logCacheArray.count >= LOG_CACHE_UPPER_LIMIT);
    if (isNeedsWriteToFile || flushImmediately) {
      toWriteArray = [NSArray arrayWithArray:self.logCacheArray];
      [self.logCacheArray removeAllObjects];
    }
  }
  
  if (NULL == toWriteArray) {
    return;
  }
  
  dispatch_async(self.logWriteQueue, ^{
    for (NSString *logContent in toWriteArray) {
      NSData *dataToWrite = [logContent dataUsingEncoding:NSUTF8StringEncoding];
      [self.logFileHandle writeData:dataToWrite];
    }
    
    [self _flush];
  });
}

- (void)_flush {
  NSError *error = nil;
  BOOL syncSuccess = [self.logFileHandle synchronizeAndReturnError:&error];
  if (!syncSuccess) {
    [self.logFileHandle closeFile];
    [self _createLogFile];
  }
}

- (void)flush {
  [self write:@"Passive flush." appendTime:YES flush:YES];
}

- (void)_handleApplicationDidEnterBackground:(NSNotification *)notify {
    [self flush];
}

@end
