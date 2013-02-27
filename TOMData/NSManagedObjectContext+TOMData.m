//
//  NSManagedObjectContext+TOMData.m
//  TOMData
//
//  Copyright (c) 2013 Tomaz Nedeljko (http://nedeljko.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "TOMDataErrorHandler.h"
#import "NSManagedObjectContext+TOMData.h"

static NSManagedObjectContext *tom_rootContext = nil;
static NSManagedObjectContext *tom_mainContext = nil;

@implementation NSManagedObjectContext (TOMData)

#pragma mark -
#pragma mark Class Methods

+ (NSManagedObjectContext *)rootContext
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tom_rootContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [tom_rootContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    });
    return tom_rootContext;
}

+ (NSManagedObjectContext *)mainContext
{    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tom_mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [tom_mainContext setParentContext:[self rootContext]];
    });
    return tom_mainContext;
}

+ (NSManagedObjectContext *)childContextWithMainContext
{
    return [self childContextWithConcurrencyType:NSPrivateQueueConcurrencyType parentContext:[self mainContext]];
}

+ (NSManagedObjectContext *)childContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)type parentContext:(NSManagedObjectContext *)parentContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
    [context setParentContext:parentContext];
    return context;
}

#pragma mark -
#pragma mark Instance Methods

- (BOOL)tom_save
{
    if (![self hasChanges]) {
        return NO;
    }
    
    NSError *error = nil;
    BOOL saved = NO;
    @try {
        saved = [self save:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"Unable to perform save: %@", (id)[exception userInfo] ?: (id)[exception reason]);
    }
    @finally {
        if (!saved && error) {
            [TOMDataErrorHandler handleError:error];
        }
    }
    return saved;
}

#pragma mark -

- (NSManagedObjectModel *)managedObjectModel
{
    return [[self persistentStoreCoordinator] managedObjectModel];
}

#pragma mark -

- (BOOL)save
{
    __block BOOL saved = NO;
    [self performBlockAndWait:^{
        saved = [self tom_save];
    }];
    
    if ([self parentContext] == tom_rootContext && [[[tom_rootContext persistentStoreCoordinator] persistentStores] count]) {
        [tom_rootContext performBlockAndWait:^{
            saved = saved && [tom_rootContext tom_save];
        }];
    }
    
    return saved;
}

- (BOOL)saveWithParentContext
{
    BOOL saved  = [self save];
    if ([self parentContext] != tom_rootContext) {
        saved = saved && [[self parentContext] save];
    }
    return saved;
}

- (BOOL)saveWithParentContexts
{
    BOOL saved = [self save];
    if ([self parentContext] != tom_rootContext) {
        saved = saved && [[self parentContext] saveWithParentContexts];
    }
    return saved;
}

#pragma mark -

- (NSArray *)executeFetchRequest:(NSFetchRequest *)request
{
    __block NSArray *results;
    [self performBlockAndWait:^{
        NSError *error = nil;
        @try {
            results = [self executeFetchRequest:request error:&error];
        }
        @catch (NSException *exception) {
            NSLog(@"Unable to execute fetch request %@: %@", request, (id)[exception userInfo] ?: (id)[exception reason]);
        }
        @finally {
            if (!results && error) {
                [TOMDataErrorHandler handleError:error];
            }
        }
    }];
    return results;
}

- (NSUInteger)countForFetchRequest:(NSFetchRequest *)request
{
    __block NSUInteger count;
    [self performBlockAndWait:^{
        NSError *error = nil;
        @try {
            count = [self countForFetchRequest:request error:&error];
        }
        @catch (NSException *exception) {
            NSLog(@"Unable to count for fetch request %@: %@", request, (id)[exception userInfo] ?: (id)[exception reason]);
        }
        @finally {
            if (count == NSNotFound && error) {
                [TOMDataErrorHandler handleError:error];
            }
        }
    }];
    return count;
}

- (NSManagedObject *)existingObjectWithID:(NSManagedObjectID *)objectID
{
    __block NSManagedObject *object;
    [self performBlockAndWait:^{
        NSError *error = nil;
        @try {
            object = [self existingObjectWithID:objectID error:&error];
        }
        @catch (NSException *exception) {
            NSLog(@"Unable to fetch existing object with ID %@: %@", objectID, (id)[exception userInfo] ?: (id)[exception reason]);
        }
        @finally {
            if (!object && error) {
                [TOMDataErrorHandler handleError:error];
            }
        }
    }];
    return object;
}

#pragma mark -

- (void)performBlockWithPrivateContext:(void (^)(NSManagedObjectContext *))block completion:(void (^)())completion
{
    NSManagedObjectContext *privateContext = [[self class] childContextWithConcurrencyType:NSPrivateQueueConcurrencyType parentContext:self];
    [privateContext performBlock:^{
        if (block) {
            block(privateContext);
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    }];
}

- (void)performBlockWithPrivateContextAndWait:(void (^)(NSManagedObjectContext *))block
{
    NSManagedObjectContext *privateContext = [[self class] childContextWithConcurrencyType:NSPrivateQueueConcurrencyType parentContext:self];
    [privateContext performBlockAndWait:^{
        if (block) {
            block(privateContext);
        }
    }];
}

@end
