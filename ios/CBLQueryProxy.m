/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "ThreadUtils.h"
#import "TitaniumUtils.h"
#import "CBLQueryProxy.h"
#import "CBLDatabaseProxy.h"
#import "CBLDocumentProxy.h"
#import "NSErrorProxy.h"

@implementation CBLQueryProxy
{
    NSThread * _thread;
}

-(id)initWithDelegate:(CBLQuery *)delegate
{
    if (self = [super init]) {
        _delegate = [delegate retain];
        _thread = [[NSThread currentThread] retain];
    }
    
    return self;
}

+(CBLQueryProxy *)proxyWithDelegate:(CBLQuery *)delegate
{
    return (delegate ? [[CBLQueryProxy alloc] initWithDelegate:delegate] : nil);
}

+(NSArray *)proxiesWithDelegates:(NSArray *)delegates
{
    NSMutableArray * proxies = [[NSMutableArray alloc] initWithCapacity:delegates.count];
    
    for (id delegate in delegates) {
        [proxies addObject:[CBLQueryProxy proxyWithDelegate:delegate]];
    }
    
    return proxies;
}

-(CBLDatabaseProxy *)database
{
    return invoke_block_on_thread(^id{
        return [CBLDatabaseProxy proxyWithDelegate:_delegate.database];
    }, _thread);
}

-(NSNumber *)limit
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithUnsignedInteger:_delegate.limit];
    }, _thread);
}

-(NSNumber *)skip
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithUnsignedInteger:_delegate.skip];
    }, _thread);
}

-(NSNumber *)isDescending
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithBool:_delegate.descending];
    }, _thread);
}

-(void)setIsDescending:(NSNumber *)descending
{
    void_block_on_thread(^{
        _delegate.descending = descending;
    }, _thread);
}

-(id)startKey
{
    return invoke_block_on_thread(^id{
        return _delegate.startKey;
    }, _thread);
}

-(void)setStartKey:(id)startKey
{
    void_block_on_thread(^{
        _delegate.startKey = startKey;
    }, _thread);
}

-(id)endKey
{
    return invoke_block_on_thread(^id{
        return _delegate.endKey;
    }, _thread);
}

-(void)setEndKey:(id)endKey
{
    void_block_on_thread(^{
        _delegate.endKey = endKey;
    }, _thread);
}

-(NSString *)startKeyDocID
{
    return invoke_block_on_thread(^id{
        return _delegate.startKeyDocID;
    }, _thread);
}

-(void)setStartKeyDocID:(NSString *)startKeyDocID
{
    void_block_on_thread(^{
        _delegate.startKeyDocID = startKeyDocID;
    }, _thread);
}

-(NSString *)endKeyDocID
{
    return invoke_block_on_thread(^id{
        return _delegate.endKeyDocID;
    }, _thread);
}

-(void)setEndKeyDocID:(NSString *)endKeyDocID
{
    void_block_on_thread(^{
        _delegate.endKeyDocID = endKeyDocID;
    }, _thread);
}

-(CBLStaleness)stale
{
    return invoke_block_on_thread(^id{
        return _delegate.stale;
    }, _thread);
}

-(void)setStale:(CBLStaleness)stale
{
    void_block_on_thread(^{
        _delegate.stale = stale;
    }, _thread);
}

-(NSArray *)keys
{
    return invoke_block_on_thread(^id{
        return _delegate.keys;
    }, _thread);
}

-(void)setKeys:(NSArray *)keys
{
    void_block_on_thread(^{
        _delegate.keys = keys;
    }, _thread);
}

-(NSNumber *)isMapOnly
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithBool:_delegate.mapOnly];
    }, _thread);
}

-(void)setIsMapOnly:(NSNumber *)mapOnly
{
    void_block_on_thread(^{
        _delegate.mapOnly = mapOnly.boolValue;
    }, _thread);
}

-(NSNumber *)groupLevel
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithUnsignedInteger:_delegate.groupLevel];
    }, _thread);
}

-(void)setGroupLevel:(NSNumber *)groupLevel
{
    void_block_on_thread(^{
        _delegate.groupLevel = groupLevel.unsignedIntValue;
    }, _thread);
}

-(NSNumber *)isPrefetch
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithBool:_delegate.prefetch];
    }, _thread);
}

-(void)setIsPrefetch:(NSNumber *)prefetch
{
    void_block_on_thread(^{
        _delegate.prefetch = prefetch.boolValue;
    }, _thread);
}

-(NSNumber *)isIncludeDeleted
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithBool:_delegate.includeDeleted];
    }, _thread);
}

