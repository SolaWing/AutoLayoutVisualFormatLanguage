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
#import <Foundation/Foundation.h>

#pragma mark - model
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
    NSString* name;
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


#pragma mark - CONSTRAINTS DICT

#pragma mark - ANALYZER
#ifdef DEBUG
#define DLOG(format, ...) NSLog(@"%s[%d]: "format, __FILE__, __LINE__,  ##__VA_ARGS__)
#else
#define DLOG(...)
#endif

#define SkipSpace(charPtr) while( isspace(*(charPtr)) ) ++(charPtr)

#define kDefaultSpace 8

static inline bool AttributeNeedPair(NSLayoutAttribute attr) {
    return attr != NSLayoutAttributeWidth && attr != NSLayoutAttributeHeight;
}

#define SUPER_TOKEN [NSNull null]
#define DEFAULT_CONNECTION_TOKEN [NSNull null]
static void buildConstraints(id leftView, NSArray* predicates, id rightView, AnalyzeEnv* env) {
    NSLayoutAttribute defAttr1, defAttr2;

    if (leftView == SUPER_TOKEN) { // [V]-|
        leftView = [rightView superview];
        NSCAssert(leftView, @"superview not exist!");

        defAttr1 = defAttr2 = env->vertical ?
            NSLayoutAttributeBottom : NSLayoutAttributeRight;
    } else if (rightView == SUPER_TOKEN) { // |-[V]
        rightView = [leftView superview];
        NSCAssert(rightView, @"superview not exist!");

        defAttr1 = defAttr2 = env->vertical ?
            NSLayoutAttributeTop : NSLayoutAttributeLeft;
    } else if (!rightView){ // [V(...)]
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
    } else if (predicates[0] == DEFAULT_CONNECTION_TOKEN) {
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
            if (rightView) view2 = rightView;
            else{ // [view(predicates)]
                if (predicate->view2 == SUPER_TOKEN ||
                    (!predicate->view2 && AttributeNeedPair(attr1)) )
                {
                    view2 = [leftView superview];
                } else {
                    view2 = predicate->view2;
                }
            }
            constraint = [NSLayoutConstraint
                constraintWithItem:leftView attribute:attr1
                         relatedBy:predicate->relation
                            toItem:view2 attribute:attr2
                        multiplier:predicate->multiplier
                          constant:predicate->constant];
            constraint.priority = predicate->priority;
            [env->constraints addObject:constraint];
            if (predicate->name.length > 0){ // if has name. associate it
                VFLSetObjectForKey(constraint, predicate->name);
            }
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
        NSCAssert1(*out, @"can't found indexValue at %s", format);
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

static inline const char* analyzeRelation(const char* format, NSLayoutRelation* outRelation){
    SkipSpace(format);
    if (*format == '='){
        *outRelation = NSLayoutRelationEqual;
        if (*++format == '=') ++format;
    } else if (*format == '<'){
        *outRelation = NSLayoutRelationLessThanOrEqual;
        if (*++format == '=') ++format;
    } else if (*format == '>') {
        *outRelation = NSLayoutRelationGreaterThanOrEqual;
        if (*++format == '=') ++format;
    }
    return format;
}

static const char* analyzePredicateStatement(const char* format, AnalyzeEnv* env, Predicate** outPredicate) {
    // (<identifier>:)?(<attr1>)?(<relation>)?(<viewIndex>)?(.?<attr2>)?(*<multiplier>)?(<constant>)?(@<priority>)?
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

#define JumpAccordingToIndexValueType(obj)              \
    if ( [obj isKindOfClass:[NSNumber class]] ) {       \
        (*outPredicate)->constant = [obj doubleValue];  \
        goto Priority;                                  \
    } else {                                            \
        (*outPredicate)->view2 = obj;                   \
        goto Attr2;                                     \
    }                                                   \

    identifierEnd = getIdentifier(format);
    if (identifierEnd != format) {
        // check if if a predicate name
        if ( *identifierEnd == ':')
        {
            (*outPredicate)->name = [[NSString alloc] initWithBytes:format
                length:identifierEnd - format encoding:NSUTF8StringEncoding];
            format = identifierEnd + 1; // skip :
        } else {
            if (!env->envIsArray) { // dict index, check if is and may jump
                obj = [env->envTable objectForKey:[[NSString alloc]
                                    initWithBytes:format length:identifierEnd-format
                                         encoding:NSUTF8StringEncoding]];
                if (obj) {
                    format = identifierEnd;
                    JumpAccordingToIndexValueType(obj);
                }
            }
            // it's attr1
            (*outPredicate)->attr1 = getAttr(*format);
            NSCAssert1((*outPredicate)->attr1 != 0, @"format error: unexpect attr type %c", *format);
            format = identifierEnd;
        }
    }

    // check relation
    format = analyzeRelation(format, &((*outPredicate)->relation));

    // check ViewIndex
    SkipSpace(format);
    if (*format == '|') { // check superview
        ++format;
        (*outPredicate)->view2 = SUPER_TOKEN;
    } else {
        format = tryGetIndexValue(format, env, &obj);
        if (obj) {
            JumpAccordingToIndexValueType(obj);
        }
    }

Attr2:
    SkipSpace(format);
    if (*format == '.') ++format;
    identifierEnd = getIdentifier(format);
    if (identifierEnd != format){
        (*outPredicate)->attr2 = getAttr(*format);
        if ( (*outPredicate)->attr2 != 0 ) {
            format = identifierEnd; // recognized
        }
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
    NSCAssert1(*outView, @"can't found identifier at %s!", format);
    SkipSpace(format);
    if (*format == '(') { // view specific predicate
        NSMutableArray* predicates = [NSMutableArray new];
        format = analyzePredicateListStatement(format+1, env, predicates);
        buildConstraints(*outView, predicates, nil, env);
        SkipSpace(format);
        if (*format == ')') {
            ++format;
        } else {
            DLOG(@"[WARN] unclose ')'");
        }
    }
    return format;
}

static const char* analyzeStatement(const char* format, AnalyzeEnv* env) {
    SkipSpace(format);
    // set H or V according to label. if not set, don't change.(init default to H)
    if (*format == 'V') { env->vertical = true; ++format; }
    else if (*format == 'H') { env->vertical = false; }

    id firstView = nil;
    id secondView = nil;
    NSMutableArray* connections = [NSMutableArray new];
    NSMutableArray* connectViews = [NSMutableArray new];

    do {
    CONTINUE_LOOP:
        switch( *format ){
            case '|': {
           superview:
                if (firstView) { // [V]-|
                    buildConstraints(SUPER_TOKEN, connections, firstView, env);

                    firstView = SUPER_TOKEN;
                    secondView = nil;
                    [connections removeAllObjects];
                } else { // first superview
                    firstView = SUPER_TOKEN;
                }
                break;
            }
            case '-': {
                ++format;   // skip -
                SkipSpace(format);
                if (*format == '[') { // [A]-[B], single -
                    [connections addObject:DEFAULT_CONNECTION_TOKEN];
                    goto View;
                } else if (*format == '|') {
                    [connections addObject:DEFAULT_CONNECTION_TOKEN];
                    goto superview;
                } else { // should be a Predicate list
                    if (*format == '(') ++format; // may enclosed by a ()

                    format = analyzePredicateListStatement(format, env, connections);

                    SkipSpace(format);
                    if (*format == ')') {
                        ++format; SkipSpace(format);
                    }
                    if (*format == '-') {
                        ++format;
                    } else {
                        DLOG(@"[WARN] predicate connection should end with -");
                    }
                    goto CONTINUE_LOOP;
                }
                NSCAssert(NO, @"shouldn't exe!");
            }
            case '[': { // view statement
            View:
                format = analyzeViewStatement(format+1, env, &secondView);
                [connectViews addObject:secondView];
                if (firstView) {
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
                    DLOG(@"[WARN] view statement should end with ]");
                }
                goto CONTINUE_LOOP;
            }
            // align flags
            case 'L': [env->constraints addObjectsFromArray:[connectViews constraintsAlignAllViews:NSLayoutAttributeLeft]]     ; break;
            case 'R': [env->constraints addObjectsFromArray:[connectViews constraintsAlignAllViews:NSLayoutAttributeRight]]    ; break;
            case 'T': [env->constraints addObjectsFromArray:[connectViews constraintsAlignAllViews:NSLayoutAttributeTop]]      ; break;
            case 'B': [env->constraints addObjectsFromArray:[connectViews constraintsAlignAllViews:NSLayoutAttributeBottom]]   ; break;
            case 'X': [env->constraints addObjectsFromArray:[connectViews constraintsAlignAllViews:NSLayoutAttributeCenterX]]  ; break;
            case 'Y': [env->constraints addObjectsFromArray:[connectViews constraintsAlignAllViews:NSLayoutAttributeCenterY]]  ; break;
            case 'l': [env->constraints addObjectsFromArray:[connectViews constraintsAlignAllViews:NSLayoutAttributeLeading]]  ; break;
            case 't': [env->constraints addObjectsFromArray:[connectViews constraintsAlignAllViews:NSLayoutAttributeTrailing]] ; break;
            case 'b': [env->constraints addObjectsFromArray:[connectViews constraintsAlignAllViews:NSLayoutAttributeBaseline]] ; break;
            case 'W': [env->constraints addObjectsFromArray:[connectViews constraintsAlignAllViews:NSLayoutAttributeWidth]]    ; break;
            case 'H': [env->constraints addObjectsFromArray:[connectViews constraintsAlignAllViews:NSLayoutAttributeHeight]]   ; break;

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

NSArray<NSLayoutConstraint*>* VFLConstraints(NSString* format, id env) {
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

NSArray<NSLayoutConstraint*>* VFLInstall(NSString* format, id env) {
    NSArray* ret = VFLConstraints(format, env);
    [ret activateConstraints];
    return ret;
}

NSArray<NSLayoutConstraint*>* VFLFullInstall(NSString* format, id env) {
    [env translatesAutoresizingMaskIntoConstraints:NO];
    NSArray* ret = VFLConstraints(format, env);
    [ret activateConstraints];
    return ret;
}

NSArray<NSLayoutConstraint*>* VFLViewConstraints(NSString* format, UIView* view, id env) {
    NSCParameterAssert(format);
    NSCParameterAssert(view);
    NSCParameterAssert(env);

    NSMutableArray* constraints = [NSMutableArray new];
    AnalyzeEnv environment = {constraints, env, [env isKindOfClass:[NSArray class]], 0};
    const char* formatPtr = format.UTF8String;

    NSMutableArray* predicates = [NSMutableArray new];
    formatPtr = analyzePredicateListStatement(formatPtr, &environment, predicates);
    buildConstraints(view, predicates, nil, &environment);

    return constraints;
}

UIView* findCommonAncestor(UIView* view1, UIView* view2) {
    // this is the most common case, so test it first
    if (!view1) return view2;
    if (!view2 || view1 == view2) return view1;
    if ([view1 superview] == [view2 superview]) return [view1 superview];
    if ([view2 superview] == view1) return view1;

    NSMutableSet* superviewSet = [NSMutableSet setWithObject:view1];
    UIView* superview = view1;
    while ((superview = [superview superview])) {
        if (superview == view2) return view2; // view2 is superview of view1
        [superviewSet addObject:superview];
    }
    superview = view2;
    do {
        // view2 or view2 superview is view1's superview;
        if ([superviewSet containsObject:superview]) return superview;
    } while(( superview = [superview superview]) );

    return nil; // not found
}


static NSMapTable* constraintsRepository =  nil;
id VFLObjectForKey(NSString* key) {
    if (!constraintsRepository) return nil;
    return [constraintsRepository objectForKey:key];
}

void VFLSetObjectForKey(id obj, NSString* key) {
    NSCParameterAssert(obj);
    NSCParameterAssert(key);
    if (!constraintsRepository) {
        constraintsRepository = [NSMapTable strongToWeakObjectsMapTable];
    }
    [constraintsRepository setObject:obj forKey:key];
}

