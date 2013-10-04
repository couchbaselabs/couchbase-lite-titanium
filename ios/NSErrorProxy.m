/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "NSErrorProxy.h"

@implementation NSErrorProxy

-(id)initWithDelegate:(NSError *)delegate {
    if (self = [super init]) {
        _delegate = [delegate retain];
    }
    
    return self;
}

+(NSErrorProxy *)proxyWithDelegate:(NSError *)delegate
{
    return (delegate ? [[NSErrorProxy alloc] initWithDelegate:delegate] : nil);
}

+(NSArray *)proxiesWithDelegates:(NSArray *)delegates
{
    NSMutableArray * proxies = [[NSMutableArray alloc] initWithCapacity:delegates.count];
    
    for (id delegate in delegates) {
        [proxies addObject:[NSErrorProxy proxyWithDelegate:delegate]];
    }
    
    return proxies;
}

-(NSString *)domain
{
    return _delegate.domain;
}

-(NSNumber *)code
{
    return _delegate.code;
}

-(NSDictionary *)userInfo
{
    return _delegate.userInfo;
}

-(NSString *)localizedDescription
{
    return _delegate.localizedDescription;
}

-(NSString *)localizedFailureReason
{
    return _delegate.localizedFailureReason;
}

-(NSString *)localizedRecoverySuggestion
{
    return _delegate.localizedRecoverySuggestion;
}

-(NSArray *)localizedRecoveryOptions
{
    return _delegate.localizedRecoveryOptions;
}

-(NSString *)helpAnchor
{
    return _delegate.helpAnchor;
}

-(void)dealloc
{
    [_delegate release];
    
    [super dealloc];
}

@end
