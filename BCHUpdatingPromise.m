//
//  BCHUpdatingPromise.m
//
//  Created by Brian Chu on 8/6/14.
//

#import "BCHUpdatingPromise.h"

@interface BCHUpdatingPromiseBlockWrapper : NSObject
@property (strong, nonatomic) BCHUpdatingPromise *promise;
@property (strong, nonatomic) BCHUpdatingPromiseBlock block;
@end
@implementation BCHUpdatingPromiseBlockWrapper
@end

@interface BCHUpdatingPromise ()
@property (strong, nonatomic) NSMutableArray *callbacks;
@property (strong, nonatomic) NSMutableArray *updateCallbacks;

@property (strong, nonatomic) NSMutableArray *catchCallbacks;
@property (strong, nonatomic) NSMutableArray *catchUpdateCallbacks;
@end

@implementation BCHUpdatingPromise

+ (instancetype)promise
{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _callbacks = [NSMutableArray array];
        _updateCallbacks = [NSMutableArray array];
        _catchCallbacks = [NSMutableArray array];
        _catchUpdateCallbacks = [NSMutableArray array];
        __weak typeof(self) this = self;
        self.then = ^BCHUpdatingPromise *(BCHUpdatingPromiseBlock block){
            return [this then:block];
        };
        self.thenAlways = ^BCHUpdatingPromise *(BCHUpdatingPromiseBlock block){
            return [this thenAlways:block];
        };
        self.catch = ^BCHUpdatingPromise *(BCHUpdatingPromiseBlock block){
            return [this catch:block];
        };
        self.catchAlways = ^BCHUpdatingPromise *(BCHUpdatingPromiseBlock block){
            return [this catchAlways:block];
        };
    }
    return self;
}

- (void)fulfill:(id)value
{
    self.value = value;
    for (BCHUpdatingPromiseBlockWrapper *wrapper in self.callbacks) {
        [wrapper.promise resolveWithValue:wrapper.block(value)];
    }
    [self.callbacks removeAllObjects];
    for (BCHUpdatingPromiseBlockWrapper *wrapper in self.updateCallbacks) {
        [wrapper.promise resolveWithValue:wrapper.block(value)];
    }
}

- (void)reject:(NSError *)error
{
    self.error = error;
    for (BCHUpdatingPromiseBlockWrapper *wrapper in self.catchCallbacks) {
        [wrapper.promise resolveWithValue:wrapper.block(error)];
    }
    [self.catchCallbacks removeAllObjects];
    for (BCHUpdatingPromiseBlockWrapper *wrapper in self.catchUpdateCallbacks) {
        [wrapper.promise resolveWithValue:wrapper.block(error)];
    }
}

// private:
- (void)resolveWithValue:(id)value
{
    if ([value isMemberOfClass:[NSError class]]) {
        [self reject:value];
    }
    else {
        [self fulfill:value];
    }
}

- (instancetype)then:(BCHUpdatingPromiseBlock)block
{
    return [self chainWithError:NO array:self.callbacks block:block];
}

- (instancetype)thenAlways:(BCHUpdatingPromiseBlock)block
{
    return [self chainWithError:NO array:self.updateCallbacks block:block];
}

- (instancetype)catch:(BCHUpdatingPromiseError)block
{
    return [self chainWithError:YES array:self.catchCallbacks block:block];
}

- (instancetype)catchAlways:(BCHUpdatingPromiseError)block
{
    return [self chainWithError:YES array:self.catchUpdateCallbacks block:block];
}

// private:
- (instancetype)chainWithError:(BOOL)error array:(NSMutableArray *)array block:(BCHUpdatingPromiseBlock)block
{
    BCHUpdatingPromiseBlockWrapper *wrapper = [[BCHUpdatingPromiseBlockWrapper alloc] init];
    wrapper.promise = [[self.class alloc] init];
    wrapper.block = block;
    id value = error ? self.error : self.value;
    if (value) {
        id chainedValue = block(value);
        [wrapper.promise resolveWithValue:chainedValue];
    }
    else {
        [array addObject:wrapper];
    }
    return wrapper.promise;
}

@end
