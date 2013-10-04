/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "ThreadUtils.h"
#import "TitaniumUtils.h"
#import "CBLModelProxy.h"
#import "CBLDocumentProxy.h"
#import "CBLDatabaseProxy.h"
#import "CBLAttachmentProxy.h"
#import "NSErrorProxy.h"

@implementation CBLModelProxy
{
    NSThread * _thread;
}

-(id)initWithDelegate:(CBLModel *)delegate
{
    if (self = [super init]) {
        _delegate = [delegate retain];
        _thread = [[NSThread currentThread] retain];
    }
    
    return self;
}

+(CBLModelProxy *)proxyWithDelegate:(CBLModel *)delegate
{
    return (delegate ? [[CBLModelProxy alloc] initWithDelegate:delegate] : nil);
}

+(NSArray *)proxiesWithDelegates:(NSArray *)delegates
{
    NSMutableArray * proxies = [[NSMutableArray alloc] initWithCapacity:delegates.count];
    
    for (id delegate in delegates) {
        [proxies addObject:[CBLModelProxy proxyWithDelegate:delegate]];
    }
    
    return proxies;
}

// NOTE: Defined in Document.
//+ (instancetype) modelForDocument: (CBLDocument*)document;

// NOTE: Defined in Module
//- (instancetype) initWithNewDocumentInDatabase: (CBLDatabase*)database;

// NOTE: Defined in Module
//- (instancetype) init;

-(CBLDocumentProxy *)document
{
    return [CBLDocumentProxy proxyWithDelegate:_delegate.document];
}

-(CBLDatabaseProxy *)database
{
    return invoke_block_on_thread(^id{
        return [CBLDatabaseProxy proxyWithDelegate:_delegate.database];
    }, _thread);
}

-(void)setDatabase:(CBLDatabaseProxy *)database
{
    void_block_on_thread(^{
        _delegate.database = database.delegate;
    }, _thread);
}

-(NSNumber *)isNew
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithBool:_delegate.isNew];
    }, _thread);
}

#pragma mark - SAVING:

-(NSNumber *)save:(id)args
{
    return invoke_block_on_thread(^id{
        NSError * error;
        id result = [NSNumber numberWithBool:[_delegate save:&error]];
        
        if (!result) {
            [TitaniumUtils throwError:error withProxy:self];
        }
        
        return result;
    }, _thread);
}

-(NSNumber *)autosaves
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithBool:_delegate.autosaves];
    }, _thread);
}

-(void)setAutosaves:(NSNumber *)autosaves
{
    void_block_on_thread(^{
        _delegate.autosaves = autosaves.boolValue;
    }, _thread);
}

-(NSNumber *)autosaveDelay
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithDouble:_delegate.autosaveDelay];
    }, _thread);
}

-(NSNumber *)needsSave
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithBool:_delegate.needsSave];
    }, _thread);
}

-(NSDictionary *)propertiesToSave:(id)args
{
    return invoke_block_on_thread(^id{
        return [_delegate propertiesToSave];
    }, _thread);
}

-(NSNumber *)deleteDocument:(id)args
{
    return invoke_block_on_thread(^id{
        NSError * error;
        id result = [NSNumber numberWithBool:[_delegate deleteDocument:&error]];
        
        if (!result) {
            [TitaniumUtils throwError:error withProxy:self];
        }
        
        return result;
    }, _thread);
}

-(NSNumber *)timeSinceExternallyChanged
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithDouble:_delegate.timeSinceExternallyChanged];
    }, _thread);
}

// NOTE: Defined in Database.
//+ (BOOL) saveModels: (NSArray*)models error: (NSError**)outError;

-(void)markExternallyChanged:(id)args
{
    void_block_on_thread(^{
        [_delegate markExternallyChanged];
    }, _thread);
}

#pragma mark - PROPERTIES & ATTACHMENTS:

-(id)getValueOfProperty:(id)args
{
    return invoke_block_on_thread(^id{
        NSString * property;
        ENSURE_ARG_OR_NIL_AT_INDEX(property, args, 0, NSString);
        
        return [_delegate getValueOfProperty:property];
    }, _thread);
}

-(NSNumber *)setValueOfProperty:(id)args
{
    return invoke_block_on_thread(^id{
        id value = args[0];
        NSString * property;
        ENSURE_ARG_OR_NIL_AT_INDEX(property, args, 1, NSString);
        
        return [NSNumber numberWithBool:[_delegate setValue:value ofProperty:property]];
    }, _thread);
}

-(NSArray *)attachmentNames
{
    return invoke_block_on_thread(^id{
        return _delegate.attachmentNames;
    }, _thread);
}

-(CBLAttachmentProxy *)attachmentNamed:(id)args
{
    return invoke_block_on_thread(^id{
        NSString * name;
        ENSURE_ARG_OR_NIL_AT_INDEX(name, args, 0, NSString);
        
        return [CBLAttachmentProxy proxyWithDelegate:[_delegate attachmentNamed:name]];
    }, _thread);
}

-(void)addAttachmentNamed:(id)args
{
    void_block_on_thread(^{
        CBLAttachmentProxy * attachment;
        ENSURE_ARG_OR_NIL_AT_INDEX(attachment, args, 0, CBLAttachmentProxy);
        NSString * name;
        ENSURE_ARG_OR_NIL_AT_INDEX(name, args, 1, NSString);
        
        [_delegate addAttachment:attachment.delegate named:name];
    }, _thread);
}

-(void)removeAttachmentNamed:(id)args
{
    void_block_on_thread(^{
        NSString * name;
        ENSURE_ARG_OR_NIL_AT_INDEX(name, args, 0, NSString);
        
        [_delegate removeAttachmentNamed:name];
    }, _thread);
}


#pragma mark - PROTECTED (FOR SUBCLASSES TO OVERRIDE)

// NOTE: Not needed?
//- (instancetype) initWithDocument: (CBLDocument*)document;

-(NSString *)idForNewDocumentInDatabase:(id)args
{
    return invoke_block_on_thread(^id{
        CBLDatabaseProxy * database;
        ENSURE_ARG_OR_NIL_AT_INDEX(database, args, 0, CBLDatabaseProxy);
        
        return [_delegate idForNewDocumentInDatabase:database.delegate];
    }, _thread);
}

-(void)didLoadFromDocument
{
    void_block_on_thread(^{
        [_delegate didLoadFromDocument];
    }, _thread);
}

-(CBLDatabaseProxy *)databaseForModelProperty:(id)args
{
    return invoke_block_on_thread(^id{
        NSString * propertyName;
        ENSURE_ARG_OR_NIL_AT_INDEX(propertyName, args, 0, NSString);
        
        return [CBLDatabaseProxy proxyWithDelegate:[_delegate databaseForModelProperty:propertyName]];
    }, _thread);
}

-(void)markNeedsSave
{
    void_block_on_thread(^{
        [_delegate markNeedsSave];
    }, _thread);
}

// NOTE: Not needed?
//+ (Class) itemClassForArrayProperty: (NSString*)property;

#pragma mark - DOCUMENT MODEL:

-(void)tdDocumentChanged:(id)args
{
    void_block_on_thread(^{
        CBLDocumentProxy * document;
        ENSURE_ARG_OR_NIL_AT_INDEX(document, args, 0, CBLDocumentProxy);
        
        [_delegate tdDocumentChanged:document.delegate];
    }, _thread);
}

-(void)dealloc
{
    [_delegate release];
    [_thread release];
    
    [super dealloc];
}

@end
