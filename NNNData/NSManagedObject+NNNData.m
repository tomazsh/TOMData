//
//  NSManagedObject+NNNData.m
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
#import "NSManagedObject+NNNData.h"
#import "NSManagedObjectContext+NNNData.h"

@implementation NSManagedObject (NNNData)

#pragma mark -
#pragma mark Class Methods

+ (id)newObjectInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

+ (NSString *)entityName
{
    return NSStringFromClass(self);
}

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
}

+ (NSFetchRequest *)request
{
    return [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
}

+ (NSFetchRequest *)requestWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors
{
    NSFetchRequest *request = [self request];
    [request setPredicate:predicate];
    [request setSortDescriptors:sortDescriptors];
    return request;
}

+ (NSFetchedResultsController *)controllerWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors sectionNameKeyPath:(NSString *)sectionNameKeyPath cacheName:(NSString *)cacheName delegate:(id<NSFetchedResultsControllerDelegate>)delegate inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self requestWithPredicate:predicate sortDescriptors:sortDescriptors];
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:sectionNameKeyPath cacheName:cacheName];
    controller.delegate = delegate;
    return controller;
}

#pragma mark -
#pragma mark Instance Methods

- (void)deleteObject
{
    [[self managedObjectContext] deleteObject:self];
}

- (id)inContext:(NSManagedObjectContext *)context
{
    return [context objectWithID:[self objectID]];
}

- (NSManagedObjectModel *)managedObjectModel
{
    return [[self managedObjectContext] managedObjectModel];
}

@end
