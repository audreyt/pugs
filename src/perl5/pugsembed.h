#include "p5embed.h"
#include <HsFFI.h>

#ifndef SvPVutf8_nolen
#define SvPVutf8_nolen SvPV_nolen
#endif

#ifndef PugsValDefined
#define PugsValDefined 1
typedef HsStablePtr Val;
#endif

extern Val *pugs_Eval ( char *code );
extern SV *pugs_Apply ( Val *sub, Val *inv, Val **args, int cxt );

extern Val *pugs_UndefVal ();
extern Val *pugs_IvToVal ( IV iv );
extern Val *pugs_NvToVal ( NV iv );
extern Val *pugs_PvnToVal ( char *pv, int len );
extern Val *pugs_PvnToValUTF8 ( char *pv, int len );

extern Val *pugs_MkSvRef  ( SV *sv );
extern SV  *pugs_ValToSv ( Val *val );
extern IV   pugs_ValToIv ( Val *val );
extern NV   pugs_ValToNv ( Val *val );
extern char *pugs_ValToPv ( Val *val );

Val *pugs_SvToVal ( SV *sv );
SV  *pugs_MkValRef ( Val *val, char *typeStr );

Val *pugs_getenv ();
void pugs_setenv ( Val *env );

