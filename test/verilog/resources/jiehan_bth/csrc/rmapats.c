#include <stdio.h>
#include <stdlib.h>
#include "rmapats.h"

typedef unsigned char UB;
typedef unsigned char scalar;
typedef unsigned short US;
#ifndef __DO_RMAHDR_
typedef unsigned int U;
#endif
#if defined(__sparcv9) || defined(__LP64__) || defined(_LP64) || defined(__ia64)
typedef unsigned long UP;
typedef unsigned long RP;
#else
typedef unsigned int UP;
typedef unsigned int RP;
#endif
typedef void (*FP)(void *, scalar);
typedef void (*FPV)(void *, UB*);
typedef void (*FP1)(void *);
typedef void (*FPLSEL)(void *, scalar, U);
typedef void (*FPLSELV)(void *, vec32*, U, U);

#ifdef __cplusplus
  extern "C" {
#endif

typedef struct { 
        void* daiCbkList;
        void* aliasIp;
        U     aliasQsymId;
 } RmaDaiCg;

typedef struct { 
        void* vecCbkList;
 } RmaRootCbkCg;

typedef struct { 
        U vrpId;
 } RmaRootVcdCg;

typedef struct {
	union {
		RP daiCbkList;
		RP vcdId;
		U  numNodes;
	} u;
} RmaDaiOptCg;
extern scalar Xunion[], Xwor[], Xwand[];
extern scalar X3val[], X4val[], XcvtstrTR[], Xbuf[], Xbitnot[],Xwor[], Xwand[];
extern scalar globalTable1Input[];
extern unsigned long long vcs_clocks;
extern UB gHsimDumpScalVal;
extern UB gHsimPliScalVal;
extern U fCallbackHsimNode;
extern U fVcdDumpHsimNode;
extern U fVpdDumpHsimNode;
extern UB* rmaEvalDelays(UB* pcode, scalar val);
extern void rmaPopTransEvent(UB* pcode);
extern void (*txpFnPtr)(UB* pcode, U);
extern void rmaSetupFuncArray(UP* ra);
extern void SinitHsimPats(void);
extern void VVrpDaicb(void* ip, U nIndex);
extern int SDaicb(void *ip, U nIndex);
extern void SDaicbForHsimNoFlagScalar(void* pDaiCb, unsigned char value);
extern void SDaicbForHsimNoFlagStrengthScalar(void* pDaiCb, unsigned char value);
extern void SDaicbForHsimNoFlag(void* pRmaDaiCg, unsigned char value);
extern void SDaicbForHsimNoFlag2(void* pRmaDaiCg, unsigned char value);
extern void SDaicbForHsimWithFlag(void* pRmaDaiCg, unsigned char value);
extern void SDaicbForHsimNoFlagFrcRel(void* pRmaDaiCg, unsigned char reason, int msb, int lsb, int ndx);
extern void SDaicbForHsimNoFlagFrcRel2(void* pRmaDaiCg, unsigned char reason, int msb, int lsb, int ndx);
extern void VcsHsimValueChangeCB(void* pRmaDaiCg, void* pValue, unsigned int valueFormat);
extern U isNonDesignNodeCallbackList(void* pRmaDaiCg);
extern void SDaicbForHsimCbkMemOptNoFlagScalar(void* pDaiCb, unsigned char value, unsigned char isStrength);
extern void SDaicbForHsimCbkMemOptWithFlagScalar(void* pDaiCb, unsigned char value, unsigned char isStrength);
extern void SDaicbForHsimCbkMemOptNoFlagScalar(void* pDaiCb, unsigned char value, unsigned char isStrength);
extern void SDaicbForHsimCbkMemOptWithFlagScalar(void* pDaiCb, unsigned char value, unsigned char isStrength);
extern void VVrpNonEventNonRegdScalarForHsimOptCbkMemopt(void* ip, U nIndex);
extern void SDaicbForHsimCbkMemOptNoFlagDynElabScalar(U* mem, unsigned char value, unsigned char isStrength);
extern void SDaicbForHsimCbkMemOptWithFlagDynElabScalar(U* mem, unsigned char value, unsigned char isStrength);
extern U RMADAIOPTCG_IS_MEM_SET_LOCAL(void* p);
extern U* GET_RMADAIOPTCG_MEM_LOCAL(void* p);
extern U RMADAIOPTCG_IS_VCD_SET_LOCAL(void* p);
extern U GET_RMADAIOPTCG_VCDID_LOCAL(void* p);
extern U RMADAIOPTCG_IS_CBK_SET_LOCAL(void* p);
extern U* GET_RMADAIOPTCG_CBKLIST_LOCAL(void* p) ;
extern void copyAndPropRootCbkCg(RmaRootCbkCg* pRootCbk, scalar val);
extern void dumpRootVcdCg(RmaRootVcdCg* pRootVcd, scalar val);
extern void SchedSemiLerMP1(UB* pmps, U partId);
extern void hsUpdateModpathTimeStamp(UB* pmps);
extern void doMpd32One(UB* pmps);
extern void SchedSemiLerMP(UB* ppulse, U partId);
extern void scheduleuna(UB *e, U t);
extern void scheduleuna_mp(EBLK *e, unsigned t);
extern void schedule(UB *e, U t);
extern void sched_hsopt(struct dummyq_struct * pQ, EBLK *e, U t);
extern void sched_millenium(struct dummyq_struct * pQ, EBLK *e, U thigh, U t);
extern void schedule_1(EBLK *e);
extern void sched0(UB *e);
extern void sched0lq(UB *e);
extern void sched0una(UB *e);
extern void sched0una_th(struct dummyq_struct *pq, UB *e);
extern void scheduleuna_mp_th(struct dummyq_struct *pq, EBLK *e, unsigned t);
extern void schedal(UB *e);
extern void sched0_th(struct dummyq_struct * pQ, UB *e);
extern void schedal_th(struct dummyq_struct * pQ, UB *e);
extern void scheduleuna_th(struct dummyq_struct * pQ, UB *e, U t);
extern void schedule_th(struct dummyq_struct * pQ, UB *e, U t);
extern void schedule_1_th(struct dummyq_struct * pQ, EBLK *e);
extern U getVcdFlags(UB *ip);
extern void VVrpNonEventNonRegdScalarForHsimOpt(void* ip, U nIndex);
extern void VVrpNonEventNonRegdScalarForHsimOpt2(void* ip, U nIndex);
extern void SchedSemiLerTBReactiveRegion(struct eblk* peblk);
extern void SchedSemiLerTBReactiveRegion_th(struct eblk* peblk, U partId);
extern void SchedSemiLerTr(UB* peblk, U partId);
extern void appendNtcEvent(UB* phdr, scalar s, U schedDelta);
extern void hsimRegisterEdge(void* sm,  scalar s);
extern U pvcsGetPartId();
extern void HsimPVCSPartIdCheck(U instNo);
extern void debug_func(U partId, struct dummyq_struct* pQ, EBLK* EblkLastEventx); 
extern struct dummyq_struct* pvcsGetQ(U thid);
extern EBLK* pvcsGetLastEventEblk(U thid);
extern void insertTransEvent(RmaTransEventHdr* phdr, scalar s, scalar pv,	scalar resval, U schedDelta, int re, UB* predd, U fpdd);
extern void insertNtcEventRF(RmaTransEventHdr* phdr, scalar s, scalar pv, scalar resval, U schedDelta, U* delays);
extern int getCurSchedRegion();
#ifdef __cplusplus
  }
