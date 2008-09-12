#include <stdlib.h>
#include <stdio.h>
#include <smop.h>
#include <string.h>
#include <smop_lowlevel.h>
#include <smop_s1p.h>
#include <smop_mold.h>

SMOP__Object* SMOP__S1P__RootNamespace;

void smop_s1p_root_namespace_insert(SMOP__Object* interpreter,char* name,SMOP__Object* obj) {

  SMOP__Object* cell = SMOP_DISPATCH(interpreter,
                                     SMOP_RI(SMOP__S1P__RootNamespace),
                                     SMOP__ID__postcircumfix_curly,
                                     SMOP__NATIVE__capture_create(interpreter,
                                                                  SMOP__S1P__RootNamespace,
                                                                  (SMOP__Object*[]) {SMOP__S1P__Str_create(name),NULL},
                                                                  NULL));

  SMOP_DISPATCH(interpreter,SMOP_RI(cell),SMOP__ID__STORE,
      SMOP__NATIVE__capture_create(interpreter,cell,(SMOP__Object*[]) {obj,NULL}, NULL));
}
void smop_s1p_root_namespace_init() {
  SMOP__S1P__RootNamespace = SMOP__S1P__Hash_create();
  smop_s1p_root_namespace_insert(SMOP__GlobalInterpreter,"::Hash",SMOP__S1P__Hash_create());
  smop_s1p_root_namespace_insert(SMOP__GlobalInterpreter,"::Array",SMOP__S1P__Array_create());
  smop_s1p_root_namespace_insert(SMOP__GlobalInterpreter,"$*OUT",SMOP__S1P__IO_create(SMOP__GlobalInterpreter));
  //smop_s1p_root_namespace_insert(SMOP__GlobalInterpreter,"::Code",SMOP__S1P__Code_create(SMOP__NATIVE__bool_false));
  SMOP__Object* mold = SMOP__Mold_create(0,(SMOP__Object*[]) { NULL },1,(int[]) { 0 });
  smop_s1p_root_namespace_insert(SMOP__GlobalInterpreter,"::Mold",SMOP_REFERENCE(SMOP__GlobalInterpreter,mold));
  smop_s1p_root_namespace_insert(SMOP__GlobalInterpreter,"::MoldFrame",SMOP__Mold__Frame_create(SMOP__GlobalInterpreter,mold));
  smop_s1p_root_namespace_insert(SMOP__GlobalInterpreter,"::Code",SMOP__S1P__Code_create());
}

void smop_s1p_root_namespace_destr() {
  SMOP_RELEASE(SMOP__GlobalInterpreter,SMOP__S1P__RootNamespace);
}


