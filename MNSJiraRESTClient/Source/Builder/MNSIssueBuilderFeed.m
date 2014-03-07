//
//  MNSIssueBuilderFeed.m
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

#import "MNSIssueBuilderFeed.h"
#import "MNSIssue.h"
#import "MNSIssueField.h"
#import "MNSIssueFieldID.h"
#import "MNSChangelogGroupBuilder.h"
#import "MNSChangelogGroup.h"

#define RENDEREDFIELDS_EXPAND @"renderedFields"
#define NAMES_EXPAND @"names"
#define SCHEMA_EXPAND @"schema"
#define TRANSITIONS_EXPAND @"transitions"
#define OPERATIONS_EXPAND @"operations"
#define EDITMETA_EXPAND @"editmeta"
#define CHANGELOG_EXPAND @"changelog"

@interface MNSIssueBuilderFeed ()
@end

@implementation MNSIssueBuilderFeed
- (id)initWithDictionary:(NSDictionary *)dic {
	self = [super init];
	if (self) {
		_fields = objectFromDicForkey(dic, kFields);
		[self setExpandosFrom:dic];
	}
	return self;
}

+(MNSIssueBuilderFeed*)createFromValidIssueSource:(id)source error:(NSError *__autoreleasing *)error{
    MNSIssueBuilderFeed *issueBuilderFeed;

    @try {
        if(validDictionary(source)){
            id hasFields = objectFromDicForkey(source, kFields);
            id hasExpands = objectFromDicForkey(source, kExpand);
            if (hasExpands && hasFields){
                issueBuilderFeed = [[MNSIssueBuilderFeed alloc] initWithDictionary:validDictionary(source)];
            }
        }
        else {
            *error = [NSError errorWithDomain:@"IssueBuilderFeed error" code:0 userInfo:nil];
        }
    }
    @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"IssueBuilderFeed error:Exception" code:0 userInfo:nil];
    }
    
    return issueBuilderFeed;

    
    
}

-(void)setExpandosFrom:(NSDictionary *)source{
    @try {
        _expandos = [(NSString*)objectFromDicForkey(source, kExpand) componentsSeparatedByString:@","];
        
        for (NSString* expandable in _expandos) {
            if ([expandable isEqualToString:RENDEREDFIELDS_EXPAND]) {
                _renderedFields = (NSDictionary*)objectFromDicForkey(source,RENDEREDFIELDS_EXPAND);
            }else if ([expandable isEqualToString:NAMES_EXPAND]) {
                _names = (NSDictionary*)objectFromDicForkey(source, NAMES_EXPAND);
            }else if ([expandable isEqualToString:SCHEMA_EXPAND]) {
                _schema = (NSDictionary*)objectFromDicForkey(source, SCHEMA_EXPAND);
            }else if ([expandable isEqualToString:TRANSITIONS_EXPAND]) {
                _transitions = (NSArray*)objectFromDicForkey(source, TRANSITIONS_EXPAND);
            }else if ([expandable isEqualToString:OPERATIONS_EXPAND]) {
                _operation = (NSDictionary*)objectFromDicForkey(source, OPERATIONS_EXPAND);
            }else if ([expandable isEqualToString:EDITMETA_EXPAND]) {
                _editmeta = (NSDictionary*)objectFromDicForkey(source, EDITMETA_EXPAND);
            }else if ([expandable isEqualToString:CHANGELOG_EXPAND]) {
                _changelog = (NSDictionary*)objectFromDicForkey(source, CHANGELOG_EXPAND);
            }else{
                if (objectFromDicForkey(source, expandable)) {
                    if(!_otherExpandables)
                        _otherExpandables = [[NSMutableDictionary alloc] init];
                    [_otherExpandables setObject:objectFromDicForkey(source, expandable) forKey:expandable];
                }
            }
        }

    }
    @catch (NSException *exception) {
        @throw([NSException exceptionWithName:@"IssueBilderFeed Exception setExpandosFrom" reason:nil userInfo:nil]);
    }
    
}

/** Add the custom issue fields */
- (NSArray*)issueFields {
    @try {
        NSMutableArray *issueFields = [NSMutableArray array];
        NSDictionary *names = [self buildNames];
        NSDictionary *schema = [self buildSchema];
        
        for (NSString *issueFieldID in [_fields allKeys] ) {
            if (![MNSIssueFieldID existID:issueFieldID]) {
                MNSIssueField *issueField = [[MNSIssueField alloc]init];
                issueField.identifier = issueFieldID;
                issueField.name = [names objectForKey:issueFieldID];
                issueField.type = [schema objectForKey:issueFieldID];
                issueField.value = [_fields objectForKey:issueFieldID];
                [issueFields addObject:issueField];
            }
        }
        
        return issueFields;

    }
    @catch (NSException *exception) {
        @throw([NSException exceptionWithName:@"IssueBilderFeed Exception issueFields" reason:nil userInfo:nil]);

    }
    
}

- (NSArray*)changelog {
    NSMutableArray *changelog = [NSMutableArray array];

    @try {
        NSArray *changelogGroupsJSON = objectFromDicForkey(_changelog, @"histories");
        for (NSDictionary *changelogGroupJSON in changelogGroupsJSON){
            NSError* error;
            MNSChangelogGroup *changelogGroup = [MNSChangelogGroupBuilder buildWithJSONObject:changelogGroupJSON error:&error];
            [changelog addObject:changelogGroup];
        }
    }
    @catch (NSException *exception) {
        @throw([NSException exceptionWithName:@"IssueBilderFeed Exception changelog" reason:nil userInfo:nil]);

    }
    return changelog;

    
}

/** It parses the names expandible and return the dictionary whose key is the id of the type field, and whose value is the name of the type field  */
- (NSDictionary*) buildNames {
    NSMutableDictionary *nameFields = [NSMutableDictionary dictionary];

    @try {
        
        for (NSString *keyID in [_names allKeys]) {
            [nameFields setObject:[_names valueForKey:keyID]  forKey:keyID];
        }
        
    }
    @catch (NSException *exception) {
        @throw([NSException exceptionWithName:@"IssueBilderFeed Exception buildNames" reason:nil userInfo:nil]);

    }
    return nameFields;

}

/** It parses the schema expandible and return a dictionary whose key is the id of the type field, and whose value is the type of the type field */
- (NSDictionary*) buildSchema {
    NSMutableDictionary *schemeFields = [NSMutableDictionary dictionary];

    @try {
        
        for (NSString *keyID in [_schema allKeys]) {
            NSDictionary *fieldDefinition = [_schema valueForKey:keyID];
            NSString *type = [fieldDefinition valueForKey:@"type"];
            [schemeFields setObject:type forKey:keyID];
        }
        
    }
    @catch (NSException *exception) {
        @throw([NSException exceptionWithName:@"IssueBilderFeed Exception buildSchema" reason:nil userInfo:nil]);

    }
    
    return schemeFields;

}

@end
