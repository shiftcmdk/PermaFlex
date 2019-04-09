#import "PFProperty.h"

@interface PFFilter: NSObject

-(id)initWithClassName:(NSString *)className frame:(NSString *)frame;
-(NSDictionary *)dictionaryRepresentation;

@property (nonatomic, retain) NSMutableArray<PFProperty *> *properties;
@property (nonatomic, copy) NSString *frame;
@property (nonatomic, copy) NSString *className;

@end