#endif
scalar dummyScalar;
scalar fScalarIsForced=0;
scalar fScalarIsReleased=0;
scalar fScalarHasChanged=0;
extern int curSchedRegion;
extern int fNotimingchecks;
typedef struct red_t {
	U reject;
	U error;
	U delay;
} RED;
typedef struct predd {
	U type;
	RED delays[1];
} PREDD;
#define HASH_BIT 0xfff
#define TransStE 255

#ifdef __cplusplus
extern "C" {
#endif
void  schedNewEvent(struct dummyq_struct * pQ, EBLK  * peblk, U  delay);
#ifdef __cplusplus
}
#endif
void  schedNewEvent(struct dummyq_struct * pQ, EBLK  * peblk, U  delay)
{
    U  abs_t;
    U  thigh_abs;
    U  hash_index;
    struct futq * pfutq;
    abs_t = ((U )vcs_clocks) + delay;
    hash_index = abs_t & 0xfff;
    peblk->peblkFlink = (EBLK  *)(-1);
    peblk->t = abs_t;
    if (abs_t < (U )vcs_clocks) {
        thigh_abs = ((U  *)&vcs_clocks)[1];
        sched_millenium(pQ, peblk, thigh_abs + 1, abs_t);
    }
    else if ((pfutq = pQ->hashtab[hash_index].tfutq)) {
        peblk->peblkPrv = pfutq->peblkTail;
        pfutq->peblkTail->peblkFlink = peblk;
        pfutq->peblkTail = peblk;
    }
    else {
        sched_hsopt(pQ, peblk, abs_t);
    }
}
#ifdef __cplusplus
extern "C" {
#endif
void  rmaPropagate2(UB  * pcode, vec32  * pval);
#ifdef __cplusplus
}
#endif
#ifdef __cplusplus
extern "C" {
#endif
void  rmaPropagate3(UB  * pcode, scalar  val);
#ifdef __cplusplus
}
#endif
#ifdef __cplusplus
extern "C" {
#endif
void  rmaPropagate4(UB  * pcode, scalar  val);
#ifdef __cplusplus
}
#endif
#ifdef __cplusplus
extern "C" {
#endif
void  rmaPropagate5(UB  * pcode, vec32  * pval);
#ifdef __cplusplus
}
#endif
#ifdef __cplusplus
extern "C" {
#endif
void  rmaPropagate6(UB  * pcode, vec32  * pval);
#ifdef __cplusplus
}
#endif
#ifdef __cplusplus
extern "C" {
#endif
void  rmaPropagate6p(UB  * pcode, vec32  * pval);
#ifdef __cplusplus
}
#endif
#ifdef __cplusplus
extern "C" {
#endif
void  rmaPropagate6lbs(UB  * pcode, scalar  val, U  index);
#ifdef __cplusplus
}
#endif
#ifdef __cplusplus
extern "C" {
#endif
void  rmaPropagate6lps(UB  * pcode, vec32  * val, U  index, U  width);
#ifdef __cplusplus
}
#endif
#ifdef __cplusplus
extern "C" {
#endif
void  rmaPropagate6s0f(UB  * pcode, vec32  * pval);
#ifdef __cplusplus
}
#endif
#ifdef __cplusplus
extern "C" {
#endif
void  rmaPropagate7(UB  * pcode, vec32  * pval);
#ifdef __cplusplus
}
#endif
#ifdef __cplusplus
extern "C" {
#endif
void  rmaPropagate8(UB  * pcode, vec32  * pval);
#ifdef __cplusplus
}
#endif
#ifdef __cplusplus
extern "C" {
#endif
void  rmaPropagate9(UB  * pcode, vec32  * pval);
#ifdef __cplusplus
}
#endif
#ifdef __cplusplus
extern "C" {
#endif
void  rmaPropagate10(UB  * pcode, scalar  val);
#ifdef __cplusplus
}
#endif
#ifdef __cplusplus
extern "C" {
#endif
void  rmaPropagate11(UB  * pcode, scalar  val);
#ifdef __cplusplus
}
#endif
#ifdef __cplusplus
extern "C" {
#endif
void  rmaPropagate12(UB  * pcode, vec32  * pval);
#ifdef __cplusplus
}
#endif
#ifdef __cplusplus
extern "C" {
#endif
void  rmaPropagate13(UB  * pcode, vec32  * pval);
#ifdef __cplusplus
}
#endif
#ifdef __cplusplus
extern "C" {
#endif
void  rmaPropagate14(UB  * pcode, scalar  val);
#ifdef __cplusplus
}
#endif
#ifdef __cplusplus
extern "C" {
#endif
void  rmaPropagate14t0(UB  * pcode, UB  val);
#ifdef __cplusplus
}
#endif
#ifdef __cplusplus
extern "C" {
#endif
void  rmaPropagate15(UB  * pcode, scalar  val);
#ifdef __cplusplus
}
#endif
#ifdef __cplusplus
extern "C" {
#endif
void  rmaPropagate15t0(UB  * pcode, UB  val);
#ifdef __cplusplus
}
#endif
FP rmaFunctionArray[] = {
	(FP) rmaPropagate2,
	(FP) rmaPropagate3,
	(FP) rmaPropagate4,
	(FP) rmaPropagate6,
	(FP) rmaPropagate6lbs,
	(FP) rmaPropagate6lps,
	(FP) rmaPropagate6s0f,
	(FP) rmaPropagate7,
	(FP) rmaPropagate8,
	(FP) rmaPropagate9,
	(FP) rmaPropagate10,
	(FP) rmaPropagate11,
	(FP) rmaPropagate12,
	(FP) rmaPropagate13,
	(FP) rmaPropagate14,
	(FP) rmaPropagate14t0,
	(FP) rmaPropagate15,
	(FP) rmaPropagate15t0
};

#ifdef __cplusplus
extern "C" {
#endif
void SinitHsimPats(void);
#ifdef __cplusplus
}
#endif
