//
//  AutoLayoutFormatAnalyzer.m
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/9/19.
//  Copyright (c) 2015年 SW. All rights reserved.
//

#import "AutoLayoutFormatAnalyzer.h"
#import "NSArray+SWAutoLayout.h"
#import <UIKit/UIKit.h>
#import <stdlib.h>

@interface _SWLayoutPredicate : NSObject
{
@public
    NSLayoutAttribute attr1;
    NSLayoutAttribute attr2;
    NSLayoutRelation relation;
    CGFloat multiplier;
    CGFloat constant;
    id view2;
    CGFloat priority;
}

@end

@implementation _SWLayoutPredicate

- (instancetype)init {
    if (self = [super init]) {
        multiplier = 1.0;
        relation = NSLayoutRelationEqual;
        priority = UILayoutPriorityRequired;
    }
    return self;
}

@end

typedef _SWLayoutPredicate Predicate;

typedef struct analyzeEnv{
    __unsafe_unretained NSMutableArray* constraints;
    __unsafe_unretained id envTable; // array or dict
    bool envIsArray;
    bool vertical;
} AnalyzeEnv;

#ifdef DEBUG
#define DLOG(format, ...) NSLog(@"%s[%d]: "format, __FILE__, __LINE__,  ##__VA_ARGS__)
#else
#define DLOG(...)
#endif

#define SkipSpace(charPtr) while( isspace(*(charPtr)) ) ++(charPtr)

#define kDefaultSpace 8
static void buildConstraints(id leftView, NSArray* predicates, id rightView, AnalyzeEnv* env) {
    NSLayoutAttribute defAttr1, defAttr2;

    if (!leftView) { // [V]-|
        leftView = [rightView superview];
        defAttr1 = defAttr2 = env->vertical ?
            NSLayoutAttributeBottom : NSLayoutAttributeRight;
    } else if (!rightView) { // |-[V]
        rightView = [leftView superview];
        defAttr1 = defAttr2 = env->vertical ?
            NSLayoutAttributeTop : NSLayoutAttributeLeft;
    } else if (rightView == [NSNull null]){ // [V(...)]
        defAttr1 = defAttr2 = env->vertical ?
            NSLayoutAttributeHeight : NSLayoutAttributeWidth;
    } else { // [V]-[V]
        if (env->vertical) {
            defAttr1 = NSLayoutAttributeTop;
            defAttr2 = NSLayoutAttributeBottom;
        } else {
            defAttr1 = NSLayoutAttributeLeft;
            defAttr2 = NSLayoutAttributeRight;
        }
    }

    if (predicates.count == 0) { // flush layout [A][B]
        [env->constraints addObject:[NSLayoutConstraint
            constraintWithItem:leftView attribute:defAttr1
                     relatedBy:NSLayoutRelationEqual
                        toItem:rightView attribute:defAttr2
                    multiplier:1.0 constant:0]];
    } else if (predicates[0] == [NSNull null]) { // represent default connection
        [env->constraints addObject:[NSLayoutConstraint
            constraintWithItem:leftView attribute:defAttr1
                     relatedBy:NSLayoutRelationEqual
                        toItem:rightView attribute:defAttr2
                    multiplier:1.0 constant:kDefaultSpace]];
    } else { // contains specific predicate
        NSLayoutAttribute attr1, attr2;
        id view2;
        NSLayoutConstraint *constraint;
        for (Predicate* predicate in predicates){
            if (predicate->attr1) {
                attr1 = predicate->attr1;
                if (predicate->attr2) {
                    attr2 = predicate->attr2;
                } else {
                    attr2 = attr1;   // set 1, not set 2, 2 equal to 1
                }
            } else {
                attr1 = defAttr1;   // not set 1, use default
                if (predicate->attr2) {
                    attr2 = predicate->attr2;
                } else {
                    attr2 = defAttr2; // not set 2, use default
                }
            }
            if (rightView != [NSNull null]) view2 = rightView;
            else{
                if (predicate->view2 == [NSNull null])
                    view2 = [leftView superview];
                else
                    view2 = predicate->view2;
            }
            constraint = [NSLayoutConstraint
                constraintWithItem:leftView attribute:attr1
                         relatedBy:predicate->relation
                            toItem:view2 attribute:attr2
                        multiplier:predicate->multiplier
                          constant:predicate->constant];
            constraint.priority = predicate->priority;
            [env->constraints addObject:constraint];
        }
    }
}