-(void)setIsIncludeDeleted:(NSNumber *)includeDeleted
{
    void_block_on_thread(^{
        _delegate.includeDeleted = includeDeleted.boolValue;
    }, _thread);
}

-(NSErrorProxy *)error
{
    return invoke_block_on_thread(^id{
        return [NSErrorProxy proxyWithDelegate:_delegate.error];
    }, _thread);
}

-(CBLQueryEnumeratorProxy *)rows
{
    return invoke_block_on_thread(^id{
        return [CBLQueryEnumeratorProxy proxyWithDelegate:_delegate.rows];
    }, _thread);
}

-(CBLQueryEnumeratorProxy *)rowsIfChanged
{
    return invoke_block_on_thread(^id{
        return [CBLQueryEnumeratorProxy proxyWithDelegate:_delegate.rowsIfChanged];
    }, _thread);
}

-(void)runAsync:(id)args
{
    void_block_on_thread(^{
        KrollCallback * onCompleteCallback;
        ENSURE_ARG_AT_INDEX(onCompleteCallback, args, 0, KrollCallback);
        
        void (^block)(CBLQueryEnumerator * onComplete);
        if (onCompleteCallback) {
            block = ^void(CBLQueryEnumerator * onComplete) {
                CBLQueryEnumeratorProxy * queryEnumeratorProxy = [CBLQueryEnumeratorProxy proxyWithDelegate:onComplete];
                
                [self.executionContext.krollContext invokeBlockOnThread:^{
                    [onCompleteCallback call:[NSArray arrayWithObject:queryEnumeratorProxy] thisObject:nil];
                }];
            };
        }
        
        [_delegate runAsync:block];
    }, _thread);
}

-(CBLLiveQueryProxy *)toLiveQuery:(id)args
{
    return invoke_block_on_thread(^id{
        return [CBLLiveQueryProxy proxyWithDelegate:_delegate.asLiveQuery];
    }, _thread);
}

-(void)dealloc
{
    [_delegate release];
    [_thread release];
    
    [super dealloc];
}

@end


@implementation CBLLiveQueryProxy
{
    NSThread * _thread;
    NSMutableArray * _rowsChangeListeners;
}

-(id)initWithDelegate:(CBLLiveQuery *)delegate
{
    if (self = [super init]) {
        _delegate = [delegate retain];
        _thread = [[NSThread currentThread] retain];
        _rowsChangeListeners = [[NSMutableArray array] retain];
        
        [_delegate addObserver:self forKeyPath:@"rows" options:0 context:NULL];
    }
    
    [super _hasListeners:nil];
    
    return self;
}

+(CBLLiveQueryProxy *)proxyWithDelegate:(CBLLiveQuery *)delegate
{
    return (delegate ? [[CBLLiveQueryProxy alloc] initWithDelegate:delegate] : nil);
}

+(NSArray *)proxiesWithDelegates:(NSArray *)delegates
{
    NSMutableArray * proxies = [[NSMutableArray alloc] initWithCapacity:delegates.count];
    
    for (id delegate in delegates) {
        [proxies addObject:[CBLLiveQueryProxy proxyWithDelegate:delegate]];
    }
    
    return proxies;
}

-(void)start:(id)args
{
    void_block_on_thread(^{
        [_delegate start];
    }, _thread);
}

-(void)stop:(id)args
{
    void_block_on_thread(^{
        [_delegate stop];
    }, _thread);
}

-(CBLQueryEnumeratorProxy *)rows
{
    return invoke_block_on_thread(^id{
        return [CBLQueryEnumeratorProxy proxyWithDelegate:_delegate.rows];
    }, _thread);
}

-(NSNumber *)waitForRows:(id)args
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithBool:_delegate.waitForRows];
    }, _thread);
}

#pragma mark - EVENTS:

#define kCBLLiveQueryProxyChangeEvent @"change"

-(NSString *)CHANGE_EVENT
{
    return kCBLLiveQueryProxyChangeEvent;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == _delegate && [keyPath isEqualToString:@"rows"]) {
        TiThreadPerformOnMainThread(^{
            [self fireEvent:kCBLLiveQueryProxyChangeEvent withObject:@{@"property":keyPath} propagate:YES];
        }, NO);
    }
}

-(void)dealloc
{
    [_delegate removeObserver:self forKeyPath:@"rows"];
    
    [_delegate release];
    [_thread release];
    [_rowsChangeListeners release];
    
    [super dealloc];
}

@end


@implementation CBLQueryEnumeratorProxy
{
    NSThread * _thread;
}

-(id)initWithDelegate:(CBLQueryEnumerator *)delegate
{
    if (self = [super init]) {
        _delegate = [delegate retain];
        _thread = [[NSThread currentThread] retain];
    }
    
    return self;
}

