//
//  NSManagedObjectContext+TOMData.h
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
 The `NSManagedObjectContext(TOMData)` category extends `NSManagedObjectContext` with a set of utility methods.
 
 ### Using the Predefined Managed Object Contexts
 
 You can utilize the `rootContext` as the base context for your app by assigning it a persistent store coordinator. Root context should primarily be used for direct interaction with persistent stores. Because it uses a private queue, every save to persistent store is done on a separate thread.
 
 For main queue interaction you can utilize the `mainContext`, which is a direct child of `rootContext` that operates on main queue. You will probably be interactiong with this context the most as it should be used for all user interface operations. Saving `mainContext` does however not automatically persist changes. To save changes to your persistent stores, be sure to use `saveWithParentContext` or `saveWithParentContexts` methods.
 
 */
@interface NSManagedObjectContext (TOMData)

///-------------------------------------------
/// @name Interacting with Predefined Contexts
///-------------------------------------------

/**
 Returns the predefined root managed object context. This context serves for saving to persistent store from a private queue.
 
 @warning Before using this context, you should set its persistent store coordinator with `setPersistentStoreCoordinator` method.
 
 @return A `NSManagedObjectContext` instance.
 */
+ (NSManagedObjectContext *)tom_rootContext;

/**
 Returns the predefined default managed object context. You should use this context for all your main queue operations. If you need another managed object context that runs on the main queue, use `childContextWithDefaultContext` method to create one.
 
 @warning The default context has *rootContext* set as its parent. Before using  *defaultContext*, you should set *rootContext*'s persistent store coordinator with `setPersistentStoreCoordinator` method.
 
 @return A `NSManagedObjectContext` instance.
 */
+ (NSManagedObjectContext *)tom_mainContext;

/**
 Allocates and initializes a new managed object context with the `NSPrivateQueueConcurrencyType` type and *defaultContext* as the parent context.
  
 @warning The newly initialized context also has *rootContext* set as its parent. You should not use this method for creating contexts if you haven't set *rootContext*'s persistent store coordinator.
 
 @return A newly initialized `NSManagedObjectContext` instance.
 */
+ (NSManagedObjectContext *)tom_childContextWithMainContext;

///---------------------------------------
/// @name Creating Managed Object Contexts
///---------------------------------------

/**
 Allocates and initializes a new managed object context with the specified concurrency type and parent context.
 
 @param type Concurrency type for the managed object context.
 @param type Parent context for the managed object context.
 
 @return A newly initialized `NSManagedObjectContext` instance.
 */
+ (NSManagedObjectContext *)tom_childContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)type
                                                  parentContext:(NSManagedObjectContext *)parentContext;

///--------------------------------------------------
/// @name Accessing Managed Object Context Properties
///--------------------------------------------------

/**
 Returns managed object model from the receiver's persistent store coordinator.
 
 @return A `NSManagedObjectModel` instance.
 */
- (NSManagedObjectModel *)tom_managedObjectModel;

///---------------------
/// @name Saving Changes
///---------------------

/**
 Attempts to commit unsaved changes to registered objects to their persistent store and handles an error if one occurs.
  
 @return `YES` if the save succeeds, otherwise `NO`.
 */
- (BOOL)tom_save;

/**
 Attempts to commit unsaved changes to registered objects to their persistent store for the receiver and its first parent (if one exists) and handles errors if they occur.
 
 @return `YES` if saves to the receiver and its parent succeed, otherwise `NO`.
 */
- (BOOL)tom_saveWithParentContext;

/**
 Attempts to commit unsaved changes to registered objects to their persistent store for the receiver and all its parents and handles errors if they occur.
 
 @return `YES` if saves to the receiver and all its parents succeed, otherwise `NO`.
 */
- (BOOL)tom_saveWithParentContexts;

///-----------------------
/// @name Fetching Objects
///-----------------------

/**
 Returns an array of objects that meet the criteria specified by a given fetch request and handles an error if one occurs.
 
 @param request A fetch request that specifies the search criteria for the fetch.

 @return An array of objects that meet the criteria specified by request fetched from the receiver and from the persistent stores associated with the receiver’s persistent store coordinator. If an error occurs, returns `nil`. If no objects match the criteria specified by request, returns an empty array.
 */
- (NSArray *)tom_executeFetchRequest:(NSFetchRequest *)request;

/**
 Returns the number of objects a given fetch request would have returned if it had been passed to `executeFetchRequest:`.
 
 @param request A fetch request that specifies the search criteria for the fetch.
 
 @return The number of objects a given fetch request would have returned if it had been passed to `executeFetchRequest:error:`, or `NSNotFound` if an error occurs.
 */
- (NSUInteger)tom_countForFetchRequest:(NSFetchRequest *)request;

/**
 Returns the object for the specified ID and handles an error if one occurs.
 
 @param objectID The object ID for the requested object.
 
 @return The object specified by *objectID*. If the object cannot be fetched, or does not exist, or cannot be faulted, it returns `nil`.
 */
- (NSManagedObject *)tom_existingObjectWithID:(NSManagedObjectID *)objectID;

///-------------------------------------------
/// @name Performing Actions on Private Queues
///-------------------------------------------

/**
 Performs a block asynchronously on a separate thread with a private context.
 
 @param block A block to be executed on the private thread. This block has no return type and takes the private queue managed object context as its sole parameter.
 @param completion A block to be executed on the main thread after the *block* is completed. This block has no return type and takes no parameters.
 */
- (void)tom_performBlockWithPrivateContext:(void (^)(NSManagedObjectContext *))block
                                completion:(void (^)())completion;

/**
 Performs a block synchronously on a separate thread with a private context.
 
 @param block A block to be executed on the private thread. This block has no return type and takes the private queue managed object context as its sole parameter.
 */
- (void)tom_performBlockWithPrivateContextAndWait:(void (^)(NSManagedObjectContext *))block;

@end
