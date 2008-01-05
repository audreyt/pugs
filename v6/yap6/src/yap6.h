
#ifndef __YAP6_H
#define __YAP6_H

#include <pthread.h>
#include <sys/types.h>
#include <complex.h>

// forward declarations
struct YAP6__Object; typedef struct YAP6__Object YAP6__Object;
struct YAP6__Prototype; typedef struct YAP6__Prototype YAP6__Prototype;
struct YAP6__MetaClass; typedef struct YAP6__MetaClass YAP6__MetaClass;

/*
 * The YAP6__Object struct represents any object in the YAP6 runtime.
 * The data of this object should be opaque for the users, the only
 * ones that should know about it are the prototype and the
 * metaclass. Every object must have a prototype. If it doesn't, it
 * is considered itself as one.
 */
struct YAP6__Object {
  YAP6__Prototype* WHAT;
};

/*
 * The YAP6__Prototype struct represents a prototype object. Every
 * object have a prototype unless it is itself one.  The prototype
 * have the object implementation, but only the metaclass knows HOW it
 * is laid out. And the metaclass is the way to fetch it.  A prototype
 * without a metaclass is a metaclass.
 */
struct YAP6__Prototype {
  YAP6__Prototype* WHAT;
  YAP6__MetaClass* HOW;
};

/*
 * The YAP6__MetaClass represents the HOW of any object. It
 * understands the object layout to know how to access the methods
 * defined in the prototype, dispatching the methods.  This finish the
 * basic triade, as the interpreter delegates to the metaclass the
 * message.  REFERENCE is called every time an object is referenced in
 * some other place. RELEASE is called every time an reference is
 * released. This doesn't mean that every object need to be
 * refcounted, but without it it would be impossible to implement a
 * refcount gc. Both methods return the input pointer.
 */
struct YAP6__MetaClass {
  YAP6__Prototype* WHAT;
  YAP6__MetaClass* HOW;
  YAP6__Object* (*MESSAGE)   (YAP6__MetaClass* self,
                              YAP6__Object* identifier,
                              YAP6__Object* capture);
  YAP6__Object* (*REFERENCE) (YAP6__MetaClass* self,
                              YAP6__Object* object);
  YAP6__Object* (*RELEASE)   (YAP6__MetaClass* self,
                              YAP6__Object* object);
}

/* Every object in YAP6 must be binary compatible with one of these
 * three. Given that, not necessarly needs to be created by yap6
 * itself, they don't even need to be managed by YAP6. Each MetaClass
 * implementation can decide how to deal with issues like garbage
 * collection and so on, as every object interaction is intermediated
 * by a MetaClass MESSAGE. But to support basic refcounting, two other
 * metaclass methods must exist. They can be no-ops for some
 * metaclasses, but the interpreter will always call them.
 */

/* 
 * Here follows the basic macros for that triade.
 */
#define YAP6_WHAT(object) ((YAP6__Prototype*)((((YAP6__Object*)object)->WHAT)?(((YAP6__Object*)object)->WHAT):(object)))

#define YAP6_HOW(object) ((YAP6__MetaClass*)( \
                          (((YAP6__Prototype*)((((YAP6__Object*)object)->WHAT)?(((YAP6__Object*)object)->WHAT):(object)))->HOW) ? \
                          (((YAP6__Prototype*)((((YAP6__Object*)object)->WHAT)?(((YAP6__Object*)object)->WHAT):(object)))->HOW) : \
                          (object)\
                         ))

#define YAP6_DISPATCH(metaclass, identifier, capture) ((YAP6__MetaClass*)metaclass)->MESSAGE((YAP6__MetaClass*)metaclass,\
                                                                                             (YAP6__Object*)identifier,\
                                                                                             (YAP6__Object*)capture)

#define YAP6_REFERENCE(object) (((YAP6__MetaClass*)( \
                          (((YAP6__Prototype*)((((YAP6__Object*)object)->WHAT)?(((YAP6__Object*)object)->WHAT):(object)))->HOW) ? \
                          (((YAP6__Prototype*)((((YAP6__Object*)object)->WHAT)?(((YAP6__Object*)object)->WHAT):(object)))->HOW) : \
                          (object)\
                         ))->REFERENCE(((YAP6__MetaClass*)( \
                          (((YAP6__Prototype*)((((YAP6__Object*)object)->WHAT)?(((YAP6__Object*)object)->WHAT):(object)))->HOW) ? \
                          (((YAP6__Prototype*)((((YAP6__Object*)object)->WHAT)?(((YAP6__Object*)object)->WHAT):(object)))->HOW) : \
                          (object)\
                         )),object))

#define YAP6_RELEASE(object) (((YAP6__MetaClass*)( \
                          (((YAP6__Prototype*)((((YAP6__Object*)object)->WHAT)?(((YAP6__Object*)object)->WHAT):(object)))->HOW) ? \
                          (((YAP6__Prototype*)((((YAP6__Object*)object)->WHAT)?(((YAP6__Object*)object)->WHAT):(object)))->HOW) : \
                          (object)\
                         ))->RELEASE(((YAP6__MetaClass*)( \
                          (((YAP6__Prototype*)((((YAP6__Object*)object)->WHAT)?(((YAP6__Object*)object)->WHAT):(object)))->HOW) ? \
                          (((YAP6__Prototype*)((((YAP6__Object*)object)->WHAT)?(((YAP6__Object*)object)->WHAT):(object)))->HOW) : \
                          (object)\
                         )),object))