static inline NSLayoutAttribute getAttr(char attrChar){
    switch( attrChar ){
        case 'L': return NSLayoutAttributeLeft;
        case 'R': return NSLayoutAttributeRight;
        case 'T': return NSLayoutAttributeTop;
        case 'B': return NSLayoutAttributeBottom;
        case 'X': return NSLayoutAttributeCenterX;
        case 'Y': return NSLayoutAttributeCenterY;
        case 'l': return NSLayoutAttributeLeading;
        case 't': return NSLayoutAttributeTrailing;
        case 'b': return NSLayoutAttributeBaseline;
        case 'W': return NSLayoutAttributeWidth;
        case 'H': return NSLayoutAttributeHeight;
        default: { return 0; }
    }
}

/** identifier begin with [a-zA-Z_], after may be [a-zA-Z0-9_] */
static inline const char* getIdentifier(const char* format){
    if (isalpha(*format) || *format == '_') { // begin with [a-zA-Z_]
        ++format;
        while ( isalnum(*format) || *format == '_') ++format;
    }
    return format;
}

/** try get indexValue, if found, set in out, and return end ptr. else return passin ptr */
static const char* _tryGetIndexValue(const char* format, AnalyzeEnv* env, id* out) {
    const char *it = format;

    if (env->envIsArray) {
        char* end;
        unsigned long index = strtoul(it, &end, 10);
        if ([env->envTable count]> index)
        {
            *out = env->envTable[index];
            return end;
        }
    } else {
        const char* begin = it;
        while ( isalnum(*it) || *it == '_' ) ++it; // identifier contains _A-Za-z0-9
        if (begin != it) {
            *out = [env->envTable objectForKey:[[NSString alloc]
                            initWithBytes:begin length:it-begin
                                 encoding:NSUTF8StringEncoding]];
            if (*out) return it;
        }
    }
    // get identifier fail
    *out = nil;
    return format;
}

static const char* tryGetIndexValue(const char* format, AnalyzeEnv* env, id* out) {
    const char* it = format;
    SkipSpace(it);
    if (*it == '$') {
        ++it;
        it = _tryGetIndexValue(it, env, out);
        if (!*out) {
            // TODO: Error, $must follow a indexValue
            DLOG(@"can't found indexValue %s", format);
        }
    } else if (*it == '|') { // superview
        ++it;
        *out = [NSNull null];  // use sharedinstance NSNull to represent superview;
    } else if (!env->envIsArray) { // dict $ may omit
        it = _tryGetIndexValue(it, env, out);
    }
    return *out ? it : format;
}

static const char* analyzeConstant(const char* format, AnalyzeEnv* env, CGFloat* outConstant) {
    char* end;
    CGFloat constant = strtod(format, &end);
    if (format != end) {
        *outConstant = constant;
        return end;
    } else {
        id out;
        end = (char*)tryGetIndexValue(format, env, &out);
        if (out) {
            if ([out isKindOfClass:[NSNumber class]]) {
                *outConstant = [out doubleValue];
                return end;
            }
        }
    }
    // fail, return origin
    return format;
}

