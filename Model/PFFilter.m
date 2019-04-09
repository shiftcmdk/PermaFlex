#import "PFFilter.h"

@implementation PFFilter

-(id)initWithClassName:(NSString *)className frame:(NSString *)frame {
    if (self = [super init]) {
        self.properties = [NSMutableArray array];
        self.frame = frame;
        self.className = className;
    }

    return self;
}

-(NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSMutableArray *array = [NSMutableArray array];

    for (PFProperty *prop in self.properties) {
        [array addObject:[prop dictionaryRepresentation]];
    }

    dict[self.frame] = array;

    return dict;
}

-(void)dealloc {
    self.properties = nil;

    self.frame = nil;

    self.className = nil;

    [super dealloc];
}

@end