+(CBLQueryEnumeratorProxy *)proxyWithDelegate:(CBLQueryEnumerator *)delegate
{
    return (delegate ? [[CBLQueryEnumeratorProxy alloc] initWithDelegate:delegate] : nil);
}

+(NSArray *)proxiesWithDelegates:(NSArray *)delegates
{
    NSMutableArray * proxies = [[NSMutableArray alloc] initWithCapacity:delegates.count];
    
    for (id delegate in delegates) {
        [proxies addObject:[CBLQueryEnumeratorProxy proxyWithDelegate:delegate]];
    }
    
    return proxies;
}

-(NSNumber *)count
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithUnsignedInteger:_delegate.count];
    }, _thread);
}

-(NSNumber *)sequenceNumber
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithUnsignedLongLong:_delegate.sequenceNumber];
    }, _thread);
}

-(CBLQueryRowProxy *)nextRow
{
    return invoke_block_on_thread(^id{
        return [CBLQueryRowProxy proxyWithDelegate:_delegate.nextRow];
    }, _thread);
}

- (id)rowAtIndex:(id)args
{
    return invoke_block_on_thread(^id{
        NSNumber * index;
        ENSURE_ARG_AT_INDEX(index, args, 0, NSNumber);
        
        return [CBLQueryRowProxy proxyWithDelegate:[_delegate rowAtIndex:index.unsignedIntValue]];
    }, _thread);
}

-(NSErrorProxy *)error
{
    return invoke_block_on_thread(^id{
        return [NSErrorProxy proxyWithDelegate:_delegate.error];
    }, _thread);
}

-(void)dealloc
{
    [_delegate release];
    [_thread release];
    
    [super dealloc];
}

@end


@implementation CBLQueryRowProxy
{
    NSThread * _thread;
}

-(id)initWithDelegate:(CBLQueryRow *)delegate
{
    if (self = [super init]) {
        _delegate = [delegate retain];
        _thread = [[NSThread currentThread] retain];
    }
    
    return self;
}

+(CBLQueryRowProxy *)proxyWithDelegate:(CBLQueryRow *)delegate
{
    return (delegate ? [[CBLQueryRowProxy alloc] initWithDelegate:delegate] : nil);
}

+(NSArray *)proxiesWithDelegates:(NSArray *)delegates
{
    NSMutableArray * proxies = [[NSMutableArray alloc] initWithCapacity:delegates.count];
    
    for (id delegate in delegates) {
        [proxies addObject:[CBLQueryRowProxy proxyWithDelegate:delegate]];
    }
    
    return proxies;
}

-(id)key
{
    return invoke_block_on_thread(^id{
        return _delegate.key;
    }, _thread);
}

-(id)value
{
    return invoke_block_on_thread(^id{
        return _delegate.value;
    }, _thread);
}

-(NSString *)documentId
{
    return invoke_block_on_thread(^id{
        return _delegate.documentID;
    }, _thread);
}

-(NSString *)sourceDocumentId
{
    return invoke_block_on_thread(^id{
        return _delegate.sourceDocumentID;
    }, _thread);
}

-(NSString *)documentRevisionId
{
    return invoke_block_on_thread(^id{
        return _delegate.documentRevision;
    }, _thread);
}

-(CBLDocumentProxy *)document
{
    return invoke_block_on_thread(^id{
        return [CBLDocumentProxy proxyWithDelegate:_delegate.document];
    }, _thread);
}

-(NSDictionary *)documentProperties
{
    return invoke_block_on_thread(^id{
        return _delegate.documentProperties;
    }, _thread);
}

-(id)getKeyAtIndex:(id)args
{
    return invoke_block_on_thread(^id{
        NSNumber * index;
        ENSURE_ARG_AT_INDEX(index, args, 0, NSNumber);
        
        return [_delegate keyAtIndex:index.unsignedIntegerValue];
    }, _thread);
}

-(id)key0
{
    return invoke_block_on_thread(^id{
        return _delegate.key0;
    }, _thread);
}

-(id)key1
{
    return invoke_block_on_thread(^id{
        return _delegate.key1;
    }, _thread);
}

-(id)key2
{
    return invoke_block_on_thread(^id{
        return _delegate.key2;
    }, _thread);
}

-(id)key3
{
    return invoke_block_on_thread(^id{
        return _delegate.key3;
    }, _thread);
}

-(NSNumber *)localSequence
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithUnsignedLongLong:_delegate.localSequence];
    }, _thread);
}

-(void)dealloc
{
    [_delegate release];
    [_thread release];
    
    [super dealloc];
}

@end