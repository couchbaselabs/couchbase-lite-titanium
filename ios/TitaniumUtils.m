//
//  TitaniumUtils.m
//  CouchbaseLiteTitanium
//
//  Created by Wayne Carter on 9/28/13.
//
//

#import "TitaniumUtils.h"

@implementation TitaniumUtils

+ (void)throwError:(NSError *)error withProxy:(TiProxy *)proxy
{
    [proxy throwException:[NSString stringWithFormat:@"%@.%d", error.domain, error.code] subreason:error.localizedDescription location:nil];
}

@end
