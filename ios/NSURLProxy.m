/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "NSURLProxy.h"

@implementation NSURLProxy

-(id)initWithDelegate:(NSURL *)delegate
{
    if (self = [super init]) {
        _delegate = [delegate retain];
    }
    
    return self;
}

+(NSURLProxy *)proxyWithDelegate:(NSURL *)delegate
{
    return (delegate ? [[NSURLProxy alloc] initWithDelegate:delegate] : nil);
}

+(NSArray *)proxiesWithDelegates:(NSArray *)delegates
{
    NSMutableArray * proxies = [[NSMutableArray alloc] initWithCapacity:delegates.count];
    
    for (id delegate in delegates) {
        [proxies addObject:[NSURLProxy proxyWithDelegate:delegate]];
    }
    
    return proxies;
}

-(NSString *)absoluteString
{
    return _delegate.absoluteString;
}

-(NSString *)relativeString
{
    return _delegate.relativeString;
}

-(NSURLProxy *)baseURL
{
    return [NSURLProxy proxyWithDelegate:_delegate.baseURL];
}

-(NSURLProxy *)absoluteURL
{
    return [NSURLProxy proxyWithDelegate:_delegate.absoluteURL];
}

@end
