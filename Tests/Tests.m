//
//  Tests.m
//  Tests
//
//  Created by SolaWing on 16/4/18.
//  Copyright © 2016年 SW. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "AutoLayoutVisualFormatLib.h"

@interface NSLayoutConstraint (testHelper)

@end

@implementation NSLayoutConstraint (testHelper)

- (BOOL)isEqual:(NSLayoutConstraint*)object {
    if ([object isKindOfClass:[NSLayoutConstraint class]]) {
        if (self.firstItem == object.firstItem
            && self.secondItem == object.secondItem
            && self.firstAttribute == object.firstAttribute
            && self.secondAttribute == object.secondAttribute
            && self.multiplier == object.multiplier
            && self.constant == object.constant
            && self.priority == object.priority)
        {
            return YES;
        }
    }
    return NO;
}

@end

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#define PP_IDENTITY(...) __VA_ARGS__

- (void)testViewPredicate {
    UIView* superView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 1000, 1000)];
    UIView* subview = [UIView new];
    id metric = @(30.0);
    [superView addSubview:subview];

    NSArray* layouts;
    NSLayoutConstraint* layout;
#define CreateSubViewConstraint(attr1, relation, toView, attr2, mul, cons, pri) \
    layout = [NSLayoutConstraint constraintWithItem:subview                     \
                                          attribute:attr1                       \
                                          relatedBy:relation                    \
                                             toItem:toView                      \
                                          attribute:attr2                       \
                                         multiplier:mul                         \
                                           constant:cons];                      \
    layout.priority = pri;

#define AssertEqualConstraint(string, attr1, relation, toView, attr2, mul, cons, pri) \
    layouts = [subview VFLConstraints:string];                                        \
    CreateSubViewConstraint(attr1, relation, toView, attr2, mul, cons, pri);          \
    XCTAssertEqual(layouts.count, 1u);                                                \
    XCTAssertEqualObjects(layouts[0], layout);

