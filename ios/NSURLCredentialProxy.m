/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "NSURLCredentialProxy.h"

@implementation NSURLCredentialProxy

-(id)initWithDelegate:(NSURLCredential *)delegate
{
    if (self = [super init]) {
        _delegate = [delegate retain];
    }
    
    return self;
}

+(NSURLCredentialProxy *)proxyWithDelegate:(NSURLCredential *)delegate
{
    return (delegate ? [[NSURLCredentialProxy alloc] initWithDelegate:delegate] : nil);
}

+(NSArray *)proxiesWithDelegates:(NSArray *)delegates
{
    NSMutableArray * proxies = [[NSMutableArray alloc] initWithCapacity:delegates.count];
    
    for (id delegate in delegates) {
        [proxies addObject:[NSURLCredentialProxy proxyWithDelegate:delegate]];
    }
    
    return proxies;
}
@end
