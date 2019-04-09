@interface PFProperty: NSObject

-(id)initWithKey:(NSString *)key value:(NSString *)value valid:(BOOL)valid equals:(BOOL)equals;
-(NSDictionary *)dictionaryRepresentation;

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, assign) BOOL valid;
@property (nonatomic, assign) BOOL equals;

@end