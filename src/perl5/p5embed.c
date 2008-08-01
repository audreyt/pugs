#include "p5embed.h"
#include <XSUB.h>
#include "perlxsi.c"
#include "pugsembed.c"

/* define to enable pugsembed debug messages */
#define PERL5_EMBED_DEBUG 0

#if PERL5_EMBED_DEBUG
#define oRZ ""
#define hate Perl_croak(aTHX_ "hate software")
#else
#define oRZ "#"
#define hate
#endif

/* Workaround for mapstart: the only op which needs a different ppaddr */
#undef Perl_pp_mapstart
#define Perl_pp_mapstart Perl_pp_grepstart
#undef OP_MAPSTART
#define OP_MAPSTART OP_GREPSTART

static PerlInterpreter *my_perl;

int _P5EMBED_INIT = 0;

const char pugs_guts_code[] =
"use strict;\n\n"

"package pugs;\n\n"

"our $AUTOLOAD;\n"
"sub AUTOLOAD { pugs::guts::invoke($AUTOLOAD, @_) } \n"
"sub DESTROY {}\n\n"

"package pugs::guts;\n"
"our @ISA=('pugs');\n"
"sub Code { my ($class, $val) = @_;\n"
"            sub { pugs::guts::invoke($val, undef, @_) } }\n"

"sub Array { my ($class, $val) = @_;\n"
"            my $array; tie @$array, 'pugs::array', $val;\n"
oRZ"   warn 'returning '.$array;\n"
"            return $array; }\n\n"

"sub Hash { my ($class, $val) = @_;\n"
"           my $hash; tie %$hash, 'pugs::hash', $val;\n"
oRZ"   warn 'returning '.$hash;\n"
"            return $hash; }\n\n"

"sub Pair { goto &Hash }\n"

"sub Scalar { my ($class, $val) = @_;\n"
"           my $scalar; tie $$scalar, 'pugs::scalar', $val;\n"
oRZ"   warn 'returning '.$scalar;\n"
"            return $scalar; }\n\n"

"sub Handle { my ($class, $val) = @_;\n"
"           tie *FH, 'pugs::handle', $val;\n"
oRZ"   warn 'returning '.$handle;\n"
"            return *FH; }\n\n"

"our $AUTOLOAD;\n"
"sub AUTOLOAD { my $type = $AUTOLOAD; $type =~ s/.*:://;\n"
"               return if $type =~ m/^[A-Z]*$/; die 'unhandled support type: '.$type } \n"
oRZ"warn 'compiled .'.__PACKAGE__;\n\n"

"package pugs::array;\n"

"our $AUTOLOAD;\n"

"sub AUTOLOAD { my $type = $AUTOLOAD; $type =~ s/.*:://;\n"
"               warn 'unhandled support type: '.$type } \n"

"sub TIEARRAY {\n"
"       my ($class, $val) = @_;\n"
"       bless \\$val, $class; }\n\n"

"sub DEREF { ${$_[0]} }\n"

"sub STORE {\n"
"       my ($self, $index, $elem) = @_;\n"
oRZ"    warn 'store! '.$elem;\n"
"       pugs::guts::eval_apply('sub ($x is rw, $y is rw, $z is rw) { item($x[$y] = $z);\n"
oRZ"                                                     warn $x\n"
"                               }', $$self, $index, $elem) }\n\n"

"sub PUSH {\n"
"       my ($self, @elems) = @_;\n"
"       pugs::guts::eval_apply('sub ($x is rw, @*y) { item $x.push(@y);\n"
oRZ"                                                 warn $x\n"
"                               }', $$self, @elems) }\n\n"

"sub FETCHSIZE {\n"
"       my ($self) = @_;\n"
"       my $ret = pugs::guts::invoke('elems', $$self); \n"
oRZ"    warn 'FETCHSIZE: '.$ret;\n"
"       $ret; }\n\n"

"sub EXISTS {\n"
"       my ($self, $index) = @_;\n"
"       pugs::guts::eval_apply('sub ($x, $y) { item $x.exists($y) }', $$self, $index) }\n"

"sub FETCH {\n"
"       my ($self, $index) = @_;\n"
oRZ"    warn 'FETCH: '.$index;\n"
"       pugs::guts::eval_apply('sub ($x, $y) { item $x.[$y] }', $$self, $index) }\n"

"package pugs::hash;\n"

"our $AUTOLOAD;\n"
"sub AUTOLOAD { my $type = $AUTOLOAD; $type =~ s/.*:://;\n"
"               warn 'unhandled support type: '.$type } \n"

"sub TIEHASH {\n"
"       my ($class, $val) = @_;\n"
"       bless [$val,0], $class; }\n\n"

