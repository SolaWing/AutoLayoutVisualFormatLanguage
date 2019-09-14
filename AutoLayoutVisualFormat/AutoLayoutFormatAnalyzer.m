//  Gihhub: https://github.com/SolaWing/AutoLayoutVisualFormatLanguage
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
    __unsafe_unretained id env; // array or dict
    bool envIsArray;
    bool vertical;
} AnalyzeEnv;

bool VFLEnableAssert = 0;

#define RELEASEWarn(desc, ...) { \
NSString *__assert_fn__ = [NSString stringWithUTF8String:__PRETTY_FUNCTION__]; \
__assert_fn__ = __assert_fn__ ? __assert_fn__ : @"<Unknown Function>"; \
NSString *__assert_file__ = [NSString stringWithUTF8String:__FILE__]; \
__assert_file__ = __assert_file__ ? __assert_file__ : @"<Unknown File>"; \
[[NSAssertionHandler currentHandler] handleFailureInFunction:__assert_fn__ \
file:__assert_file__ \
lineNumber:__LINE__ description:(desc), ##__VA_ARGS__]; \
}

#ifdef DEBUG

#define DLOG(format, ...) NSLog(@"%s:%d: "format, __FILE__, __LINE__,  ##__VA_ARGS__)
#define WARN(...) RELEASEWarn(__VA_ARGS__)
#define WARNWithFormat(desc, ...) RELEASEWarn(desc " (left: %s)", ##__VA_ARGS__, format)

#else

