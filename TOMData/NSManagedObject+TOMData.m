//
//  NSManagedObject+TOMData.m
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
#import "NSManagedObject+TOMData.h"
#import "NSManagedObjectContext+TOMData.h"

@implementation NSManagedObject (TOMData)

#pragma mark -
#pragma mark Class Methods

+ (instancetype)tom_newObjectInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self tom_entityName] inManagedObjectContext:context];
}

+ (NSString *)tom_entityName
{
    return NSStringFromClass(self);
}

+ (NSEntityDescription *)tom_entityDescriptionInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription entityForName:[self tom_entityName] inManagedObjectContext:context];
}

+ (NSFetchRequest *)tom_request
{
    return [NSFetchRequest fetchRequestWithEntityName:[self tom_entityName]];
}

+ (NSFetchRequest *)tom_requestWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors
{
    NSFetchRequest *request = [self tom_request];
    [request setPredicate:predicate];
    [request setSortDescriptors:sortDescriptors];
    return request;
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED

+ (NSFetchedResultsController *)tom_controllerWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors sectionNameKeyPath:(NSString *)sectionNameKeyPath cacheName:(NSString *)cacheName delegate:(id<NSFetchedResultsControllerDelegate>)delegate context:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self tom_requestWithPredicate:predicate sortDescriptors:sortDescriptors];
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:sectionNameKeyPath cacheName:cacheName];
    controller.delegate = delegate;
    return controller;
}

#endif

#pragma mark -
#pragma mark Instance Methods

- (void)tom_deleteObject
{
    [[self managedObjectContext] deleteObject:self];
}

- (id)tom_inContext:(NSManagedObjectContext *)context
{
    return [context objectWithID:[self objectID]];
}

- (NSManagedObjectModel *)tom_managedObjectModel
{
    return [[self managedObjectContext] tom_managedObjectModel];
}

@end
