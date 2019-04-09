#import "Model/PFFilter.h"

@interface PFFilterManager: NSObject

@property (nonatomic, assign) BOOL enabled;
+(instancetype)sharedManager;
-(void)saveFilter:(PFFilter *)filter;
-(void)deleteFilter:(PFFilter *)filter;
-(void)initForSpringBoard;
-(NSArray<PFFilter *> *)filtersForClass:(Class)cls;
-(PFFilter *)filterForClass:(Class)cls frame:(NSString *)frame;

@end