//
//  NSFetchedResultsController+NNNData.h
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 The `NSFetchedResultsController(NNNData)` category extends `NSFetchedResultsController` with a set of utility methods.
 */
@interface NSFetchedResultsController (NNNData)

///---------------
/// @name Fetching
///---------------

/**
 Executes the receiver’s fetch request. If the fetch is not successful it handles the error through `NNNDataHelper` registered error handler.
 
 @return `YES` if the fetch executed successfully, otherwise `NO`.
*/
- (BOOL)performFetch;

/**
 Asynchronously executes the receiver’s fetch request. If the fetch is not successful it handles the error through `NNNDataHelper` registered error handler.
 
 @param completed A block object to be executed when the fetch finishes. This block has no return value and takes one argument: a boolean value, indicating if fetch was successful.
 */
- (void)performFetchCompleted:(void (^)(BOOL success))completed;

@end
