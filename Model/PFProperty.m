#import "PFProperty.h"

@implementation PFProperty

-(id)initWithKey:(NSString *)key value:(NSString *)value valid:(BOOL)valid equals:(BOOL)equals {
    if (self = [super init]) {
        self.key = key;
        self.value = value;
        self.valid = valid;
        self.equals = equals;
    }

    return self;
}

-(NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"key"] = self.key;
    dict[@"value"] = self.value;
    dict[@"equals"] = [NSNumber numberWithBool:self.equals];

    return dict;
}

-(void)dealloc {
    self.key = nil;
    self.value = nil;

    [super dealloc];
}

@end