static const char* analyzePredicateStatement(const char* format, AnalyzeEnv* env, Predicate** outPredicate) {
    // (<attr1>)?(<relation>)?(<viewIndex>)?(.?<attr2>)?(*<multiplier>)?<constant>(@<priority>)?
    // because each part is optional, need to check if is the later part
    *outPredicate = [Predicate new];
    bool isMinus = false;
    const char* identifierEnd;
    id obj;
    SkipSpace(format);
    // check first is number, if so, direct get as constant and jump to last
    if (((*outPredicate)->constant = strtod(format, (char**)&identifierEnd)),
            format != identifierEnd)
    {
        format = identifierEnd;
        goto Priority;
    }

#define CheckIndexValue()                                       \
    format = tryGetIndexValue(format, env, &obj);               \
    if (obj) {                                                  \
        if ( [obj isKindOfClass:[NSNumber class]] ) {           \
            (*outPredicate)->constant = [obj doubleValue];      \
            goto Priority;                                      \
        } else {                                                \
            (*outPredicate)->view2 = obj;                       \
            goto Attr2;                                         \
        }                                                       \
    }                                                           \

    // check if first is ViewIndex
    CheckIndexValue();

    // check attr1
    identifierEnd = getIdentifier(format);
    if ( identifierEnd != format ) {
        // it's attr1
        (*outPredicate)->attr1 = getAttr(*format);
        if ( (*outPredicate)->attr1 == 0 ) {
            // TODO: error, not recognized as attr1
            DLOG(@"format error: unexpect str %s", format);
        }
        // check if after is attr2, and jump over equal and view2
        if (identifierEnd - format == 2 && ((*outPredicate)->attr2 = getAttr(*(format+1))) != 0) {
            format = identifierEnd;
            goto Multiplier;
        }
        format = identifierEnd;
    }
    // check relation
    SkipSpace(format);
    if (*format == '='){
        (*outPredicate)->relation = NSLayoutRelationEqual;
        if (*++format == '=') ++format;
    } else if (*format == '<'){
        (*outPredicate)->relation = NSLayoutRelationLessThanOrEqual;
        if (*++format == '=') ++format;
    } else if (*format == '>') {
        (*outPredicate)->relation = NSLayoutRelationGreaterThanOrEqual;
        if (*++format == '=') ++format;
    }

    // check ViewIndex
    CheckIndexValue();
Attr2:
    SkipSpace(format);
    if (*format == '.') ++format;
    identifierEnd = getIdentifier(format);
    if (identifierEnd != format){
        (*outPredicate)->attr2 = getAttr(*format);
        if ( (*outPredicate)->attr2 == 0 ) {
            // TODO: error, not recognized as attr2 but has identifier
            DLOG(@"format error: unexpect str %s", format);
        }
        format = identifierEnd;
    }
Multiplier:
    SkipSpace(format);
    if (*format == '*'){
        format = analyzeConstant(format+1, env, &((*outPredicate)->multiplier));
    }

    // constant
    SkipSpace(format);
    if (*format == '+') {++format;}
    else if (*format == '-') {++format; isMinus = true;}
    format = analyzeConstant(format, env, &((*outPredicate)->constant));
    if (isMinus) (*outPredicate)->constant *= -1;

Priority:
    SkipSpace(format);
    if (*format == '@') {
        format = analyzeConstant(format+1, env, &((*outPredicate)->priority));
    }

    return format;
}

static const char* analyzePredicateListStatement(const char* format, AnalyzeEnv* env, NSMutableArray* predicates){
    Predicate* predicate;
    do
    {
        format = analyzePredicateStatement(format, env, &predicate);
        [predicates addObject:predicate];

        SkipSpace(format);
        if (*format != ',') break;
        ++format;
    }while( true );

    return format;
}

static const char* analyzeViewStatement(const char* format, AnalyzeEnv* env, id* outView) {
    SkipSpace(format);
    if (*format == '$') ++format;
    format = _tryGetIndexValue(format, env, outView);
    if (!*outView) {
        // TODO: Error!!
        DLOG(@"can't found identifier at %s!", format);
    }
    SkipSpace(format);
    if (*format == '(') { // view specific predicate
        NSMutableArray* predicates = [NSMutableArray new];
        format = analyzePredicateListStatement(format+1, env, predicates);
        buildConstraints(*outView, predicates, [NSNull null], env);
        SkipSpace(format);
        if (*format == ')') {
            ++format;
        } else {
            // TODO: Error
            DLOG(@"unclose ')'");
        }
    }
    return format;
}