"sub DEREF { $_[0][0] }\n"

"sub FETCH {\n"
"       my ($self, $index) = @_;\n"
oRZ"    warn 'FETCH: '.$index;\n"
"       pugs::guts::eval_apply('sub ($x, $y) { item $x.{$y} }', $self->[0], $index) }\n"

"sub DELETE {\n"
"       my ($self, $index) = @_;\n"
oRZ"    warn 'DELETE: '.$index;\n"
"       pugs::guts::eval_apply('sub ($x, $y) { item $x.delete($y) }', $self->[0], $index) }\n"

"sub CLEAR {\n"
"       my ($self) = @_;\n"
"       pugs::guts::eval_apply('sub ($x) { item $x.delete($x.keys) }', $self->[0]) }\n"

"sub STORE {\n"
"       my ($self, $index, $elem) = @_;\n"
oRZ"    warn 'store! '.$elem;\n"
"       pugs::guts::eval_apply('sub ($x is rw, $y, $z) { item($x{$y} = $z);\n"
oRZ"                                                     warn $x\n"
"                               }', $self->[0], $index, $elem) }\n\n"

"sub FIRSTKEY {\n"
"       my ($self) = @_;\n"
"       my $ret = pugs::guts::invoke('keys', $self->[0]); \n"
oRZ"       warn $ret;\n"
"       $self->[1] = 0; $self->[2] = $ret;"
"       $self->NEXTKEY; }\n"

"sub NEXTKEY {\n"
"       my ($self) = @_;\n"
"       return undef if $self->[1] > $#{$self->[2]};"
"       $self->[2]->[$self->[1]++]; }"

"package pugs::scalar;\n"

"our $AUTOLOAD;\n"
"sub AUTOLOAD { my $type = $AUTOLOAD; $type =~ s/.*:://;\n"
"               warn 'unhandled support type: '.$type } \n"

"sub TIESCALAR {\n"
"       my ($class, $val) = @_;\n"
"       bless \\$val, $class; }\n\n"

"sub DEREF { ${$_[0]} }\n"

"sub FETCH {\n"
"       my ($self) = @_;\n"
"       pugs::guts::eval_apply('sub ($x) { ~$x }', $$self) }\n"

"sub STORE {\n"
"       my ($self, $val) = @_;\n"
"       pugs::guts::eval_apply('sub ($x is rw, $y) { $$x = $y;\n"
oRZ"                                                     warn $x\n"
"                               }', $$self, $val) }\n\n"

"package pugs::handle;\n"

"our $AUTOLOAD;\n"
"sub AUTOLOAD { my $type = $AUTOLOAD; $type =~ s/.*:://;\n"
"               warn 'unhandled support type: '.$type } \n"

"sub TIEHANDLE {\n"
"       my ($class, $val) = @_;\n"
"       bless \\$val, $class; }\n\n"

"sub DEREF { ${$_[0]} }\n"

"sub PRINT {\n"
"       my ($self, @vals) = shift;\n"
"       pugs::guts::eval_apply('sub ($x, *@y) { $x.print(@y) }', $$self, @vals) }\n"

"sub READLINE {\n"
"       my ($self) = @_;\n"
"       pugs::guts::eval_apply('sub ($x) { ~($x.readline);\n"
oRZ"                                                     warn $x\n"
"                               }', $$self) }\n\n"

"sub GETC {\n"
"       my ($self) = @_;\n"
"       pugs::guts::eval_apply('sub ($x) { ~($x.getc);\n"
oRZ"                                                     warn $x\n"
"                               }', $$self) }\n\n"

oRZ"warn 'compiled';\n"
"1;\n";

XS(_pugs_guts_invoke) {
    Val *val, *inv, **stack;
    SV *ret, *sv;
    int i;
    dXSARGS;
    if (items < 1) {
      hate;
    }

    sv = ST(0);
    if (sv_isa(sv, "pugs")) {
        val = pugs_SvToVal(ST(0));
    }
    else {
        char *method, *fullname;
        fullname = SvPV_nolen(sv);
        method = strrchr(fullname, ':');
        method = method ? method+1 : fullname;
        val = pugs_PvnToVal(method, strlen(method));
    }
    inv = SvOK(ST(1)) ? pugs_SvToVal(ST(1)) : NULL;

    New(6, stack, items, Val*);

    for (i = 2; i < items; ++i) {
        stack[i-2] = pugs_SvToVal(ST(i));
    }
    stack[i-2] = NULL;
    
    ST(0) = pugs_Apply(val, inv, stack, GIMME_V);
    /* sv_dump (ret); */
    Safefree(stack);
    
    XSRETURN(1);
}


