//
//  TOMDataErrorHandler.m
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

@interface TOMDataErrorHandler ()

+ (instancetype)sharedHandler;

@property (weak, nonatomic) id target;
@property (nonatomic) SEL action;
@property (copy, nonatomic) TOMDataErrorHandlingBlock block;

@end

@implementation TOMDataErrorHandler

#pragma mark -
#pragma mark Class Methods

+ (void)setTarget:(id)target action:(SEL)action
{
    [[self sharedHandler] setTarget:target];
    [[self sharedHandler] setAction:action];
}

+ (void)setBlock:(TOMDataErrorHandlingBlock)block
{
    [[self sharedHandler] setBlock:block];
}

+ (void)handleError:(NSError *)error
{
    if (!error) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *errorCopy = [error copy];
        TOMDataErrorHandler *handler = [[self class] sharedHandler];
        
        if (handler.target && handler.action) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [handler.target performSelector:handler.action withObject:errorCopy];
#pragma clang diagnostic pop
        }
            
        if (handler.block) {
            handler.block(errorCopy);
        }
            
        if ((!handler.target || !handler.action) && !handler.block) {
            NSLog(@"Core Data Error: %@ %@", [error localizedDescription], [error userInfo]);
        }
    });
}

#pragma mark -
#pragma mark Private Class Methods

+ (instancetype)sharedHandler
{
    static TOMDataErrorHandler *SharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SharedHandler = [TOMDataErrorHandler new];
    });
    return SharedHandler;
}

@end