/*
 * Besides the basic structures to which all objects must be
 * binary-compatible with, we also need to have defined which are the
 * native types for YAP6. These types are the key for the YAP6 runtime
 * being able to actually do something in the low-level. The key to
 * that is in S12:
 *
 *       You may derive from any built-in type, but the derivation of
 *       a low-level type like int may only add behaviors, not change
 *       the representation. Use composition and/or delegation to
 *       change the representation.
 *
 * This means that the native objects can have a fixed structure. As
 * they are known and fixed, we can intermix high-level calls and
 * low-level calls. An important thing then, is that the autoboxing
 * from the native types to the immutable types must be available in
 * both ways, as the non-native implementations may even be some
 * object that acts like a Int, so we can only use it by calling the
 * metaclass.
 *
 * This means that, besides having a way to enforce numeric context to
 * all values, we need a way to also force native-type-context to that
 * value. Which would be something like:
 *
 *       my $a = +$someobject; # Returns Int, Num, Complex or even Rat
 *       my $b = $a.$native_int_method(); # returns that as int
 *       my $b = $a.$native_float_method(); # returns that as float
 *
 * The thing is, this methods will be part of the API of any object
 * that emulates one of the types that can be autoboxed to/from native
 * types.  Considering that a Int is any object that returns true to
 * .^does(Int), the low-level runtime cannot presume to know which is
 * the lowlevel implementation of an object, the only that knows it is
 * the metaclass, so it's natural that this native-type coercion
 * methods reside in the metaclass. This way, YAP6 will count on the
 * metaclasses to provide a "native" method that receives the
 * prototype of the native-type to convert to and returns a
 * native-type object. One, possibly more important, reason for the
 * "native" method to reside in the metaclass is because a metaclass
 * will require at least some C code, and creating the lowlevel
 * objects are C calls, so we concentrate that on the metaclass.
 *
 * But this doesn't mean that every metaclass must implement it
 * directly. The call to native may result in a call to coerce to the
 * respective high-level type before.
 *
 * It's important to realize that the native-type objects are binary
 * compatible with any other object, but as they can't have they
 * representation changed, they can't be extended, and the only
 * prototype that can answer true to .^does(int) is the lowlevel int
 * implementation. It is considered illegal to answer true to that for
 * any other prototype, as this would certainly cause a segfault.
 */


/*
 * The native types are then declared here for external use.
 */
extern YAP6__Prototype* YAP6__NATIVE__bit;
extern YAP6__Prototype* YAP6__NATIVE__int;
extern YAP6__Prototype* YAP6__NATIVE__uint;
extern YAP6__Prototype* YAP6__NATIVE__buf;
extern YAP6__Prototype* YAP6__NATIVE__num;
extern YAP6__Prototype* YAP6__NATIVE__complex;
extern YAP6__Prototype* YAP6__NATIVE__bool;

/*
 * And so as its lowlevel API.
 */

// create methods
extern YAP6__NATIVE__bit*     YAP6__NATIVE__bit_create(int value);
extern YAP6__NATIVE__int*     YAP6__NATIVE__int_create(int value);
extern YAP6__NATIVE__uint*    YAP6__NATIVE__uint_create(unsigned int value);
extern YAP6__NATIVE__buf*     YAP6__NATIVE__buf_create(int bytesize, char* unicodestr);
extern YAP6__NATIVE__num*     YAP6__NATIVE__num_create(double value);
extern YAP6__NATIVE__complex* YAP6__NATIVE__complex_create(double complex value);
extern YAP6__NATIVE__bool*    YAP6__NATIVE__bool_create(int value);

// get methods
extern int                    YAP6__NATIVE__bit_fetch(YAP6__NATIVE__bit* value);
extern int                    YAP6__NATIVE__int_fetch(YAP6__NATIVE__int* value);
extern unsigned int           YAP6__NATIVE__uint_fetch(YAP6__NATIVE__uint* value);
extern char*                  YAP6__NATIVE__buf_fetch(YAP6__NATIVE__buf* value, int* retsize);
extern double                 YAP6__NATIVE__num_fetch(YAP6__NATIVE__num* value);
extern double complex         YAP6__NATIVE__complex_fetch(YAP6__NATIVE__complex* value);
extern int                    YAP6__NATIVE__bool_fetch(YAP6__NATIVE__bool* value);

// set methods
extern void                   YAP6__NATIVE__bit_store(YAP6__NATIVE__bit* value, int newvalue);
extern void                   YAP6__NATIVE__int_store(YAP6__NATIVE__int* value, int newvalue);
extern void                   YAP6__NATIVE__uint_store(YAP6__NATIVE__uint* value, unsigned int newvalue);
extern void                   YAP6__NATIVE__buf_store(YAP6__NATIVE__buf* value, int newbytesize, char* newvalue);
extern void                   YAP6__NATIVE__num_store(YAP6__NATIVE__num* value, double newvalue);
extern void                   YAP6__NATIVE__complex_store(YAP6__NATIVE__complex* value, double complex newvalue);
extern void                   YAP6__NATIVE__bool_store(YAP6__NATIVE__bool* value, int newvalue);

#endif
