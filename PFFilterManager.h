#import "Model/PFFilter.h"

@interface PFFilterManager: NSObject

@property (nonatomic, assign) BOOL enabled;
+(instancetype)sharedManager;
-(id)initWithBundleID:(NSString *)bundleID;
-(void)saveFilter:(PFFilter *)filter;
-(void)deleteFilter:(PFFilter *)filter;
-(void)deleteFiltersForClassName:(NSString *)className;
-(void)initForSpringBoard;
-(NSArray<PFFilter *> *)filtersForClassName:(NSString *)classString;
-(NSArray<PFFilter *> *)filtersForClass:(Class)cls;
-(PFFilter *)filterForClass:(Class)cls frame:(NSString *)frame;
-(NSArray<NSString *> *)allClasses;
-(BOOL)hasAnyFrameForClass:(Class)cls;

@end