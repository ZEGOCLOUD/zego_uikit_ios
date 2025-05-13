#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LogManager : NSObject

+ (instancetype)sharedInstance;

- (void)writeToLog:(NSString *)content;

- (void)writeToLog:(NSString *)content flush:(BOOL)flushImmediately;

- (void)writeToLog:(NSString *)content appendTime:(BOOL)appendTime flush:(BOOL)flushImmediately;

- (void)flush;

@end

NS_ASSUME_NONNULL_END
