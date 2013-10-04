/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import <CouchbaseLite/CouchbaseLite.h>

@interface CBLAttachmentProxy : TiProxy

+(CBLAttachmentProxy *)proxyWithDelegate:(CBLAttachment *)delegate;
+(NSArray *)proxiesWithDelegates:(NSArray *)delegates;

@property (readonly) CBLAttachment * delegate;

@end
