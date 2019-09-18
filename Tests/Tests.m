//
//  Tests.m
//  Tests
//
//  Created by SolaWing on 16/4/18.
//  Copyright © 2016年 SW. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import <VFL/VFL.h>

@interface NSLayoutConstraint (testHelper)

@end

@implementation NSLayoutConstraint (testHelper)

- (BOOL)isEqual:(NSLayoutConstraint*)object {
    if ([object isKindOfClass:[NSLayoutConstraint class]]) {
        // FIXME: get item may crash when dealloc, move it to last
        if ( self.firstAttribute == object.firstAttribute
                && self.secondAttribute == object.secondAttribute
                && self.multiplier == object.multiplier
                && self.constant == object.constant
                && self.priority == object.priority
                && self.firstItem == object.firstItem
                && self.secondItem == object.secondItem
        ) {
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

typedef struct {
    NSMutableArray* array;
    NSMutableDictionary* dict;
    UIView* superview;
} ENV;
static ENV prepareVFL() {
    ENV env = {
        [NSMutableArray arrayWithCapacity:10],
        [NSMutableDictionary dictionaryWithCapacity:10],
        .superview = [[UIView alloc] initWithFrame:CGRectMake(0,0, 1000, 1000)]
    };
    for (NSUInteger i = 0; i < 5; ++i) {
        UIView* v = [UIView new];
        [env.superview addSubview:v];
        [env.array addObject:v];
        env.dict[[NSString stringWithFormat:@"v%lu", i]] = v;
    }
    for (NSUInteger i = 0; i < 5; ++i) {
        id metric = @(i * 10);
        [env.array addObject:metric];
        env.dict[[NSString stringWithFormat:@"m%lu", i]] = metric;
    }
    return env;
}

#define PP_IDENTITY(...) __VA_ARGS__

/// use to guard basic view predicate analyzer is ok
- (void)testViewPredicate {
    UIView* superview = [[UIView alloc] initWithFrame:CGRectMake(0,0, 1000, 1000)];
    UIView* subview = [UIView new];
    id metric = @(30.0);
    [superview addSubview:subview];

    NSArray* layouts;
    NSLayoutConstraint* layout;

    layouts = [subview VFLConstraints:@"", metric];
    XCTAssertEqual(layouts.count, 0u);


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

    AssertAttrChar(L, NSLayoutAttributeLeft, superview)
    AssertAttrChar(R, NSLayoutAttributeRight, superview)
    AssertAttrChar(T, NSLayoutAttributeTop, superview)
    AssertAttrChar(B, NSLayoutAttributeBottom, superview)
    AssertAttrChar(X, NSLayoutAttributeCenterX, superview)
    AssertAttrChar(Y, NSLayoutAttributeCenterY, superview)
    AssertAttrChar(l, NSLayoutAttributeLeading, superview)
    AssertAttrChar(t, NSLayoutAttributeTrailing, superview)
    AssertAttrChar(b, NSLayoutAttributeBaseline, superview) // attr need secondView, default superview

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
    AssertEqualConstraint(PP_IDENTITY(@"|m"), NSLayoutAttributeWidth, NSLayoutRelationEqual, superview.layoutMarginsGuide, NSLayoutAttributeWidth, 1.0, 0, 1000);
    AssertEqualConstraint(PP_IDENTITY(@"|r"), NSLayoutAttributeWidth, NSLayoutRelationEqual, superview.readableContentGuide, NSLayoutAttributeWidth, 1.0, 0, 1000);
    if (@available(iOS 11.0, *)) {
        AssertEqualConstraint(PP_IDENTITY(@"|s"), NSLayoutAttributeWidth, NSLayoutRelationEqual, superview.safeAreaLayoutGuide, NSLayoutAttributeWidth, 1.0, 0, 1000);
    }
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
    AssertEqualConstraint(PP_IDENTITY(@"Height < |.Width * 1.5 - 500 @$1", metric), NSLayoutAttributeHeight, NSLayoutRelationLessThanOrEqual , superview, NSLayoutAttributeWidth, 1.5, -500, [metric doubleValue]);

    // multi predicate
    layouts = [subview VFLConstraints:@"Width > 100, Height < $1, Height < $0.Width, Left = |.Right - 300, Right = |m.Left * 2 + 200 @999", metric];

    XCTAssertEqual(layouts.count, 5u);
    CreateSubViewConstraint(NSLayoutAttributeWidth, NSLayoutRelationGreaterThanOrEqual, nil, NSLayoutAttributeWidth, 1.0, 100, 1000);
    XCTAssertEqualObjects(layouts[0], layout);
    CreateSubViewConstraint(NSLayoutAttributeHeight, NSLayoutRelationLessThanOrEqual, nil, NSLayoutAttributeHeight, 1.0, [metric doubleValue], 1000);
    XCTAssertEqualObjects(layouts[1], layout);
    CreateSubViewConstraint(NSLayoutAttributeHeight, NSLayoutRelationLessThanOrEqual, subview, NSLayoutAttributeWidth, 1.0, 0, 1000);
    XCTAssertEqualObjects(layouts[2], layout);
    CreateSubViewConstraint(NSLayoutAttributeLeft, NSLayoutRelationEqual, superview, NSLayoutAttributeRight, 1.0, -300, 1000);
    XCTAssertEqualObjects(layouts[3], layout);
    CreateSubViewConstraint(NSLayoutAttributeRight, NSLayoutRelationEqual, superview.layoutMarginsGuide, NSLayoutAttributeLeft, 2.0, 200, 999);
    XCTAssertEqualObjects(layouts[4], layout);
}

// use to assure full VFL statement is ok
- (void)testVFL {
    ENV env = prepareVFL();
    typeof(env.superview) superview = env.superview;

    // view predicate prove correct in testViewPredicate, so can use it to ensure correct

    // default connection
    NSArray* layouts;
    NSMutableArray* compareLayouts;

#define AssertAppleVFLEqual(appleFormat, myFormat) \
    XCTAssertEqualObjects([NSLayoutConstraint constraintsWithVisualFormat:appleFormat options:0 metrics:nil views:env.dict], \
                          [env.dict VFLConstraints:myFormat]) // same as apple's VFL
#define AssertAppleVFLHorzontalEqual(format) AssertAppleVFLEqual(@"H:" format, @"F:" format);
#define AssertAppleVFLVerticleEqual(format) AssertAppleVFLEqual(@"V:" format, @"V:" format);

    AssertAppleVFLHorzontalEqual(@"|-[v0]-4-[v1][v2]-|");
    AssertAppleVFLVerticleEqual(@"|-[v0]-4-[v1][v2]-|");
    
    XCTAssertEqualObjects( ([env.array[0] VFLConstraints:@"L=$1", superview.layoutMarginsGuide]), [env.array VFLConstraints:@"H:|-[$0]"] );
    XCTAssertEqualObjects( ([superview.layoutMarginsGuide VFLConstraints:@"R=$1", env.array[0]]), [env.array VFLConstraints:@"[0]-|"] );
    XCTAssertEqualObjects( ([(UIView*)env.array[0] VFLConstraints:@"L=$1.R+8", env.array[1]]), [env.array VFLConstraints:@"[$1]-[0]"] );
    XCTAssertEqualObjects( ([env.array[0] VFLConstraints:@"T=$1", superview.layoutMarginsGuide]), [env.array VFLConstraints:@"V:|-[0]"] );
    XCTAssertEqualObjects( ([superview.layoutMarginsGuide VFLConstraints:@"B=$1", env.array[0]]), [env.array VFLConstraints:@"V:[0]-|"] );
    XCTAssertEqualObjects( ([(UIView*)env.array[0] VFLConstraints:@"T=$1.B+8", env.array[1]]), [env.array VFLConstraints:@"V:[1]-[0]"] );

    // flush connection
    XCTAssertEqualObjects( [env.array[0] VFLConstraints:@"L"], [env.array VFLConstraints:@"|[0]"] );
    XCTAssertEqualObjects( ([superview VFLConstraints:@"R=$1", env.array[0]]), [env.array VFLConstraints:@"[0]|"] );
    XCTAssertEqualObjects( ([(UIView*)env.array[0] VFLConstraints:@"L=$1.R", env.array[1]]), [env.array VFLConstraints:@"[1][0]"] );
    XCTAssertEqualObjects( [env.array[0] VFLConstraints:@"T"], [env.array VFLConstraints:@"V:|[0]"] );
    XCTAssertEqualObjects( ([superview VFLConstraints:@"B=$1", env.array[0]]), [env.array VFLConstraints:@"V:[0]|"] );
    XCTAssertEqualObjects( ([(UIView*)env.array[0] VFLConstraints:@"T=$1.B", env.array[1]]), [env.array VFLConstraints:@"V:[1][0]"] );

    // specifiy connection
    XCTAssertEqualObjects( [env.array[0] VFLConstraints:@"L=8"], [env.array VFLConstraints:@"|-8-[$0]"] );
    XCTAssertEqualObjects( ([superview VFLConstraints:@"R=$1+$2", env.array[0], env.array[6]]), [env.array VFLConstraints:@"[0]-$6-|"] );
    XCTAssertEqualObjects( ([(UIView*)env.array[0] VFLConstraints:@"L=$1.R+8", env.array[1]]), [env.array VFLConstraints:@"[$1]-8-[0]"] );
    XCTAssertEqualObjects( [env.array[0] VFLConstraints:@"T=8"], [env.array VFLConstraints:@"V:|-8-[0]"] );
    XCTAssertEqualObjects( ([superview VFLConstraints:@"B=$1+8", env.array[0]]), [env.array VFLConstraints:@"V:[0]-8-|"] );
    XCTAssertEqualObjects( ([(UIView*)env.array[0] VFLConstraints:@"T=$1.B+8", env.array[1]]), [env.array VFLConstraints:@"V:[1]-8-[0]"] );

    // width constraint
    AssertAppleVFLHorzontalEqual(@"[v0(>=50)]");
    AssertAppleVFLVerticleEqual(@"[v0(>=50)]");

    // equal width
    AssertAppleVFLHorzontalEqual(@"[v0(==v1)]");
    AssertAppleVFLVerticleEqual(@"[v0(==v1)]");

    // multi complex connection
    XCTAssertEqualObjects( [env.array[0] VFLConstraints:@"L>=8, L<=6@5, L==7"], [env.array VFLConstraints:@"|->8, <6@5,=7-[$0]"] );
    XCTAssertEqualObjects( ([superview VFLConstraints:@"R>=$1+8, R<=$1+6@5, R==$1+7", env.array[0]]), [env.array VFLConstraints:@"[$0]-(>8, <6@5,=7)-|"] );

    // multi chain view and align. should have same order
    layouts = [env.array VFLConstraints:@"|- (>15, < 50) -[$0($6)] - [$1][$2] - | LTRBXYltbWH"];
    compareLayouts = [NSMutableArray new];
    [compareLayouts addObjectsFromArray:[(UIView*)env.array[0] VFLConstraints:@"L>15, L<50, W=$1", env.array[6]]];
    [compareLayouts addObjectsFromArray:[(UIView*)env.array[1] VFLConstraints:@"L=$1.R+8", env.array[0]]];
    [compareLayouts addObjectsFromArray:[(UIView*)env.array[2] VFLConstraints:@"L=$1.R", env.array[1]]];
    [compareLayouts addObjectsFromArray:[superview.layoutMarginsGuide VFLConstraints:@"R=$1", env.array[2]]];
    NSArray* views = @[env.array[0], env.array[1], env.array[2]];
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

    // multi statement and change H, V, optional [View ()]
    layouts = [env.array VFLConstraints:@"|-[$0(W=$0.H+$8)]-| X;"
        "V:[$0][$1($7)] L;"
        "[$0][$1 L=$0.R+$7, R@20] L;"
        "H:[$1][$2][$3] XY;" ];
    compareLayouts = [NSMutableArray new];
    // default horizontal
    [compareLayouts addObjectsFromArray:[(UIView*)env.array[0] VFLConstraints:@"L=$2, W=$0.H+$1", env.array[8], superview.layoutMarginsGuide]];
    [compareLayouts addObjectsFromArray:[superview.layoutMarginsGuide VFLConstraints:@"R=$1", env.array[0]]];
    // change to vertical
    [compareLayouts addObjectsFromArray:[(UIView*)env.array[1] VFLConstraints:@"T=$1.B, H=$2", env.array[0], env.array[7]]];
    [compareLayouts addObjectsFromArray:[@[env.array[0], env.array[1]] constraintsAlignAllViews:NSLayoutAttributeLeft]];
    // continue to vertical. and same repeat constraint
    [compareLayouts addObjectsFromArray:[(UIView*)env.array[1] VFLConstraints:@"T=$1.B, L=$1.R+$2, R@20", env.array[0], env.array[7]]];
    [compareLayouts addObjectsFromArray:[@[env.array[0], env.array[1]] constraintsAlignAllViews:NSLayoutAttributeLeft]];
    // change back to horizontal
    [compareLayouts addObjectsFromArray:[(UIView*)env.array[2] VFLConstraints:@"L=$1.R", env.array[1]]];
    [compareLayouts addObjectsFromArray:[(UIView*)env.array[3] VFLConstraints:@"L=$1.R", env.array[2]]];
    [compareLayouts addObjectsFromArray:[@[env.array[1], env.array[2], env.array[3]] constraintsAlignAllViews:NSLayoutAttributeCenterX]];
    [compareLayouts addObjectsFromArray:[@[env.array[1], env.array[2], env.array[3]] constraintsAlignAllViews:NSLayoutAttributeCenterY]];
    XCTAssertEqualObjects(layouts, compareLayouts);

    // multi statement use dict env
    layouts = [env.dict VFLConstraints:@"|-[v0(abc:W=v0.H+m3)]-| X;"
        "V:[$v0][v1(m2)] L;"
        "[v0][v1(L=$v0.R+$m2, R@20)] L;"
        "H:[v1][v2][v3] XY;" ];
    XCTAssertEqualObjects(layouts, compareLayouts);

    // all constraints shouldn't change translatesAutoresizingMaskIntoConstraints
    for (UIView* element in env.array){
        if ([element isKindOfClass:[UIView class]]) {
            XCTAssertEqual(element.translatesAutoresizingMaskIntoConstraints, true);
        }
    }
}

- (void)testException {
    VFLEnableAssert = true;
    XCTAssertThrows(VFLConstraints(@"[$1]", [NSDictionary dictionary]));
}

- (void)testFullInstall {
    ENV env = prepareVFL();
    // typeof(env.superview) superview = env.superview;

    // only change translatesAutoresizingMaskIntoConstraints for view in []
    // no format, no effect
    __auto_type output = [env.array VFLFullInstall:@""];
    XCTAssertEqual(output.count, 0u);
    for (UIView* element in env.array){
        if ([element isKindOfClass:[UIView class]]) {
            XCTAssertEqual(element.translatesAutoresizingMaskIntoConstraints, true);
        }
    }

    // only change the main view's translatesAutoresizingMaskIntoConstraints
    output = [env.array VFLFullInstall:@"[$0($1)]"];
    XCTAssertEqual(output.count, 1u);
    XCTAssertEqual(output[0].active, true);
    for (UIView* element in [env.array subarrayWithRange:NSMakeRange(1, 4)]){
        XCTAssertEqual(element.translatesAutoresizingMaskIntoConstraints, true);
    }
    
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
