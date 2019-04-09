@interface PFApp: NSObject

-(id)initWithBundleID:(NSString *)bundleID name:(NSString *)name enabled:(BOOL)enabled;

@property (nonatomic, copy) NSString *bundleID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL enabled;

@end