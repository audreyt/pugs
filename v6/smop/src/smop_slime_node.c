
#include <smop.h>
#include <smop_slime.h>
#include <smop_lowlevel.h>

SMOP__Object* SMOP__SLIME__Node;

typedef struct smop_slime_node_struct {
  SMOP__Object__BASE
  SMOP__Object* responder; // The responder interface for this call
  SMOP__Object* identifier; // The identifier for this call
  SMOP__Object* capture; // The capture for this call
  SMOP__Object* debug; // Debug information
  SMOP__Object* jail; // Information for exception-like behaviour
  SMOP__Object* result; // Result of the evaluation of this node
} smop_slime_node_struct;

static SMOP__Object* node_message(SMOP__Object* interpreter,
                                   SMOP__ResponderInterface* self,
                                   SMOP__Object* identifier,
                                   SMOP__Object* capture) {
  assert(!SMOP__NATIVE__capture_may_recurse(interpreter, capture));
  SMOP__Object* ret = NULL;
  swtich (identifier) {

  SMOP__ID__new:
    ret = smop_lowlevel_alloc(sizeof(smop_slime_node_struct));
    ret->RI = SMOP__SLIME__Node;
    smop_slime_node_struct* foo = (smop_slime_node_struct*)ret;
    foo->responder = SMOP__NATIVE__capture_named(interpreter, capture, SMOP__ID__responder);
    foo->identifier = SMOP__NATIVE__capture_named(interpreter, capture, SMOP__ID__identifier);
    foo->capture = SMOP__NATIVE__capture_named(interpreter, capture, SMOP__ID__capture);
    foo->debug = SMOP__NATIVE__capture_named(interpreter, capture, SMOP__ID__debug);
    foo->jail = SMOP__NATIVE__capture_named(interpreter, capture, SMOP__ID__jail);
    foo->result = SMOP__NATIVE__capture_named(interpreter, capture, SMOP__ID__result);
    break;

  SMOP__ID__responder:
    SMOP__Object* node = SMOP__NATIVE__capture_invocant(interpreter,capture);
    SMOP__Object* old = NULL;
    SMOP__Object* set = SMOP__NATIVE__capture_positional(interpreter,capture,0);
    if (set) {
      smop_lowlevel_wrlock(node);
      old = ((smop_slime_node_struct*)node)->responder;
      ((smop_slime_node_struct*)node)->responder = set;
    } else {
      smop_lowlevel_rdlock(node);
    }
    ret = ((smop_slime_node_struct*)node)->responder;
    smop_lowlevel_unlock(node);
    if (old) SMOP_RELEASE(interpreter, old);
    break;

  SMOP__ID__identifier:
    SMOP__Object* node = SMOP__NATIVE__capture_invocant(interpreter,capture);
    SMOP__Object* old = NULL;
    SMOP__Object* set = SMOP__NATIVE__capture_positional(interpreter,capture,0);
    if (set) {
      smop_lowlevel_wrlock(node);
      old = ((smop_slime_node_struct*)node)->identifier;
      ((smop_slime_node_struct*)node)->identifier = set;
    } else {
      smop_lowlevel_rdlock(node);
    }
    ret = ((smop_slime_node_struct*)node)->identifier;
    smop_lowlevel_unlock(node);
    if (old) SMOP_RELEASE(interpreter, old);
    break;

  SMOP__ID__capture:
    SMOP__Object* node = SMOP__NATIVE__capture_invocant(interpreter,capture);
    SMOP__Object* old = NULL;
    SMOP__Object* set = SMOP__NATIVE__capture_positional(interpreter,capture,0);
    if (set) {
      smop_lowlevel_wrlock(node);
      old = ((smop_slime_node_struct*)node)->capture;
      ((smop_slime_node_struct*)node)->capture = set;
    } else {
      smop_lowlevel_rdlock(node);
    }
    ret = ((smop_slime_node_struct*)node)->capture;
    smop_lowlevel_unlock(node);
    if (old) SMOP_RELEASE(interpreter, old);
    break;

  SMOP__ID__debug:
    SMOP__Object* node = SMOP__NATIVE__capture_invocant(interpreter,capture);
    SMOP__Object* old = NULL;
    SMOP__Object* set = SMOP__NATIVE__capture_positional(interpreter,capture,0);
    if (set) {
      smop_lowlevel_wrlock(node);
      old = ((smop_slime_node_struct*)node)->debug;
      ((smop_slime_node_struct*)node)->debug = set;
    } else {
      smop_lowlevel_rdlock(node);
    }
    ret = ((smop_slime_node_struct*)node)->debug;
    smop_lowlevel_unlock(node);
    if (old) SMOP_RELEASE(interpreter, old);
    break;

  SMOP__ID__jail:
    SMOP__Object* node = SMOP__NATIVE__capture_invocant(interpreter,capture);
    SMOP__Object* old = NULL;
    SMOP__Object* set = SMOP__NATIVE__capture_positional(interpreter,capture,0);
    if (set) {
      smop_lowlevel_wrlock(node);
      old = ((smop_slime_node_struct*)node)->jail;
      ((smop_slime_node_struct*)node)->jail = set;
    } else {
      smop_lowlevel_rdlock(node);
    }
    ret = ((smop_slime_node_struct*)node)->jail;
    smop_lowlevel_unlock(node);
    if (old) SMOP_RELEASE(interpreter, old);
    break;

  SMOP__ID__result:
    SMOP__Object* node = SMOP__NATIVE__capture_invocant(interpreter,capture);
    SMOP__Object* old = NULL;
    SMOP__Object* set = SMOP__NATIVE__capture_positional(interpreter,capture,0);
    if (set) {
      smop_lowlevel_wrlock(node);
      old = ((smop_slime_node_struct*)node)->result;
      ((smop_slime_node_struct*)node)->result = set;
    } else {
      smop_lowlevel_rdlock(node);
    }
    ret = ((smop_slime_node_struct*)node)->result;
    smop_lowlevel_unlock(node);
    if (old) SMOP_RELEASE(interpreter, old);
    break;

  SMOP__ID__eval:
    SMOP__Object* node = SMOP__NATIVE__capture_invocant(interpreter,capture);

    smop_lowlevel_rdlock(node);
    SMOP__Object* responder = ((smop_slime_node_struct*)node)->responder;
    SMOP__Object* identifier = ((smop_slime_node_struct*)node)->identifier;
    SMOP__Object* capture = ((smop_slime_node_struct*)node)->capture;
    smop_lowlevel_unlock(node);

    if (responder)
      ret = SMOP_DISPATCH(interpreter,responder,identifier,capture);

    smop_lowlevel_wrlock(node);
    SMOP__Object* old = ((smop_slime_node_struct*)node)->result;
    ((smop_slime_node_struct*)node)->result = ret;
    smop_lowlevel_unlock(node);

    if (old) SMOP_RELEASE(interpreter, old);
    break;

  SMOP__ID__DESTROYALL:
    smop_slime_node_struct* node = (smop_slime_node_struct*)capture;

    smop_lowlevel_wrlock(node);
    SMOP__Object* r = node->responder; node->responder = NULL;
    SMOP__Object* i = node->identifier; node->identifier = NULL;
    SMOP__Object* c = node->capture; node->capture = NULL;
    SMOP__Object* d = node->debug; node->debug = NULL;
    SMOP__Object* j = node->jail; node->jail = NULL;
    SMOP__Object* x = node->result; node->result = NULL;
    smop_lowlevel_unlock(node);

    if (r) SMOP_RELEASE(interpreter,r);
    if (i) SMOP_RELEASE(interpreter,i);
    if (c) SMOP_RELEASE(interpreter,c);
    if (d) SMOP_RELEASE(interpreter,d);
    if (j) SMOP_RELEASE(interpreter,j);
    if (x) SMOP_RELEASE(inteprreter,x);

    break;
  }
  return ret;
}

static SMOP__Object* node_reference(SMOP__Object* interpreter, SMOP__ResponderInterface* responder, SMOP__Object* obj) {
  if (responder != obj) {
    smop_lowlevel_refcnt_inc(interpreter, responder, obj);
  }
  return obj;
}

static SMOP__Object* node_release(SMOP__Object* interpreter, SMOP__ResponderInterface* responder, SMOP__Object* obj) {
  if (responder != obj) {
    smop_lowlevel_refcnt_dec(interpreter, responder, obj);
  }
  return obj;
}

void smop_slime_node_init() {
  SMOP__SLIME__Node = calloc(1, sizeof(SMOP__ResponderInterface));
  assert(SMOP__SLIME__Node);
  SMOP__SLIME__Node->MESSAGE = node_message;
  SMOP__SLIME__Node->REFERENCE = node_reference;
  SMOP__SLIME__Node->RELEASE = node_release;
}

void smop_slime_node_destr() {
  free(SMOP__SLIME__Node);
}
