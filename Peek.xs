#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#define LANGDUMPMAX 4

static int loopDump;

#define DBL_DIG	15   /* A guess that works lots of places */

void
Dump(sv,lim)
SV *sv;
I32 lim;
{
    char tmpbuf[1024];
    char *d = tmpbuf;
    I32 count;
    U32 flags;
    U32 type;

    if (!sv) {
	fprintf(stderr, "SV = 0\n");
	return;
    }
    
    flags = SvFLAGS(sv);
    type = SvTYPE(sv);

    sprintf(d, "(0x%lx)\n  REFCNT = %ld\n  FLAGS = (",
	(unsigned long)SvANY(sv), (long)SvREFCNT(sv));
    d += strlen(d);
    if (flags & SVs_PADBUSY)	strcat(d, "PADBUSY,");
    if (flags & SVs_PADTMP)	strcat(d, "PADTMP,");
    if (flags & SVs_PADMY)	strcat(d, "PADMY,");
    if (flags & SVs_TEMP)	strcat(d, "TEMP,");
    if (flags & SVs_OBJECT)	strcat(d, "OBJECT,");
    if (flags & SVs_GMG)	strcat(d, "GMG,");
    if (flags & SVs_SMG)	strcat(d, "SMG,");
    if (flags & SVs_RMG)	strcat(d, "RMG,");
    d += strlen(d);

    if (flags & SVf_IOK)	strcat(d, "IOK,");
    if (flags & SVf_NOK)	strcat(d, "NOK,");
    if (flags & SVf_POK)	strcat(d, "POK,");
    if (flags & SVf_ROK)	strcat(d, "ROK,");
    if (flags & SVf_OOK)	strcat(d, "OOK,");
    if (flags & SVf_FAKE)	strcat(d, "FAKE,");
    if (flags & SVf_READONLY)	strcat(d, "READONLY,");
    d += strlen(d);

    if (flags & SVp_IOK)	strcat(d, "pIOK,");
    if (flags & SVp_NOK)	strcat(d, "pNOK,");
    if (flags & SVp_POK)	strcat(d, "pPOK,");
    if (flags & SVp_SCREAM)	strcat(d, "SCREAM,");

    switch (type) {
    case SVt_PVCV:
      if (flags & SVpcv_ANON)	strcat(d, "ANON,");
      if (flags & SVpcv_CLONE)	strcat(d, "CLONE,");
      if (flags & SVpcv_CLONED)	strcat(d, "CLONED,");
      break;
    case SVt_PVGV:
      if (flags & SVpgv_MULTI)	strcat(d, "MULTI,");
    }

    d += strlen(d);
    if (d[-1] == ',')
	d--;
    *d++ = ')';
    *d = '\0';

    fprintf(stderr, "SV = ");
    switch (type) {
    case SVt_NULL:
	fprintf(stderr,"NULL%s\n", tmpbuf);
	return;
    case SVt_IV:
	fprintf(stderr,"IV%s\n", tmpbuf);
	break;
    case SVt_NV:
	fprintf(stderr,"NV%s\n", tmpbuf);
	break;
    case SVt_RV:
	fprintf(stderr,"RV%s\n", tmpbuf);
	break;
    case SVt_PV:
	fprintf(stderr,"PV%s\n", tmpbuf);
	break;
    case SVt_PVIV:
	fprintf(stderr,"PVIV%s\n", tmpbuf);
	break;
    case SVt_PVNV:
	fprintf(stderr,"PVNV%s\n", tmpbuf);
	break;
    case SVt_PVBM:
	fprintf(stderr,"PVBM%s\n", tmpbuf);
	break;
    case SVt_PVMG:
	fprintf(stderr,"PVMG%s\n", tmpbuf);
	break;
    case SVt_PVLV:
	fprintf(stderr,"PVLV%s\n", tmpbuf);
	break;
    case SVt_PVAV:
	fprintf(stderr,"PVAV%s\n", tmpbuf);
	break;
    case SVt_PVHV:
	fprintf(stderr,"PVHV%s\n", tmpbuf);
	break;
    case SVt_PVCV:
	fprintf(stderr,"PVCV%s\n", tmpbuf);
	break;
    case SVt_PVGV:
	fprintf(stderr,"PVGV%s\n", tmpbuf);
	break;
    case SVt_PVFM:
	fprintf(stderr,"PVFM%s\n", tmpbuf);
	break;
    case SVt_PVIO:
	fprintf(stderr,"PVIO%s\n", tmpbuf);
	break;
    default:
	fprintf(stderr,"UNKNOWN%s\n", tmpbuf);
	return;
    }
    if (type >= SVt_PVIV || type == SVt_IV)
	fprintf(stderr, "  IV = %ld\n", (long)SvIVX(sv));
    if (type >= SVt_PVNV || type == SVt_NV)
	fprintf(stderr, "  NV = %.*g\n", DBL_DIG, SvNVX(sv));
    if (SvROK(sv)) {
	fprintf(stderr, "  RV = 0x%lx\n", (long)SvRV(sv));
	if (loopDump < lim) {
	  loopDump++;
	  Dump(SvRV(sv),lim);
	  loopDump--;
	}
	return;
    }
    if (type < SVt_PV)
	return;
    if (type <= SVt_PVLV) {
	if (SvPVX(sv))
	    fprintf(stderr, "  PV = 0x%lx \"%s\"\n  CUR = %ld\n  LEN = %ld\n",
		(long)SvPVX(sv), SvPVX(sv), (long)SvCUR(sv), (long)SvLEN(sv));
	else
	    fprintf(stderr, "  PV = 0\n");
    }
    if (type >= SVt_PVMG) {
	if (SvMAGIC(sv)) {
	    fprintf(stderr, "  MAGIC = 0x%lx\n", (long)SvMAGIC(sv));
	}
	if (SvSTASH(sv))
	    fprintf(stderr, "  STASH = %s\n", HvNAME(SvSTASH(sv)));
    }
    switch (type) {
    case SVt_PVLV:
	fprintf(stderr, "  TYPE = %c\n", LvTYPE(sv));
	fprintf(stderr, "  TARGOFF = %ld\n", (long)LvTARGOFF(sv));
	fprintf(stderr, "  TARGLEN = %ld\n", (long)LvTARGLEN(sv));
	fprintf(stderr, "  TARG = 0x%lx\n", (long)LvTARG(sv));
	Dump(LvTARG(sv),lim);
	break;
    case SVt_PVAV:
	fprintf(stderr, "  ARRAY = 0x%lx\n", (long)AvARRAY(sv));
	fprintf(stderr, "  ALLOC = 0x%lx\n", (long)AvALLOC(sv));
	fprintf(stderr, "  FILL = %ld\n", (long)AvFILL(sv));
	fprintf(stderr, "  MAX = %ld\n", (long)AvMAX(sv));
	fprintf(stderr, "  ARYLEN = 0x%lx\n", (long)AvARYLEN(sv));
	if (AvREAL(sv))
	    fprintf(stderr, "  FLAGS = (REAL)\n");
	else
	    fprintf(stderr, "  FLAGS = ()\n");
	if (loopDump < lim && av_len((AV*)sv) >= 0) {
	  loopDump++;
	  for (count = 0; count <=  av_len((AV*)sv) && count < lim; 
	       count++) {
	    SV** elt = av_fetch((AV*)sv,count,0);

	    fprintf(stderr, "Elt No. %ld\n", (long)count);
	    if (elt) Dump(*elt,lim);
	  }
	  loopDump--;
	}
	break;
    case SVt_PVHV:
	fprintf(stderr, "  ARRAY = 0x%lx\n",(long)HvARRAY(sv));
	fprintf(stderr, "  KEYS = %ld\n", (long)HvKEYS(sv));
	fprintf(stderr, "  FILL = %ld\n", (long)HvFILL(sv));
	fprintf(stderr, "  MAX = %ld\n", (long)HvMAX(sv));
	fprintf(stderr, "  RITER = %ld\n", (long)HvRITER(sv));
	fprintf(stderr, "  EITER = 0x%lx\n",(long) HvEITER(sv));
	if (HvPMROOT(sv))
	    fprintf(stderr, "  PMROOT = 0x%lx\n",(long)HvPMROOT(sv));
	if (HvNAME(sv))
	    fprintf(stderr, "  NAME = \"%s\"\n", HvNAME(sv));
	if (loopDump < lim && !HvEITER(sv)) { /* Try to preserve iterator */
	  HE *he;
	  HV *hv = (HV*)sv;
	  int count = lim - loopDump;
	  I32 len;
	  SV *elt;
	  char *key;

	  loopDump--;
	  hv_iterinit(hv);
	  while ((elt = hv_iternextsv(hv,&key,&len)) && count--) {
	    fprintf(stderr, "Elt \"%s\" => 0x%lx\n", key, elt);
	    Dump(elt,lim);
	  }
	  hv_iterinit(hv);		/* Return to status quo */
	  loopDump--;
	}
	break;
    case SVt_PVFM:
    case SVt_PVCV:
	fprintf(stderr, "  STASH = %s\n", HvNAME(CvSTASH(sv)));
	fprintf(stderr, "  START = 0x%lx\n", (long)CvSTART(sv));
	fprintf(stderr, "  ROOT = 0x%lx\n", (long)CvROOT(sv));
	fprintf(stderr, "  XSUB = 0x%lx\n", (long)CvXSUB(sv));
	fprintf(stderr, "  XSUBANY = %ld\n", (long)CvXSUBANY(sv).any_i32);
	fprintf(stderr, "  GV = 0x%lx", (long)CvGV(sv));
	if (CvGV(sv) && GvNAME(CvGV(sv))) {
	  fprintf(stderr, "  \"%s\"\n", GvNAME(CvGV(sv)));
	} else {
	  fprintf(stderr, "\n");
	}
	fprintf(stderr, "  FILEGV = 0x%lx\n", (long)CvFILEGV(sv));
	fprintf(stderr, "  DEPTH = %ld\n", (long)CvDEPTH(sv));
	fprintf(stderr, "  PADLIST = 0x%lx\n", (long)CvPADLIST(sv));
	if (type == SVt_PVFM)
	    fprintf(stderr, "  LINES = %ld\n", (long)FmLINES(sv));
	break;
    case SVt_PVGV:
	fprintf(stderr, "  NAME = %s\n", GvNAME(sv));
	fprintf(stderr, "  NAMELEN = %ld\n", (long)GvNAMELEN(sv));
	fprintf(stderr, "  STASH = %s\n", HvNAME(GvSTASH(sv)));
	fprintf(stderr, "  GP = 0x%lx\n", (long)GvGP(sv));
	fprintf(stderr, "    SV = 0x%lx\n", (long)GvSV(sv));
	fprintf(stderr, "    REFCNT = %ld\n", (long)GvREFCNT(sv));
	fprintf(stderr, "    IO = 0x%lx\n", (long)GvIOp(sv));
	fprintf(stderr, "    FORM = 0x%lx\n", (long)GvFORM(sv));
	fprintf(stderr, "    AV = 0x%lx\n", (long)GvAV(sv));
	fprintf(stderr, "    HV = 0x%lx\n", (long)GvHV(sv));
	fprintf(stderr, "    CV = 0x%lx\n", (long)GvCV(sv));
	fprintf(stderr, "    CVGEN = 0x%lx\n", (long)GvCVGEN(sv));
	fprintf(stderr, "    LASTEXPR = %ld\n", (long)GvLASTEXPR(sv));
	fprintf(stderr, "    LINE = %ld\n", (long)GvLINE(sv));
	fprintf(stderr, "    FLAGS = 0x%x\n", (int)GvFLAGS(sv));
	fprintf(stderr, "    STASH = %s\n", HvNAME(GvSTASH(sv)));
	fprintf(stderr, "    EGV = 0x%lx\n", (long)GvEGV(sv));
	break;
    case SVt_PVIO:
	fprintf(stderr, "  IFP = 0x%lx\n", (long)IoIFP(sv));
	fprintf(stderr, "  OFP = 0x%lx\n", (long)IoOFP(sv));
	fprintf(stderr, "  DIRP = 0x%lx\n", (long)IoDIRP(sv));
	fprintf(stderr, "  LINES = %ld\n", (long)IoLINES(sv));
	fprintf(stderr, "  PAGE = %ld\n", (long)IoPAGE(sv));
	fprintf(stderr, "  PAGE_LEN = %ld\n", (long)IoPAGE_LEN(sv));
	fprintf(stderr, "  LINES_LEFT = %ld\n", (long)IoLINES_LEFT(sv));
	fprintf(stderr, "  TOP_NAME = %s\n", IoTOP_NAME(sv));
	fprintf(stderr, "  TOP_GV = 0x%lx\n", (long)IoTOP_GV(sv));
	fprintf(stderr, "  FMT_NAME = %s\n", IoFMT_NAME(sv));
	fprintf(stderr, "  FMT_GV = 0x%lx\n", (long)IoFMT_GV(sv));
	fprintf(stderr, "  BOTTOM_NAME = %s\n", IoBOTTOM_NAME(sv));
	fprintf(stderr, "  BOTTOM_GV = 0x%lx\n", (long)IoBOTTOM_GV(sv));
	fprintf(stderr, "  SUBPROCESS = %ld\n", (long)IoSUBPROCESS(sv));
	fprintf(stderr, "  TYPE = %c\n", IoTYPE(sv));
	fprintf(stderr, "  FLAGS = 0x%lx\n", (long)IoFLAGS(sv));
	break;
    }
}

MODULE = ExtUtils::Peek		PACKAGE = ExtUtils::Peek

void
Dump(sv,lim=4)
SV *	sv
I32	lim

I32
SvREFCNT(sv)
SV *	sv

 
# PPCODE needed since otherwise sv_2mortal is inserted that will kill
# the value.


SV *
SvREFCNT_inc(sv)
SV *	sv
 PPCODE:
    {
	RETVAL = SvREFCNT_inc(sv);
	PUSHs(RETVAL);
    }

# PPCODE needed since by default it is void

SV *
SvREFCNT_dec(sv)
SV *	sv
 PPCODE:
    {
	SvREFCNT_dec(sv);
	PUSHs(sv);
    }

