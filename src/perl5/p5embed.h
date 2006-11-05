#define dirent DIRENT
#define _INTPTR_T_DEFINED
#define _UINTPTR_T_DEFINED
#undef RETURN

#if defined(__OpenBSD__)
#define _P5EMBED_INIT _p5embed_init
#else
#define _P5EMBED_INIT __init
#endif

#include "EXTERN.h"
#include "perl.h"
#include "embed.h"

PerlInterpreter * perl5_init ( int argc, char **argv );
char * perl5_SvPV ( SV * sv );
int perl5_SvIV ( SV * sv );
double perl5_SvNV ( SV * sv );
bool perl5_SvTRUE ( SV * sv );
bool perl5_SvROK(SV *inv);
SV * perl5_newSVpvn ( char * pv, int len );
SV * perl5_newSViv ( int iv );
SV * perl5_newSVnv ( double iv );
SV ** perl5_apply(SV *sub, SV *inv, SV** args, void *env, int cxt);
bool perl5_can(SV *inv, char *subname);
SV * perl5_eval(char *code, void *env, int cxt);
SV * perl5_get_sv ( const char *name );
void perl5_finalize ( SV* sv );
SV * perl5_sv_undef ();
