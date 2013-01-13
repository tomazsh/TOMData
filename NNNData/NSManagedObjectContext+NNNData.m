//
//  NSManagedObjectContext+NNNData.m
//  NNNData
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

#import "NNNDataErrorHandler.h"
#import "NSManagedObjectContext+NNNData.h"

@implementation NSManagedObjectContext (NNData)

#pragma mark -
#pragma mark Class Methods

+ (NSManagedObjectContext *)rootContext
{
    static NSManagedObjectContext *RootContext = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RootContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [RootContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    });
    return RootContext;
}

+ (NSManagedObjectContext *)mainContext
{    
    static NSManagedObjectContext *MainContext = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [MainContext setParentContext:[self rootContext]];
    });
    return MainContext;
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

- (BOOL)nnn_save
{
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
            [NNNDataErrorHandler handleError:error];
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
        saved = [self nnn_save];
    }];
    
    __weak NSManagedObjectContext *rootContext = [[self class] rootContext];
    if ([self parentContext] == rootContext) {
        [rootContext performBlockAndWait:^{
            saved = saved && [rootContext nnn_save];
        }];
    }
    
    return saved;
}

- (BOOL)saveWithParentContext
{
    BOOL saved  = [self save];
    if ([self parentContext] != [[self class] rootContext]) {
        saved = saved && [[self parentContext] save];
    }
    return saved;
}

- (BOOL)saveWithParentContexts
{
    BOOL saved = [self save];
    if ([self parentContext] != [[self class] rootContext]) {
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
                [NNNDataErrorHandler handleError:error];
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
                [NNNDataErrorHandler handleError:error];
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
                [NNNDataErrorHandler handleError:error];
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