// single and default value test
#define AssertAttrChar(ch, attr, toView)                                                           \
    AssertEqualConstraint(@#ch, attr, NSLayoutRelationEqual, toView, attr, 1.0, 0, 1000)

    AssertAttrChar(L, NSLayoutAttributeLeft, superView)
    AssertAttrChar(R, NSLayoutAttributeRight, superView)
    AssertAttrChar(T, NSLayoutAttributeTop, superView)
    AssertAttrChar(B, NSLayoutAttributeBottom, superView)
    AssertAttrChar(X, NSLayoutAttributeCenterX, superView)
    AssertAttrChar(Y, NSLayoutAttributeCenterY, superView)
    AssertAttrChar(l, NSLayoutAttributeLeading, superView)
    AssertAttrChar(t, NSLayoutAttributeTrailing, superView)
    AssertAttrChar(b, NSLayoutAttributeBaseline, superView) // attr need secondView, default superView

    AssertAttrChar(W, NSLayoutAttributeWidth, nil) // toView default nil
    AssertAttrChar(H, NSLayoutAttributeHeight, nil)

    // in view predicate, attr default to width
#define AssertRelation(ch, relation) \
    AssertEqualConstraint(@#ch, NSLayoutAttributeWidth, relation, nil, NSLayoutAttributeWidth, 1.0, 0, 1000)

    AssertRelation(=, NSLayoutRelationEqual)
    AssertRelation(==, NSLayoutRelationEqual)
    AssertRelation(<=, NSLayoutRelationLessThanOrEqual)
    AssertRelation(<, NSLayoutRelationLessThanOrEqual)
    AssertRelation(>=, NSLayoutRelationGreaterThanOrEqual)
    AssertRelation(>, NSLayoutRelationGreaterThanOrEqual)

    // view or metric Index test
    AssertEqualConstraint(PP_IDENTITY(@"$0"), NSLayoutAttributeWidth, NSLayoutRelationEqual, subview, NSLayoutAttributeWidth, 1.0, 0, 1000);
    AssertEqualConstraint(PP_IDENTITY(@"$1", metric), NSLayoutAttributeWidth, NSLayoutRelationEqual, nil, NSLayoutAttributeWidth, 1.0, [metric doubleValue], 1000);

    // specifiy attr2
#define AssertAttrChar2(ch, attr, toView)                                                           \
    AssertEqualConstraint(@"."#ch, NSLayoutAttributeWidth, NSLayoutRelationEqual, toView, attr, 1.0, 0, 1000)
    AssertAttrChar2(W, NSLayoutAttributeWidth, nil) // toView default nil
    AssertAttrChar2(H, NSLayoutAttributeHeight, nil)

    // multiplier test
    AssertEqualConstraint(PP_IDENTITY(@"* 0.5"), NSLayoutAttributeWidth, NSLayoutRelationEqual, nil, NSLayoutAttributeWidth, 0.5, 0, 1000);
    AssertEqualConstraint(PP_IDENTITY(@"* $1", metric), NSLayoutAttributeWidth, NSLayoutRelationEqual, nil, NSLayoutAttributeWidth, [metric doubleValue], 0, 1000);

    // constant test
    AssertEqualConstraint(PP_IDENTITY(@"400"), NSLayoutAttributeWidth, NSLayoutRelationEqual, nil, NSLayoutAttributeWidth, 1, 400, 1000);
    AssertEqualConstraint(PP_IDENTITY(@"$1", metric), NSLayoutAttributeWidth, NSLayoutRelationEqual, nil, NSLayoutAttributeWidth, 1.0, [metric doubleValue], 1000);
    AssertEqualConstraint(PP_IDENTITY(@"-400"), NSLayoutAttributeWidth, NSLayoutRelationEqual, nil, NSLayoutAttributeWidth, 1, -400, 1000);
    AssertEqualConstraint(PP_IDENTITY(@"-$1", metric), NSLayoutAttributeWidth, NSLayoutRelationEqual, nil, NSLayoutAttributeWidth, 1.0, -[metric doubleValue], 1000);

    // priority test
    AssertEqualConstraint(PP_IDENTITY(@"@400"), NSLayoutAttributeWidth, NSLayoutRelationEqual, nil, NSLayoutAttributeWidth, 1, 0, 400);
    AssertEqualConstraint(PP_IDENTITY(@"@$1", metric), NSLayoutAttributeWidth, NSLayoutRelationEqual, nil, NSLayoutAttributeWidth, 1.0, 0, [metric doubleValue]);

    // complete constraint test
    AssertEqualConstraint(PP_IDENTITY(@"Left > $0.Right * 0.2 + 500 @$1", metric), NSLayoutAttributeLeft, NSLayoutRelationGreaterThanOrEqual , subview, NSLayoutAttributeRight, 0.2, 500, [metric doubleValue]);
    AssertEqualConstraint(PP_IDENTITY(@"Height < |.Width * 1.5 - 500 @$1", metric), NSLayoutAttributeHeight, NSLayoutRelationLessThanOrEqual , superView, NSLayoutAttributeWidth, 1.5, -500, [metric doubleValue]);

    // multi predicate
    layouts = [subview VFLConstraints:@"Width > 100, Height < $1, Height < $0.Width, Left = |.Right - 300, Right = |.Left * 2 + 200 @999", metric];

    XCTAssertEqual(layouts.count, 5u);
    CreateSubViewConstraint(NSLayoutAttributeWidth, NSLayoutRelationGreaterThanOrEqual, nil, NSLayoutAttributeWidth, 1.0, 100, 1000);
    XCTAssertEqualObjects(layouts[0], layout);
    CreateSubViewConstraint(NSLayoutAttributeHeight, NSLayoutRelationLessThanOrEqual, nil, NSLayoutAttributeHeight, 1.0, [metric doubleValue], 1000);
    XCTAssertEqualObjects(layouts[1], layout);
    CreateSubViewConstraint(NSLayoutAttributeHeight, NSLayoutRelationLessThanOrEqual, subview, NSLayoutAttributeWidth, 1.0, 0, 1000);
    XCTAssertEqualObjects(layouts[2], layout);
    CreateSubViewConstraint(NSLayoutAttributeLeft, NSLayoutRelationEqual, superView, NSLayoutAttributeRight, 1.0, -300, 1000);
    XCTAssertEqualObjects(layouts[3], layout);
    CreateSubViewConstraint(NSLayoutAttributeRight, NSLayoutRelationEqual, superView, NSLayoutAttributeLeft, 2.0, 200, 999);
    XCTAssertEqualObjects(layouts[4], layout);
}

- (void)testVFL {
    // prepare
    UIView* superView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 1000, 1000)];
    NSMutableArray* arrayEnv = [NSMutableArray arrayWithCapacity:10];
    NSMutableDictionary* dictEnv = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSUInteger i = 0; i < 5; ++i) {
        UIView* v = [UIView new];
        [superView addSubview:v];
        [arrayEnv addObject:v];
        dictEnv[[NSString stringWithFormat:@"v%lu", i]] = v;
    }
    for (NSUInteger i = 0; i < 5; ++i) {
        id metric = @(i * 10);
        [arrayEnv addObject:metric];
        dictEnv[[NSString stringWithFormat:@"m%lu", i]] = metric;
    }

    // view predicate prove correct in testViewPredicate, so can use it to ensure correct

    // default connection
    NSArray* layouts;
    NSMutableArray* compareLayouts;
    XCTAssertEqualObjects( [arrayEnv[0] VFLConstraints:@"L=8"], [arrayEnv VFLConstraints:@"|-[$0]"] );
    XCTAssertEqualObjects( ([superView VFLConstraints:@"R=$1+8", arrayEnv[0]]), [arrayEnv VFLConstraints:@"[0]-|"] );
    XCTAssertEqualObjects( ([(UIView*)arrayEnv[0] VFLConstraints:@"L=$1.R+8", arrayEnv[1]]), [arrayEnv VFLConstraints:@"[$1]-[0]"] );
    XCTAssertEqualObjects( [arrayEnv[0] VFLConstraints:@"T=8"], [arrayEnv VFLConstraints:@"V:|-[0]"] );
    XCTAssertEqualObjects( ([superView VFLConstraints:@"B=$1+8", arrayEnv[0]]), [arrayEnv VFLConstraints:@"V:[0]-|"] );
    XCTAssertEqualObjects( ([(UIView*)arrayEnv[0] VFLConstraints:@"T=$1.B+8", arrayEnv[1]]), [arrayEnv VFLConstraints:@"V:[1]-[0]"] );

    // flush connection
    XCTAssertEqualObjects( [arrayEnv[0] VFLConstraints:@"L"], [arrayEnv VFLConstraints:@"|[0]"] );
    XCTAssertEqualObjects( ([superView VFLConstraints:@"R=$1", arrayEnv[0]]), [arrayEnv VFLConstraints:@"[0]|"] );
    XCTAssertEqualObjects( ([(UIView*)arrayEnv[0] VFLConstraints:@"L=$1.R", arrayEnv[1]]), [arrayEnv VFLConstraints:@"[1][0]"] );
    XCTAssertEqualObjects( [arrayEnv[0] VFLConstraints:@"T"], [arrayEnv VFLConstraints:@"V:|[0]"] );
    XCTAssertEqualObjects( ([superView VFLConstraints:@"B=$1", arrayEnv[0]]), [arrayEnv VFLConstraints:@"V:[0]|"] );
    XCTAssertEqualObjects( ([(UIView*)arrayEnv[0] VFLConstraints:@"T=$1.B", arrayEnv[1]]), [arrayEnv VFLConstraints:@"V:[1][0]"] );

    // specifiy connection
    XCTAssertEqualObjects( [arrayEnv[0] VFLConstraints:@"L=8"], [arrayEnv VFLConstraints:@"|-8-[$0]"] );
    XCTAssertEqualObjects( ([superView VFLConstraints:@"R=$1+$2", arrayEnv[0], arrayEnv[6]]), [arrayEnv VFLConstraints:@"[0]-$6-|"] );
    XCTAssertEqualObjects( ([(UIView*)arrayEnv[0] VFLConstraints:@"L=$1.R+8", arrayEnv[1]]), [arrayEnv VFLConstraints:@"[$1]-8-[0]"] );
    XCTAssertEqualObjects( [arrayEnv[0] VFLConstraints:@"T=8"], [arrayEnv VFLConstraints:@"V:|-8-[0]"] );
    XCTAssertEqualObjects( ([superView VFLConstraints:@"B=$1+8", arrayEnv[0]]), [arrayEnv VFLConstraints:@"V:[0]-8-|"] );
    XCTAssertEqualObjects( ([(UIView*)arrayEnv[0] VFLConstraints:@"T=$1.B+8", arrayEnv[1]]), [arrayEnv VFLConstraints:@"V:[1]-8-[0]"] );

    // multi complex connection
    XCTAssertEqualObjects( [arrayEnv[0] VFLConstraints:@"L>=8, L<=6@5, L==7"], [arrayEnv VFLConstraints:@"|->8, <6@5,=7-[$0]"] );
    XCTAssertEqualObjects( ([superView VFLConstraints:@"R>=$1+8, R<=$1+6@5, R==$1+7", arrayEnv[0]]), [arrayEnv VFLConstraints:@"[$0]-(>8, <6@5,=7)-|"] );

    // multi chain view and align
    layouts = [arrayEnv VFLConstraints:@"|- (>15, < 50) -[$0($6)] - [$1][$2] - | LTRBXYltbWH"];
    compareLayouts = [NSMutableArray new];
    [compareLayouts addObjectsFromArray:[(UIView*)arrayEnv[0] VFLConstraints:@"L>15, L<50, W=$1", arrayEnv[6]]];
    [compareLayouts addObjectsFromArray:[(UIView*)arrayEnv[1] VFLConstraints:@"L=$1.R+8", arrayEnv[0]]];
    [compareLayouts addObjectsFromArray:[(UIView*)arrayEnv[2] VFLConstraints:@"L=$1.R", arrayEnv[1]]];
    [compareLayouts addObjectsFromArray:[superView VFLConstraints:@"R=$1.R+8", arrayEnv[2]]];
    NSArray* views = @[arrayEnv[0], arrayEnv[1], arrayEnv[2]];
    [compareLayouts addObjectsFromArray:[views constraintsAlignAllViews:NSLayoutAttributeLeft]];
    [compareLayouts addObjectsFromArray:[views constraintsAlignAllViews:NSLayoutAttributeTop]];
    [compareLayouts addObjectsFromArray:[views constraintsAlignAllViews:NSLayoutAttributeRight]];
    [compareLayouts addObjectsFromArray:[views constraintsAlignAllViews:NSLayoutAttributeBottom]];
    [compareLayouts addObjectsFromArray:[views constraintsAlignAllViews:NSLayoutAttributeCenterX]];
    [compareLayouts addObjectsFromArray:[views constraintsAlignAllViews:NSLayoutAttributeCenterY]];
    [compareLayouts addObjectsFromArray:[views constraintsAlignAllViews:NSLayoutAttributeLeading]];
    [compareLayouts addObjectsFromArray:[views constraintsAlignAllViews:NSLayoutAttributeTrailing]];
    [compareLayouts addObjectsFromArray:[views constraintsAlignAllViews:NSLayoutAttributeBaseline]];
    [compareLayouts addObjectsFromArray:[views constraintsAlignAllViews:NSLayoutAttributeWidth]];
    [compareLayouts addObjectsFromArray:[views constraintsAlignAllViews:NSLayoutAttributeHeight]];
    XCTAssertEqualObjects(layouts, compareLayouts);

    // multi statement and change H, V
    layouts = [arrayEnv VFLConstraints:@"|-[$0(W=$0.H+$8)]-| X;"
        "V:[$0][$1($7)] L;"
        "[$0][$1(L=$0.R+$7, R@20)] L;"
        "H:[$1][$2][$3] XY;" ];
    compareLayouts = [NSMutableArray new];
    // default horizontal
    [compareLayouts addObjectsFromArray:[(UIView*)arrayEnv[0] VFLConstraints:@"L=8, W=$0.H+$1", arrayEnv[8]]];
    [compareLayouts addObjectsFromArray:[superView VFLConstraints:@"R=$1+8", arrayEnv[0]]];
    // change to vertical
    [compareLayouts addObjectsFromArray:[(UIView*)arrayEnv[1] VFLConstraints:@"T=$1.B, H=$2", arrayEnv[0], arrayEnv[7]]];
    [compareLayouts addObjectsFromArray:[@[arrayEnv[0], arrayEnv[1]] constraintsAlignAllViews:NSLayoutAttributeLeft]];
    // continue to vertical. and same repeat constraint
    [compareLayouts addObjectsFromArray:[(UIView*)arrayEnv[1] VFLConstraints:@"T=$1.B, L=$1.R+$2, R@20", arrayEnv[0], arrayEnv[7]]];
    [compareLayouts addObjectsFromArray:[@[arrayEnv[0], arrayEnv[1]] constraintsAlignAllViews:NSLayoutAttributeLeft]];
    // change back to horizontal
    [compareLayouts addObjectsFromArray:[(UIView*)arrayEnv[2] VFLConstraints:@"L=$1.R", arrayEnv[1]]];
    [compareLayouts addObjectsFromArray:[(UIView*)arrayEnv[3] VFLConstraints:@"L=$1.R", arrayEnv[2]]];
    [compareLayouts addObjectsFromArray:[@[arrayEnv[1], arrayEnv[2], arrayEnv[3]] constraintsAlignAllViews:NSLayoutAttributeCenterX]];
    [compareLayouts addObjectsFromArray:[@[arrayEnv[1], arrayEnv[2], arrayEnv[3]] constraintsAlignAllViews:NSLayoutAttributeCenterY]];
    XCTAssertEqualObjects(layouts, compareLayouts);

    // multi statement use dict env
    layouts = [dictEnv VFLConstraints:@"|-[v0(abc:W=v0.H+m3)]-| X;"
        "V:[$v0][v1(m2)] L;"
        "[v0][v1(L=$v0.R+$m2, R@20)] L;"
        "H:[v1][v2][v3] XY;" ];
    XCTAssertEqualObjects(layouts, compareLayouts);
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
