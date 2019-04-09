#import "PFApp.h"

@implementation PFApp

-(id)initWithBundleID:(NSString *)bundleID name:(NSString *)name enabled:(BOOL)enabled {
    if (self = [super init]) {
        self.bundleID = bundleID;
        self.name = name;
        self.enabled = enabled;
    }

    return self;
}

-(void)dealloc {
    self.bundleID = nil;
    self.name = nil;

    [super dealloc];
}

@end