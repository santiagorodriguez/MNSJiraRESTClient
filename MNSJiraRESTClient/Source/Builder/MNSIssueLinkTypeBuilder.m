//
//  MNSIssueLinkTypeBuilder.m
//
//  Copyright 2014 MediaNet Software
//  This file is part of MNSJiraRESTClient.
//
//  MNSJiraRESTClient is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License as published by
//  the Free Software Foundation, either version 3 of the License.
//
//  MNSJiraRESTClient is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with MNSJiraRESTClient.  If not, see <http://www.gnu.org/licenses/>.

#import "MNSIssueLinkTypeBuilder.h"
#import "MNSIssueLinkType.h"



@implementation MNSIssueLinkTypeBuilder

+ (id) buildWithJSONObject:(id)source error:(NSError **)error {
    
    MNSIssueLinkType *issueLinkType;

    @try {
        
        if (validDictionary(source)) {
            NSString *name = objectFromDicForkey(source, kName);
            NSString *description = objectFromDicForkey(source, kDescription);
            NSString *directionString = objectFromDicForkey(source, kDirection);
            enum MNSIssueLinkTypeDirection direction = [MNSIssueLinkType directionWithString:directionString];
            
            issueLinkType = [[MNSIssueLinkType alloc] initWithName:name description:description direction:direction];
        }else {
            *error = [NSError errorWithDomain:@"IssueLingTypeBuilder error" code:0 userInfo:nil];
        }
    }
    @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"IssueLingTypeBuilder error:Exception" code:0 userInfo:nil];

    }
    return issueLinkType;

}

@end