XS(_pugs_guts_eval_apply) {
    Val *val, *inv, **stack;
    int i;
    dXSARGS;
    if (items < 1) {
        hate;
    }

    val = pugs_Eval(SvPV_nolen(ST(0)));

    New(6, stack, items, Val*);

    for (i = 1; i < items; ++i) {
#if PERL5_EMBED_DEBUG
        fprintf(stderr, "put into stack: %s\n", SvPV_nolen(ST(i)));
#endif
        stack[i-1] = pugs_SvToVal(ST(i));
    }
    stack[i-1] = NULL;
    
    ST(0) = pugs_Apply(val, NULL, stack, GIMME_V);
    Safefree(stack);
    
    XSRETURN(1);
}


#ifdef HAS_PROCSELFEXE
/* This is a function so that we don't hold on to MAXPATHLEN
   bytes of stack longer than necessary
 */
STATIC void
S_procself_val(pTHX_ SV *sv, char *arg0)
{
    char buf[MAXPATHLEN];
    int len = readlink(PROCSELFEXE_PATH, buf, sizeof(buf) - 1);

    /* On Playstation2 Linux V1.0 (kernel 2.2.1) readlink(/proc/self/exe)
       includes a spurious NUL which will cause $^X to fail in system
       or backticks (this will prevent extensions from being built and
       many tests from working). readlink is not meant to add a NUL.
       Normal readlink works fine.
     */
    if (len > 0 && buf[len-1] == '\0') {
      len--;
    }

    /* FreeBSD's implementation is acknowledged to be imperfect, sometimes
       returning the text "unknown" from the readlink rather than the path
       to the executable (or returning an error from the readlink).  Any valid
       path has a '/' in it somewhere, so use that to validate the result.
       See http://www.freebsd.org/cgi/query-pr.cgi?pr=35703
    */
    if (len > 0 && memchr(buf, '/', len)) {
        sv_setpvn(sv,buf,len);
    }
    else {
        sv_setpv(sv,arg0);
    }
}
#endif /* HAS_PROCSELFEXE */

#    if defined(__APPLE__)
#      include <crt_externs.h>  /* for the env array */
#      define p5embed_environ (*_NSGetEnviron())
#    else
#      define p5embed_environ environ
#    endif

PerlInterpreter *
perl5_init ( int argc, char **argv )
{
    int exitstatus;
    int i;

#ifdef PERL_GPROF_MONCONTROL
    PERL_GPROF_MONCONTROL(0);
#endif
#ifdef PERL_SYS_INIT3
    PERL_SYS_INIT3(&argc,&argv,&p5embed_environ);
#endif

#if (defined(USE_5005THREADS) || defined(USE_ITHREADS)) && defined(HAS_PTHREAD_ATFORK)
    /* XXX Ideally, this should really be happening in perl_alloc() or
     * perl_construct() to keep libperl.a transparently fork()-safe.
     * It is currently done here only because Apache/mod_perl have
     * problems due to lack of a call to cancel pthread_atfork()
     * handlers when shared objects that contain the handlers may
     * be dlclose()d.  This forces applications that embed perl to
     * call PTHREAD_ATFORK() explicitly, but if and only if it hasn't
     * been called at least once before in the current process.
     * --GSAR 2001-07-20 */
    PTHREAD_ATFORK(Perl_atfork_lock,
                   Perl_atfork_unlock,
                   Perl_atfork_unlock);
#endif

    if (!PL_do_undump) {
        my_perl = perl_alloc();
        if (!my_perl)
            exit(1);
        perl_construct( my_perl );
        PL_perl_destruct_level = 0;
    }
#ifdef PERL_EXIT_DESTRUCT_END
    PL_exit_flags |= PERL_EXIT_DESTRUCT_END;
#endif /* PERL_EXIT_DESTRUCT_END */
#ifdef PERL_EXIT_EXPECTED
    PL_exit_flags |= PERL_EXIT_EXPECTED;
#endif /* PERL_EXIT_EXPECTED */

#if (defined(CSH) && defined(PL_cshname))
    if (!PL_cshlen)
      PL_cshlen = strlen(PL_cshname);
#endif

    exitstatus = perl_parse(my_perl, xs_init, argc, argv, (char **)NULL);

    if (exitstatus == 0)
        exitstatus = perl_run( my_perl );

    _P5EMBED_INIT = 1;

    newXS((char*) "pugs::guts::invoke", _pugs_guts_invoke, (char*)__FILE__);
    newXS((char*) "pugs::guts::eval_apply", _pugs_guts_eval_apply, (char*)__FILE__);

#if PERL5_EMBED_DEBUG
    fprintf(stderr, "(%s)", pugs_guts_code);
#endif
    eval_pv(pugs_guts_code, TRUE);

    if (SvTRUE(ERRSV)) {
        STRLEN n_a;
        printf("Error init perl: %s\n", SvPV(ERRSV,n_a));
        exit(1);
    }
    return my_perl;
}

