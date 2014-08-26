//
//  BCHUpdatingPromise.h
//
//  Created by Brian Chu on 8/6/14.
//

@class BCHUpdatingPromise;

typedef id(^BCHUpdatingPromiseBlock)(id);
typedef id(^BCHUpdatingPromiseError)(NSError*);

typedef BCHUpdatingPromise *(^BCHUpdatingPromiseAction)(BCHUpdatingPromiseBlock);

@interface BCHUpdatingPromise : NSObject
@property (strong, nonatomic) id value;
@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) BCHUpdatingPromiseAction then;
@property (strong, nonatomic) BCHUpdatingPromiseAction thenAlways;
@property (strong, nonatomic) BCHUpdatingPromiseAction catch;
@property (strong, nonatomic) BCHUpdatingPromiseAction catchAlways;

+ (instancetype)promise;
- (void)fulfill:(id)value;
- (void)reject:(NSError *)error;
- (instancetype)then:(BCHUpdatingPromiseBlock)block;
- (instancetype)thenAlways:(BCHUpdatingPromiseBlock)block;
- (instancetype)catch:(BCHUpdatingPromiseError)block;
- (instancetype)catchAlways:(BCHUpdatingPromiseError)block;
@end
