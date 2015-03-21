//
//  TOMDataErrorHandler.h
//  TOMData
//
//  Copyright (c) 2015 Tomaz Nedeljko (http://nedeljko.com)
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

typedef void(^TOMDataErrorHandlingBlock)(NSError *error);

/**
 The `TOMDataErrorHandler` is a utility class that enables you to define a single point for handling Core Data errors. It enables you to define an action on a target or a block to be executed when the error occurs.
 */
@interface TOMDataErrorHandler : NSObject 

///----------------------
/// @name Handling Errors
///----------------------

/**
 Sets target to handle the error and a selector to be performed on `target` on main thread when an error occurs.
 
 @param target Target that will handle the error.
 @param selector Selector to be performed on `target` when an error occurs. It takes a `NSError` as the sole argument.
 */
+ (void)setTarget:(id)target selector:(SEL)selector;

/**
 Sets block to be executed on main thread when an error occurs.
 
 @param block A block to be executed when an error occurs. It takes the error as the sole parameter.
 */
+ (void)setBlock:(TOMDataErrorHandlingBlock)block;

/**
 Handles an error. This method performs the action on the target you have specified through the `setTarget:action:` method. It also executes the block you've set through the `setBlock:` method. If you haven't speficied either, it logs the error.
 
 @param block A `NSError` object to be handled by the receiver.
 */
+ (void)handleError:(NSError *)error;

@end
