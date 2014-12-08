@import Foundation;

#import "HYPFormField.h"

@interface HYPFieldValue : NSObject

@property (nonatomic, strong) id valueID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *label;
@property (nonatomic, strong) NSArray *targets;
@property (nonatomic, strong) HYPFormField *field;
@property (nonatomic, strong) NSNumber *value;

- (BOOL)identifierIsEqualTo:(id)identifier;

@end
