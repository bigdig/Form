#import "FORMSection.h"
#import "FORMField.h"
#import "FORMGroup.h"
#import "NSDictionary+ANDYSafeValue.h"
#import "FORMTarget.h"

@implementation FORMSection

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
                          position:(NSInteger)position
                          disabled:(BOOL)disabled
                 disabledFieldsIDs:(NSArray *)disabledFieldsIDs
                     isLastSection:(BOOL)isLastSection
{
    self = [super init];
    if (!self) return nil;

    _sectionID = [dictionary andy_valueForKey:@"id"];
    _position = @(position);
    _isLast = isLastSection;
    _typeString  = [dictionary andy_valueForKey:@"type"] ?: @"default";
    _type = [self typeFromTypeString:_typeString];
    NSLog(@"_typeString: %@", _typeString);

    NSArray *dataSourceFields = [dictionary andy_valueForKey:@"fields"];
    NSMutableArray *fields = [NSMutableArray new];

    [dataSourceFields enumerateObjectsUsingBlock:^(NSDictionary *fieldDict, NSUInteger fieldIndex, BOOL *stop) {

        FORMField *field = [[FORMField  alloc] initWithDictionary:fieldDict
                                                               position:fieldIndex
                                                               disabled:disabled
                                                      disabledFieldsIDs:disabledFieldsIDs];
        field.section = self;
        [fields addObject:field];
    }];

    if (_type == FORMSectionTypeDynamic) {
        FORMField *field = [FORMField new];
        field.position = @(fields.count);
        field.section = self;
        field.fieldID = [NSString stringWithFormat:@"%@.add", self.sectionID];
        field.typeString = @"button";
        field.type = FORMFieldTypeButton;
        field.title = [NSString stringWithFormat:@"✚ %@", [self.sectionID uppercaseString]];
        field.section = self;
        field.size = CGSizeMake(100.0f, 2.0f);
        [fields addObject:field];
    }

    if (!isLastSection) {
        FORMField *field = [FORMField new];
        field.sectionSeparator = YES;
        field.position = @(fields.count);
        field.section = self;
        [fields addObject:field];
    }

    self.fields = fields;

    return self;
}

- (FORMSectionType)typeFromTypeString:(NSString *)typeString
{
    if ([typeString isEqualToString:@"dynamic"]) {
        return FORMSectionTypeDynamic;
    } else {
        return FORMSectionTypeDefault;
    }
}

#pragma mark - Public Methods

#pragma mark Class

+ (void)sectionAndIndexForField:(FORMField *)field
                        inForms:(NSArray *)forms
                     completion:(void (^)(BOOL found,
                                          FORMSection *section,
                                          NSInteger index))completion
{
    FORMGroup *form = forms[[field.section.form.position integerValue]];
    FORMSection *section = form.sections[[field.section.position integerValue]];

    __block NSInteger index = 0;
    __block BOOL found = NO;
    [section.fields enumerateObjectsUsingBlock:^(FORMField *aField, NSUInteger idx, BOOL *stop) {
        if ([aField.fieldID isEqualToString:field.fieldID]) {
            index = idx;
            found = YES;
            *stop = YES;
        }
    }];

    if (completion) {
        completion(found, section, index);
    }
}

#pragma mark Instance

- (NSInteger)indexInForms:(NSArray *)forms
{
    FORMGroup *form = forms[[self.form.position integerValue]];

    BOOL found = NO;
    NSInteger index = 0;
    NSUInteger idx = 0;

    for (FORMSection *aSection in form.sections) {
        if ([aSection.position integerValue] >= [self.position integerValue]) {
            index = idx;
            found = YES;
            break;
        }

        idx++;
    }

    if (!found) index = [form.sections count];

    return index;
}

- (void)removeField:(FORMField *)field inForms:(NSArray *)forms
{
    __block NSInteger index = 0;
    [self.fields enumerateObjectsUsingBlock:^(FORMField *aField, NSUInteger idx, BOOL *stop) {
        if ([aField.fieldID isEqualToString:field.fieldID]) {
            index = idx;
            *stop = YES;
        }
    }];

    [self.fields removeObjectAtIndex:index];
}

- (NSString *)description
{
    NSMutableArray *fields = [NSMutableArray new];
    for (FORMField *field in self.fields) {
        [fields addObject:field.fieldID];
    }

    return [NSString stringWithFormat:@"\n — Section: %@ —\n position: %@\n formID: %@\n shouldValidate: %@\n containsSpecialField: %@\n isLast: %@\n fields: %@\n",
            self.sectionID, self.position, self.form.formID, self.shouldValidate ? @"YES" : @"NO", self.containsSpecialField ? @"YES" : @"NO", self.isLast ? @"YES" : @"NO", fields];
}

@end
