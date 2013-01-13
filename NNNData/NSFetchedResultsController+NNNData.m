//
//  NSFetchedResultsController+NNNData.m
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

#import "NSFetchedResultsController+NNNData.h"
#import "NNNDataErrorHandler.h"

@implementation NSFetchedResultsController (NNNData)

- (BOOL)performFetch
{
    __block BOOL fetched;
    [[self managedObjectContext] performBlockAndWait:^{
        NSError *error = nil;
        @try {
            fetched = [self performFetch:&error];
        }
        @catch (NSException *exception) {
            NSLog(@"Unable to perform fetch: %@", (id)[exception userInfo] ?: (id)[exception reason]);
        }
        @finally {
            if (!fetched && error) {
                [NNNDataErrorHandler handleError:error];
            }
        }
    }];
    return fetched;
}

- (void)performFetchCompleted:(void (^)(BOOL success))completed
{
    [[self managedObjectContext] performBlock:^{
        NSError *error = nil;
        BOOL fetched = NO;
        @try {
            fetched = [self performFetch:&error];
        }
        @catch (NSException *exception) {
            NSLog(@"Unable to perform fetch: %@", (id)[exception userInfo] ?: (id)[exception reason]);
        }
        @finally {
            if (!fetched && error) {
                [NNNDataErrorHandler handleError:error];
            }
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (completed) {
                completed(fetched);
            }
        });
    }];
}

@end
