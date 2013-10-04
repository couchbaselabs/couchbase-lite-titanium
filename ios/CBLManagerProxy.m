/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TitaniumUtils.h"
#import "ThreadUtils.h"
#import "CBLManagerProxy.h"
#import "CBLDatabaseProxy.h"
#import "NSErrorProxy.h"

@interface CBLManagerProxyCreateArgs : NSObject

@property (readwrite) CBLManagerDelegateBlock delegateBlock;
@property (readwrite,assign) CBLManagerProxy * proxy;

@end
@implementation CBLManagerProxyCreateArgs @end


@implementation CBLManagerProxy
{
    NSThread * _thread;
    BOOL _closed;
}

-(id)initWithDelegate:(CBLManager *)delegate
{
    if (self = [super init]) {
        _delegate = [delegate retain];
        _thread = [[NSThread currentThread] retain];
    }
    
    return self;
}

+(CBLManagerProxy *)proxyWithDelegateBlock:(CBLManagerDelegateBlock)delegateBlock onNewThread:(BOOL)onNewThread
{
    CBLManagerProxyCreateArgs * createArgs = [[CBLManagerProxyCreateArgs alloc] init];
    createArgs.delegateBlock = delegateBlock;
    
    if (onNewThread) {
        NSThread * createThread = [[NSThread alloc] initWithTarget:CBLManagerProxy.class selector:@selector(proxyWithCreateArgs:) object:createArgs];
        createThread.name = @"CouchbaseLite";
        [createThread start];
        
        while (!createArgs.proxy) {
            [NSThread sleepForTimeInterval:0.1f];
        }
    } else {
        createArgs.proxy = [CBLManagerProxy proxyWithDelegate:createArgs.delegateBlock()];
    }
    
    return createArgs.proxy;
}

+(void)proxyWithCreateArgs:(CBLManagerProxyCreateArgs *)createArgs
{
    createArgs.proxy = [CBLManagerProxy proxyWithDelegate:createArgs.delegateBlock()];
    [createArgs.proxy runCurrentRunLoop];
}

+(CBLManagerProxy *)proxyWithDelegate:(CBLManager *)delegate
{
    return (delegate ? [[CBLManagerProxy alloc] initWithDelegate:delegate] : nil);
}

+(NSArray *)proxiesWithDelegates:(NSArray *)delegates
{
    NSMutableArray * proxies = [[NSMutableArray alloc] initWithCapacity:delegates.count];
    
    for (id delegate in delegates) {
        [proxies addObject:[CBLManagerProxy proxyWithDelegate:delegate]];
    }
    
    return proxies;
}

-(void)runCurrentRunLoop
{
    while (!_closed) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

// NOTE: Defined in Module
//+ (instancetype) sharedInstance;
//
//+ (BOOL) isValidDatabaseName: (NSString*)name;
//
//- (instancetype) init;
//
//- (instancetype) initWithDirectory: (NSString*)directory
//                           options: (const CBLManagerOptions*)options
//                             error: (NSError**)outError;

// TODO: Needed?
//+ (NSString*) defaultDirectory;

-(void)close:(id)args
{
    void_block_on_thread(^{
        [_delegate close];
        _closed = YES;
    }, _thread);
}

-(NSString *)directory
{
    return invoke_block_on_thread(^id{
        return _delegate.directory;
    }, _thread);
}

-(CBLDatabaseProxy *)getDatabase:(id)args
{
    return invoke_block_on_thread(^id{
        NSString * name;
        ENSURE_ARG_OR_NIL_AT_INDEX(name, args, 0, NSString);
        
        NSError * error;
        CBLDatabase * database = [_delegate databaseNamed:name error:&error];
        
        if (!database) {
            [TitaniumUtils throwError:error withProxy:self];
        }
        
        return [CBLDatabaseProxy proxyWithDelegate:database];
    }, _thread);
}

-(CBLDatabaseProxy *)createDatabase:(id)args
{
    return invoke_block_on_thread(^id{
        NSString * name;
        ENSURE_ARG_OR_NIL_AT_INDEX(name, args, 0, NSString);
        
        NSError * error;
        CBLDatabase * database = [_delegate createDatabaseNamed:name error:&error];
        
        if (!database) {
            [TitaniumUtils throwError:error withProxy:self];
        }
        
        return [CBLDatabaseProxy proxyWithDelegate:database];
    }, _thread);
}

-(NSArray *)allDatabaseNames
{
    return invoke_block_on_thread(^id{
        return _delegate.allDatabaseNames;
    }, _thread);
}

-(NSNumber *)replaceDatabase:(id)args
{
    return invoke_block_on_thread(^id{
        NSString * databaseName;
        ENSURE_ARG_OR_NIL_AT_INDEX(databaseName, args, 0, NSString);
        NSString * databasePath;
        ENSURE_ARG_OR_NIL_AT_INDEX(databasePath, args, 1, NSString);
        NSString * attachmentsPath;
        ENSURE_ARG_OR_NIL_AT_INDEX(attachmentsPath, args, 2, NSString);
        
        NSError * error;
        BOOL result = [NSNumber numberWithBool:[_delegate replaceDatabaseNamed:databaseName
                                                              withDatabaseFile:databasePath
                                                               withAttachments:attachmentsPath
                                                                         error:&error]];
        
        if (!result) {
            [TitaniumUtils throwError:error withProxy:self];
        }
        
        return [NSNumber numberWithBool:result];
    }, _thread);
}

-(void)runAsync:(id)args
{
    void_block_on_thread(^{
        NSString * dbName;
        ENSURE_ARG_AT_INDEX(dbName, args, 0, NSString);
        KrollCallback * callback;
        ENSURE_ARG_AT_INDEX(callback, args, 1, KrollCallback);
        
        void (^block)(CBLDatabase * database);
        if (callback) {
            block = ^void(CBLDatabase * database) {
                CBLDatabaseProxy * databaseProxy = [CBLDatabaseProxy proxyWithDelegate:database];
                
                [self.executionContext.krollContext invokeBlockOnThread:^{
                    [callback call:[NSArray arrayWithObject:databaseProxy] thisObject:nil];
                }];
            };
        }
        
        [_delegate asyncTellDatabaseNamed:dbName to:block];
    }, _thread);
}

-(NSString *)internalUrl
{
    return invoke_block_on_thread(^id{
        return _delegate.internalURL.absoluteString;
    }, _thread);
}

// NOT NEEDED: Same as -databaseNamed:. Enables "[]" access in Xcode 4.4+
//- (CBLDatabase*) objectForKeyedSubscript: (NSString*)key;

-(void)dealloc
{
    [_delegate release];
    [_thread release];
    
    [super dealloc];
}

@end


// NOTE: Defined in Module
//extern NSString* CBLVersionString( void );

// NOTE: Defined in Module
//extern NSString* const CBLHTTPErrorDomain;
