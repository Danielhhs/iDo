//
//  Slide+iDo.m
//  iDo
//
//  Created by Huang Hongsen on 11/7/14.
//  Copyright (c) 2014 com.microstrategy. All rights reserved.
//

#import "Slide+iDo.h"
#import "CoreDataHelper.h"
#import "KeyConstants.h"
#import "GenericConent+iDo.h"
#import "CoreDataHelper.h"
#import <UIKit/UIKit.h>

@implementation Slide (iDo)

+ (Slide *) slideFromAttributes:(NSDictionary *)attributes inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    Slide *maxUnique = (Slide *)[CoreDataHelper maxUniqueObjectForEntityName:@"Slide" inManagedObjectContext:managedObjectContext];
    
    Slide *slide = [NSEntityDescription insertNewObjectForEntityForName:@"Slide" inManagedObjectContext:managedObjectContext];
    
    slide.unique = @([maxUnique.unique integerValue] + 1);
    
    [Slide applySlideAttributes:attributes toSlide:slide inManageObjectContext:managedObjectContext];
    return slide;
}

+ (NSMutableDictionary *) attributesFromSlide:(Slide *)slide
{
    NSMutableDictionary *attribtues = [NSMutableDictionary dictionary];
    
    [attribtues setObject:slide.background forKey:[KeyConstants slideBackgroundKey]];
    
    NSSet *contents = slide.contents;
    NSArray *sortedContents = [contents sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]]];
    
    NSMutableArray *contentAttributes = [NSMutableArray array];
    for (GenericConent *content in sortedContents) {
        [contentAttributes addObject:[CoreDataHelper contentAttributesFromGenericContent:content]];
    }
    [attribtues setObject:slide.unique forKey:[KeyConstants slideUniqueKey]];
    [attribtues setObject:[contentAttributes copy] forKey:[KeyConstants slideContentsKey]];
    [attribtues setObject:[UIImage imageWithData:slide.thumbnail] forKey:[KeyConstants slideThumbnailKey]];
    [attribtues setObject:slide.index forKey:[KeyConstants slideIndexKey]];
    return attribtues;
}

+ (void) applySlideAttributes:(NSDictionary *)slideAttributes toSlide:(Slide *)slide inManageObjectContext:(NSManagedObjectContext *)manageObjectContext
{
    
    slide.background = slideAttributes[[KeyConstants slideBackgroundKey]];
    slide.thumbnail = UIImageJPEGRepresentation(slideAttributes[[KeyConstants slideThumbnailKey]], 1.f);
    NSArray *contentsAttributes = slideAttributes[[KeyConstants slideContentsKey]];
    NSArray *contents = [slide.contents sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]]];
    
    for (NSInteger i = 0; i < [contentsAttributes count]; i++) {
        GenericConent *content = contents[i];
        [CoreDataHelper applyContentAttributes:contentsAttributes[i] toContentObject:content inManagedObjectContext:manageObjectContext];
    }
    
}

@end
