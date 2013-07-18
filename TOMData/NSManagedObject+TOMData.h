//
//  NSManagedObject+TOMData.h
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 The `NSManagedObject(TOMData)` category extends `NSManagedObject` with a set of utility methods.
 
 ### Subclassing Notes
 
 If the entity name in your managed object model is different than current class name, you should override the `entityName` method and return the appropriate name.
 
 */
@interface NSManagedObject (TOMData)

/// ------------------------------
/// @name Creating Managed Objects
/// ------------------------------

/**
 Creates a new managed object in specified context.
 
 @param context Managed object context to create the object in.
 
 @return An initialized `NSManagedObject` instance.
 */
+ (instancetype)tom_newObjectInContext:(NSManagedObjectContext *)context;

/**
 Deletes the receiver from its managed object context.
 */
- (void)tom_deleteObject;

/// --------------------------------
/// @name Getting Object Information
/// --------------------------------

/**
 Return current instance representation in a different context.
 
 @param context Managed object context to obtain the current instance in.
 
 @return A `NSManagedObject` instance or `nil` if it does not exist in *context*.
 */
- (id)tom_inContext:(NSManagedObjectContext *)context;

/**
 Return managed object model for curent instance.
 
 @return A `NSManagedObjectModel` instance.
 */
- (NSManagedObjectModel *)tom_managedObjectModel;

/**
 Returns the entity name in managed object model represented by the current `NSManagedObject` subclass. Override this method to return the entity name if different than your `NSMAnagedObject` subclass name.
 
 @return A `NSString` instance.
 */
+ (NSString *)tom_entityName;


/**
 Returns the entity description represented by the current `NSManagedObject` subclass.
 
 @return A `NSEntityDescription` instance.
 */
+ (NSEntityDescription *)tom_entityDescriptionInContext:(NSManagedObjectContext *)context;

/// -----------------------------
/// @name Creating Fetch Requests
/// -----------------------------

/**
 Creates a new fetch request configured with entity name obtained from `entityName` method.
 
 @return An initalized `NSFetchRequest` object.
 */
+ (NSFetchRequest *)tom_request;

/**
 Creates a new fetch request configured with specified predicate, sort descriptors and entity name obtained from `entityName` method.
 
 @param predicate Predicate for the fetch request.
 @param sortDescriptors Sort descriptors for fetch request.
 
 @return An initalized `NSFetchRequest` object.
 */
+ (NSFetchRequest *)tom_requestWithPredicate:(NSPredicate *)predicate
                             sortDescriptors:(NSArray *)sortDescriptors;

/// ----------------------------------------
/// @name Creating Fetch Results Controllers
/// ----------------------------------------

/**
 Creates a new fetch results controller configured with specified arguments
 
 @param predicate Predicate for the fetched results controller request.
 @param sortDescriptors Sort descriptors for the fetched results controller request.
 @param sectionNameKeyPath A key path on result objects that returns the section name. Pass `nil` to indicate that the controller should generate a single section.
 @param cacheName The name of the cache file the receiver should use. Pass `nil` to prevent caching.
 @param context The managed object context against which *fetchRequest* is executed.
 
 @return An initalized `NSFetchedResultsController` object.
 */
+ (NSFetchedResultsController *)tom_controllerWithPredicate:(NSPredicate *)predicate
                                    		  sortDescriptors:(NSArray *)sortDescriptors
                                         sectionNameKeyPath:(NSString *)sectionNameKeyPath
                                                  cacheName:(NSString *)cacheName
                                                   delegate:(id<NSFetchedResultsControllerDelegate>)delegate
                                                    context:(NSManagedObjectContext *)context;

@end