static const char* analyzeStatement(const char* format, AnalyzeEnv* env) {
    SkipSpace(format);
    if (*format == 'V') { env->vertical = true; ++format; }
    else { env->vertical = false; }

    id firstView = nil;
    bool firstIsSuperView = false;
    id secondView = nil;
    NSMutableArray* connections = [NSMutableArray new];
    NSMutableArray* connectViews = [NSMutableArray new];

    do {
    CONTINUE_LOOP:
        switch( *format ){
            case '|': {
           superview:
                if (firstView) { // [V]-|
                    buildConstraints(nil, connections, firstView, env);

                    firstIsSuperView = true;
                    firstView = secondView = nil;
                    [connections removeAllObjects];
                } else { // first superview
                    firstIsSuperView = true;
                }
                break;
            }
            case '-': {
                ++format;   // skip -
                SkipSpace(format);
                if (*format == '[') { // [A]-[B], single -
                    [connections addObject:[NSNull null]]; // use NSNull to represet default connection
                    goto View;
                } else if (*format == '|') {
                    [connections addObject:[NSNull null]]; // use NSNull to represet default connection
                    goto superview;
                } else { // should be a Predicate list
                    format = analyzePredicateListStatement(format, env, connections);
                    SkipSpace(format);
                    if (*format == '-') {
                        ++format;
                    } else {
                        // TODO: Error, connection predicate list should end with -
                        DLOG(@"should end with -");
                    }
                    goto CONTINUE_LOOP;
                }
                DLOG(@"shouldn't exe!");
            }
            case '[': { // view statement
            View:
                format = analyzeViewStatement(format+1, env, &secondView);
                [connectViews addObject:secondView];
                if (firstView || firstIsSuperView) {
                    // for connection, use
                    // secondView.attr = firstView.attr * mul + constant
                    // so constant can use positive number to represent space
                    buildConstraints(secondView, connections, firstView, env);
                }

                firstView = secondView;
                secondView = nil;
                [connections removeAllObjects];

                SkipSpace(format);
                if (*format == ']') { ++format; }
                else {
                    // TODO: Error, view statement end with ];
                    DLOG(@"should end with ]");
                }
                goto CONTINUE_LOOP;
            }
            // align flags
            case 'L': [env->constraints addObjectsFromArray:[connectViews constrainsAlignAll:NSLayoutAttributeLeft]]     ; break;
            case 'R': [env->constraints addObjectsFromArray:[connectViews constrainsAlignAll:NSLayoutAttributeRight]]    ; break;
            case 'T': [env->constraints addObjectsFromArray:[connectViews constrainsAlignAll:NSLayoutAttributeTop]]      ; break;
            case 'B': [env->constraints addObjectsFromArray:[connectViews constrainsAlignAll:NSLayoutAttributeBottom]]   ; break;
            case 'X': [env->constraints addObjectsFromArray:[connectViews constrainsAlignAll:NSLayoutAttributeCenterX]]  ; break;
            case 'Y': [env->constraints addObjectsFromArray:[connectViews constrainsAlignAll:NSLayoutAttributeCenterY]]  ; break;
            case 'l': [env->constraints addObjectsFromArray:[connectViews constrainsAlignAll:NSLayoutAttributeLeading]]  ; break;
            case 't': [env->constraints addObjectsFromArray:[connectViews constrainsAlignAll:NSLayoutAttributeTrailing]] ; break;
            case 'b': [env->constraints addObjectsFromArray:[connectViews constrainsAlignAll:NSLayoutAttributeBaseline]] ; break;
            case 'W': [env->constraints addObjectsFromArray:[connectViews constrainsAlignAll:NSLayoutAttributeWidth]]    ; break;
            case 'H': [env->constraints addObjectsFromArray:[connectViews constrainsAlignAll:NSLayoutAttributeHeight]]   ; break;

            case ';': { ++format; } // ; mark this statement is end. exit
            case '\0': { goto exit; }
            default: { break; }
        }
        ++format;
    } while(true);
exit:
    return format;
}

#pragma mark - API

NSArray* constraintsWithFormat(NSString* format, id env) {
    NSCParameterAssert(format);
    NSCParameterAssert(env);

    NSMutableArray* constraints = [NSMutableArray new];
    AnalyzeEnv environment = {constraints, env, [env isKindOfClass:[NSArray class]], 0};
    const char* formatPtr = format.UTF8String;
    while(*formatPtr) {
        formatPtr = analyzeStatement(formatPtr, &environment);
    }

    return constraints;
}

id findCommonAncestor(id view1, id view2) {
    if (!view1) return view2;
    if (!view2 || view1 == view2) return view1;
    if ([view1 superview] == [view2 superview]) return [view1 superview];
    NSMutableSet* superviewSet = [NSMutableSet setWithObject:view1];
    UIView* superview = view1;
    while ((superview = [superview superview])) {
        if (superview == view2) return view2; // view2 is super of view1
        [superviewSet addObject:superview];
    }
    superview = view2;
    do {
        // view2 or view2 superview is view1's superview;
        if ([superviewSet containsObject:superview]) return superview;
    } while(( superview = [superview superview]) );

    return nil; // not found
}