#define DLOG(...)
#define WARN(format, ...)                                            \
    if (VFLEnableAssert) {                                           \
        RELEASEWarn(format, ##__VA_ARGS__);                          \
    } else {                                                         \
        NSLog(@"%s:%d: " format, __FILE__, __LINE__, ##__VA_ARGS__); \
    }
#define WARNWithFormat(desc, ...) WARN(desc "(left: %s)", ##__VA_ARGS__, format)

#endif

#define Assert(_condition_, ...) \
    if (__builtin_expect(!(_condition_), 0)) { WARN(__VA_ARGS__); }

#define SkipSpace(charPtr) while( isspace(*(charPtr)) ) {++(charPtr);}

#define kDefaultSpace 8

#pragma mark - Getter
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

/** try convert format to a string identifier */
static inline const char* getKey(const char* format, __strong NSString** out) {
    const char* end = getIdentifier(format);
    if (end != format) {
        *out = CFBridgingRelease(CFStringCreateWithBytesNoCopy(nil, (void*)format, end-format,
                    kCFStringEncodingUTF8, NO, kCFAllocatorNull));
    } else {
        *out = nil;
    }
    return end;
}

/** try get indexValue, if found, set in out, and return end ptr. else return passin ptr */
static const char* _tryGetIndexValue(const char* format, AnalyzeEnv* env, id* out) {
    const char* it;

    if (env->envIsArray) {
        unsigned long index = strtoul(format, (char**)&it, 10);
        if ( format != it && [env->env count] > index)
        {
            *out = env->env[index];
            return it;
        }
    } else {
        NSString* key;
        it = getKey(format, &key);
        if (format != it) {
            *out = [env->env objectForKey:key];
            if (*out) return it;
        }
    }
    // get identifier fail
    *out = nil;
    return format;
}

static const char* tryGetIndexValue(const char* format, AnalyzeEnv* env, id* out) {
    const char* it;
    if (*format == '$') {
        ++format;
        it = _tryGetIndexValue(format, env, out);
        Assert(*out, @"can't found indexValue at %s", format);
        return it;
    } else if (!env->envIsArray) { // dict $ may omit
        it = _tryGetIndexValue(format, env, out);
        if (out) {
            return it;
        }
    }
    return format;
}

static inline bool AttributeNeedPair(NSLayoutAttribute attr) {
    return attr != NSLayoutAttributeWidth && attr != NSLayoutAttributeHeight;
}


#pragma mark - ANALYZER

#define SUPER_TOKEN [NSNull null]
#define DEFAULT_CONNECTION_TOKEN [NSNull null]
/** create constraint and add it into constraints
 * @param leftView view at equation left.
 * @param rightView view at equation right.
 * */
static void buildConstraints(id leftView, NSArray* predicates, id rightView, bool vertical, NSMutableArray* constraints) {
    NSLayoutAttribute defAttr1, defAttr2;

    if (leftView == SUPER_TOKEN) { // [V]-|
        leftView = [rightView superview];
        Assert(leftView, @"superview not exist!");

        defAttr1 = defAttr2 = vertical ?
            NSLayoutAttributeBottom : NSLayoutAttributeRight;
    } else if (rightView == SUPER_TOKEN) { // |-[V]
        rightView = [leftView superview];
        Assert(rightView, @"superview not exist!");

        defAttr1 = defAttr2 = vertical ?
            NSLayoutAttributeTop : NSLayoutAttributeLeft;
    } else if (!rightView){ // [V(...)]
        defAttr1 = defAttr2 = vertical ?
            NSLayoutAttributeHeight : NSLayoutAttributeWidth;
    } else { // [V]-[V]
        if (vertical) {
            defAttr1 = NSLayoutAttributeTop;
            defAttr2 = NSLayoutAttributeBottom;
        } else {
            defAttr1 = NSLayoutAttributeLeft;
            defAttr2 = NSLayoutAttributeRight;
        }
    }

    if (predicates.count == 0) { // flush layout [A][B]
        [constraints addObject:[NSLayoutConstraint
            constraintWithItem:leftView attribute:defAttr1
                     relatedBy:NSLayoutRelationEqual
                        toItem:rightView attribute:defAttr2
                    multiplier:1.0 constant:0]];
    } else if (predicates[0] == DEFAULT_CONNECTION_TOKEN) { // [A]-[B]
        [constraints addObject:[NSLayoutConstraint
            constraintWithItem:leftView attribute:defAttr1
                     relatedBy:NSLayoutRelationEqual
                        toItem:rightView attribute:defAttr2
                    multiplier:1.0 constant:kDefaultSpace]];
    } else { // contains specific predicate
        NSLayoutAttribute attr1, attr2;
        id view2;
        NSLayoutConstraint *constraint;
        for (Predicate* predicate in predicates){
            // set attr1, attr2
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
            // set rightView
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
            [constraints addObject:constraint];
            if (predicate->name.length > 0){ // if has name. associate it
                VFLSetObjectForKey(constraint, predicate->name);
            }
        }
    }
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
    (*outPredicate)->constant = strtod(format, (char**)&identifierEnd);
    // check first is number, this is a common use case. if so, direct get as constant and jump to last
    if (format != identifierEnd)
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
        // check if it's a predicate name
        if ( *identifierEnd == ':')
        {
            (*outPredicate)->name = [[NSString alloc] initWithBytes:format
                length:identifierEnd - format encoding:NSUTF8StringEncoding];
            format = identifierEnd + 1; // skip :
            SkipSpace(format);
            identifierEnd = getIdentifier(format);
        }
        if (identifierEnd != format) {
            if (!env->envIsArray) { // dict index, check if is and may jump
                NSString* key = CFBridgingRelease(CFStringCreateWithBytesNoCopy(
                            nil, (void*)format, identifierEnd-format,
                            kCFStringEncodingUTF8, NO, kCFAllocatorNull));
                obj = [env->env objectForKey:key];
                if (obj) {
                    format = identifierEnd;
                    JumpAccordingToIndexValueType(obj);
                }
            }
            // it's attr1
            (*outPredicate)->attr1 = getAttr(*format);
            Assert((*outPredicate)->attr1 != 0, @"format error: unexpect attr type %c", *format);
            format = identifierEnd;
        }
    }

    // check relation
    SkipSpace(format);
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

// Multiplier:
    SkipSpace(format);
    if (*format == '*'){
        ++format;
        SkipSpace(format);
        identifierEnd = analyzeConstant(format, env, &((*outPredicate)->multiplier));
        Assert( identifierEnd != format, @"* should follow metric. at %s", format);
        format = identifierEnd;
    }

    // constant
    SkipSpace(format);
    if (*format == '+') {++format; SkipSpace(format);}
    else if (*format == '-') {++format; isMinus = true; SkipSpace(format);}
    format = analyzeConstant(format, env, &((*outPredicate)->constant));
    if (isMinus) (*outPredicate)->constant *= -1;

Priority:
    SkipSpace(format);
    if (*format == '@') {
        ++format;
        SkipSpace(format);
        identifierEnd = analyzeConstant(format, env, &((*outPredicate)->priority));
        Assert( identifierEnd != format, @"@ should follow priority. at %s", format);
        format = identifierEnd;
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
        if (*format != ',') {break;} // predicate, predicate, ...
        ++format;
    }while( true );

    return format;
}

static const char* analyzeViewStatement(const char* format, AnalyzeEnv* env, UIView** outView, NSMutableArray** outConstraints) {
    SkipSpace(format);
    if (*format == '$') ++format;
    format = _tryGetIndexValue(format, env, outView);
    // outView should be UIView or layoutGuide
    Assert(*outView, @"can't found identifier at %s!", format);

    SkipSpace(format);
    if (*format == '!') { (*outView).translatesAutoresizingMaskIntoConstraints = NO; ++format; SkipSpace(format); }
    bool wrapInParen = false;
    if (*format == '(') {
        // [view(predicateList)]: view specific predicate
        // now the paren is optional. (Swift interpolate syntax is odd with paren)
        // TODO: test
        wrapInParen = true;
        ++format;
    }

    *outConstraints = [NSMutableArray new];
    NSMutableArray* predicates = [NSMutableArray new];
    format = analyzePredicateListStatement(format, env, predicates);
    buildConstraints(*outView, predicates, nil, env->vertical, *outConstraints);
    SkipSpace(format);

    if (wrapInParen) {
        if (*format == ')') {
            ++format;
        } else {
            WARNWithFormat(@"[WARN] unclose ')'");
        }
    }
    return format;
}

static const char* analyzeStatement(const char* format, AnalyzeEnv* env) {
    SkipSpace(format);
    // set H or V according to label. if not set, don't change.(init default to H)
    if (*format == 'V') {
        env->vertical = true;
        Assert(*(format+1) == ':', @"V should followed by :!");
        format += 2;
    } else if (*format == 'H') {
        env->vertical = false;
        Assert(*(format+1) == ':', @"H should followed by :!");
        format += 2;
    }

    id firstView = nil;   ///< view at the - connection left
    id secondView = nil;  ///< view at the - connection right
    NSMutableArray* connections = [NSMutableArray new];   ///< connection constraints between two view.
    NSMutableArray* connectViews = [NSMutableArray new];  ///< collect all view show in [], used for batch align.
    NSMutableArray* viewConstraints; ///< use to hold constraints in [view(predicateList)]

    do {
    CONTINUE_LOOP:
        switch( *format ){
            case '|': {
           Superview:
                if (firstView) { // [V]-|
                    buildConstraints(SUPER_TOKEN, connections, firstView, env->vertical, env->constraints);

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
                    goto Superview;
                } else { // should be a Predicate list
                    if (*format == '(') { ++format; } // may enclosed by a ()

                    format = analyzePredicateListStatement(format, env, connections);

                    SkipSpace(format);
                    if (*format == ')') {
                        ++format; SkipSpace(format);
                    }
                    if (*format == '-') {
                        ++format;
                    } else {
                        WARNWithFormat(@"[WARN] predicate connection should end with -");
                    }
                    goto CONTINUE_LOOP;
                }
                Assert(NO, @"shouldn't happen!");
            }
            case '[': { // view statement
            View:
                format = analyzeViewStatement(format+1, env, &secondView, &viewConstraints);
                [connectViews addObject:secondView];
                if (firstView) {
                    // for connection, use
                    // secondView.attr = firstView.attr * mul + constant
                    // so constant can use positive number to represent space
                    buildConstraints(secondView, connections, firstView, env->vertical, env->constraints);
                }
                if (viewConstraints) { // guarantee constraint create order from left to right
                     [env->constraints addObjectsFromArray:viewConstraints];
                }

                firstView = secondView;
                secondView = nil;
                [connections removeAllObjects];

                SkipSpace(format);
                if (*format == ']') { ++format; }
                else {
                    WARNWithFormat(@"[WARN] view statement should end with ]");
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

            case '!': [connectViews translatesAutoresizingMaskIntoConstraints:NO]; break;

            case ';': { ++format; } // ; mark this statement is end. exit
            case '\0': { goto exit; }
            case ' ': case '\t': case '\n': { break; }
            default: { WARNWithFormat(@"[WARN] shouldn't enter!"); break; }
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
    AnalyzeEnv environment = {constraints, env, [env isKindOfClass:[NSArray class]], false};
    const char* formatPtr = format.UTF8String;
    while(*formatPtr) {
        formatPtr = analyzeStatement(formatPtr, &environment);
    }

    return constraints;
}

NSArray<NSLayoutConstraint*>* VFLInstall(NSString* format, id env) {
    NSArray* ret = VFLConstraints(format, env);
    [NSLayoutConstraint activateConstraints:ret];
    return ret;
}

NSArray<NSLayoutConstraint*>* VFLFullInstall(NSString* format, id env) {
    [env translatesAutoresizingMaskIntoConstraints:NO];
    NSArray* ret = VFLConstraints(format, env);
    [NSLayoutConstraint activateConstraints:ret];
    return ret;
}

NSArray<NSLayoutConstraint*>* VFLViewConstraints(NSString* formatString, UIView* view, id env) {
    NSCParameterAssert(formatString);
    NSCParameterAssert(view);
    NSCParameterAssert(env);

    NSMutableArray* constraints = [NSMutableArray new];
    AnalyzeEnv environment = {constraints, env, [env isKindOfClass:[NSArray class]], 0};
    const char* format = formatString.UTF8String;

    NSMutableArray* predicates = [NSMutableArray new];
    format = analyzePredicateListStatement(format, &environment, predicates);
    if (*format != '\0') {
        WARNWithFormat(@"[WARN] unfinish formatString");
    }

    buildConstraints(view, predicates, nil, NO, constraints);

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
    NSCParameterAssert(key);
    if (obj) {
        if (!constraintsRepository) {
            constraintsRepository = [NSMapTable mapTableWithKeyOptions:NSMapTableCopyIn valueOptions:NSMapTableWeakMemory];
        }
        [constraintsRepository setObject:obj forKey:key];
    } else if (constraintsRepository) {
        [constraintsRepository removeObjectForKey:key];
    }
}