char *
perl5_SvPV ( SV *sv )
{
    char *rv;
    rv = SvPV_nolen(sv);
    return rv;
}

int
perl5_SvIV ( SV *sv )
{
    return((int)SvIV(sv));
}

double
perl5_SvNV ( SV *sv )
{
    return((double)SvNV(sv));
}

bool
perl5_SvTRUE ( SV * sv )
{
    bool rv;
    rv = SvTRUE(sv);
    return(rv ? 1 : 0);
}

bool
perl5_SvROK ( SV * sv )
{
    bool rv;
    sv_dump(sv);
    rv = SvROK(sv);
    return(rv ? 1 : 0);
}

SV *
perl5_sv_undef ()
{
    return(&PL_sv_undef);
}

SV *
perl5_newSVpvn ( char * pv, int len )
{
    SV *sv = newSVpvn(pv, len);
#ifdef SvUTF8_on
    SvUTF8_on(sv);
#endif
    return(sv);
}

SV *
perl5_newSViv ( int iv )
{
    return(newSViv(iv));
}

SV *
perl5_newSVnv ( double iv )
{
    return(newSVnv(iv));
}

SV **
perl5_apply(SV *sub, SV *inv, SV** args, void *env, int cxt)
{
    SV **arg;
    SV **out;
    SV *rv;
    SV *sv;
    void *old_env = pugs_getenv();
    int count, i;

    dSP;

    ENTER;
    SAVETMPS;

    pugs_setenv(env);

    PUSHMARK(SP);
    if (inv != NULL) {
        XPUSHs(inv);
    }
    for (arg = args; *arg != NULL; arg++) {
        XPUSHs(*arg);
    }
    PUTBACK;

    if (inv != NULL) {
        count = call_method(SvPV_nolen(sub), cxt|G_EVAL);
    }
    else {
        count = call_sv(sub, cxt|G_EVAL);
    }

    SPAGAIN;

    if (SvTRUE(ERRSV)) {
        Newz(42, out, 3, SV*);
        if (SvROK(ERRSV)) {
            out[0] = newSVsv(ERRSV);
            out[1] = NULL;
        }
        else {
            out[0] = ERRSV;
            out[1] = ERRSV; /* for Haskell-side to read PV */
        }
        out[2] = NULL;
    }
    else {
        Newz(42, out, count+2, SV*);

        out[0] = NULL;

        for (i=count; i>0; --i) {
            out[i] = newSVsv(POPs);
        }
        out[count+1] = NULL;
    }

    PUTBACK;
    FREETMPS;
    LEAVE;

    pugs_setenv(old_env);
    return out;
}

SV *
perl5_get_sv(const char *name)
{
    SV *sv = get_sv(name, 1);
    /* sv_dump(sv); */
    return sv;
}

SV *
perl5_eval(char *code, void *env, int cxt)
{
    dSP;
    SV* sv;
    void *old_env = pugs_getenv();

    ENTER;
    SAVETMPS;

    pugs_setenv(env);

    sv = newSVpv(code, 0);
#ifdef SvUTF8_on
    SvUTF8_on(sv);
#endif
    eval_sv(sv, cxt);
    SvREFCNT_dec(sv);

    SPAGAIN;
    sv = POPs;
    SvREFCNT_inc(sv);
    PUTBACK;

    if (SvTRUE(ERRSV)) {
        STRLEN n_a;
        fprintf(stderr, "Error eval perl5: \"%s\"\n*** %s\n", code, SvPV(ERRSV,n_a));
    }

    FREETMPS;
    LEAVE;

    pugs_setenv(old_env);
    return sv;
}

bool
perl5_can(SV *inv, char *subname)
{
    int rv;

    dSP;

    ENTER;
    SAVETMPS;

    PUSHMARK(SP);
    XPUSHs(inv);
    XPUSHs(newSVpv(subname, 0));
    PUTBACK;

    call_pv("UNIVERSAL::can", G_SCALAR);

    SPAGAIN;

    rv = (POPi != 0);
    /* printf("Checking: %s->can(%s), ret %d\n", SvPV_nolen(inv), subname, rv); */

    PUTBACK;
    FREETMPS;
    LEAVE;

    return rv;
}

void perl5_finalize ( SV* sv )
{
    SvREFCNT_dec(sv);
}
