/* This program generates Xilinx 7-series MMCME2 and PLLE2 from input
 * parameters. */
/* This program was written August 2022 to be placed in the Public Domain. */

/* Copied/modifed from my ecp5-pll.c.  I didn't even bother trying to
 * implement this in Verilog, given the abject failure of the ecp5 variant.
 * See ecp5-pll.c for more details.  Note that unlike the ECP5 program,
 * I am unaware of any free alternatives. */

/* Major TODO:
 *   using OUTFB as an output
 *   OUT6->OUT4 ganging
 *   maybe tapping OUTFB */

/* TODO:  Check all math so rounding occurs correctly
 *        Support _BASE output
 *        Support phase adjustment
 *          static: Just use defparam <modname>.pll <val>
 *          dynamic: PHASE{SEL{0,1},DIR,STEP,LOADREG}
 *        Maybe support some sort of external CLKFB arrangement
 *        Option to insert BUFG (or BUFR?)
 *        Option to spit out the results in machine-readable form instead of .v */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/* MMCM B gets a suffix */
/* 6 is MMCM only */
static const char * const ocname[8] = {
    "CLKOUT0", "CLKOUT1", "CLKOUT2", "CLKOUT3", "CLKOUT4", "CLKOUT5",
    "CLKOUT6", "CLKFBOUT" };

/* Timing limits */
/* From ds187 (Zynq 7010/7020 data sheet).  Probably different for other
 * parts.  I don't feel like reading every single relevant document */
/* FIXME: At least look up xc7 parts supported by f4pga (non-zync xc7t) */
static const struct tlimit {
    double FCLKINMIN, FCLKINMAX, FCLKOUTMIN, FCLKOUTMAX, FVCOMIN, FVCOMAX,
	   PFDMIN, PFDMAX;
} speed_limit[] = {
    /* MMCME2 Speed grade 1* */
    { 10, 800, 4.69, 800, 600, 1200, 10, 440 },
    /* MMCME2 Speed grade 2 */
    { 10, 800, 4.69, 800, 600, 1440, 10, 500 },
    /* MMCME2 Speed grade 3 */
    { 10, 800, 4.69, 800, 600, 1600, 10, 550 },
    /* PLLE2 Speed grade 1* */
    { 19, 800, 6.25, 800, 800, 1600, 19, 440 },
    /* PLLE2 Speed grade 2 */
    { 19, 800, 6.25, 800, 800, 1866, 19, 500 },
    /* PLLE2 Speed grade 3 */
    { 19, 800, 6.25, 800, 800, 2133, 19, 550 }
};

int main(int argc, const char **argv)
{
    double FCLKIN1 = 25.0, FCLKOUT[7] = {FCLKIN1};
    struct tlimit limit = {};
    int  spd = 0, use_mmcm = 0, dyn_freq = 0, clk6_clk4 = 0;

    const char *modname = NULL, *iname = NULL, *iname2 = NULL, *iselname = NULL,
	       *oname[8] = {}, *invsuff = NULL,
	       *resetname = NULL, *lockname = NULL;

    /* FIXME:  sort/bsearch.  Then again, who but me cares? */
    /* God damn, I hate gcc sometimes */
    #pragma GCC diagnostic ignored "-Wmissing-field-initializers"
    const struct {
	const char *name;
	double *val;
	const char **sval;
	const char *def;
    } args[] = {
	{ "FCLKIN1", &FCLKIN1 }, { "FCLKOUT0", &FCLKOUT[0] },
	{ "FCLKOUT1", &FCLKOUT[1] }, { "FCLKOUT2", &FCLKOUT[2] },
	{ "FCLKOUT3", &FCLKOUT[3] }, { "FCLKOUT4", &FCLKOUT[4] },
	{ "FCLKOUT5", &FCLKOUT[5] }, { "FCLKOUT6", &FCLKOUT[6] },
	{ "FCLKINMIN", &limit.FCLKINMIN }, { "FCLKINMAX", &limit.FCLKINMAX },
	{ "FCLKOUTMIN", &limit.FCLKOUTMIN }, { "FCLKOUTMAX", &limit.FCLKOUTMAX },
	{ "FVCOMIN", &limit.FVCOMIN }, { "FVCOMAX", &limit.FVCOMAX },
	{ "PFDMIN", &limit.PFDMIN }, { "PFDMAX", &limit.PFDMAX },
	{ "modname", NULL, &modname, "pll" },
	{ "clkin1name", NULL, &iname, "CLKIN1" },
	{ "clkin2name", NULL, &iname2, "" },
	{ "clkinselname", NULL, &iselname, "CLKINSEL" },
	{ "clkout0name", NULL, &oname[0], ocname[0] },
	{ "clkout1name", NULL, &oname[1], ocname[1] },
	{ "clkout2name", NULL, &oname[2], ocname[2] },
	{ "clkout3name", NULL, &oname[3], ocname[3] },
	{ "clkout4name", NULL, &oname[4], ocname[4] },
	{ "clkout5name", NULL, &oname[5], ocname[5] },
	{ "clkout6name", NULL, &oname[6], ocname[6] },
	{ "clkoutfbname", NULL, &oname[7], ocname[7] },
	{ "clkinvsuf", NULL, &invsuff, "" },
	{ "resetname", NULL, &resetname, "" },
	{ "lockname", NULL, &lockname, "" }
    };
#define NARG (int)(sizeof(args)/sizeof(args[0]))

    const char *prog = argv[0];
    while(--argc > 0) {
	const char *parm = *++argv, *eq = strchr(parm, '=');
	if(*parm == '-' && parm[1] && !parm[2])
	    switch(parm[1]) {
	      case 's':
		if(argc == 1)
		    break;
		argc--;
		spd = atoi(*++argv) - 1;
		if(spd < 0 || spd >= 3) {
		    fprintf(stderr, "Speed grade must be 1..3\n");
		    break;
		}
		continue;
	      case 'm':
		use_mmcm = 1;
		continue;
	      case 'd':
		dyn_freq = 1;
		continue;
	      case '4':
		clk6_clk4 = use_mmcm = 1;
		continue;
	    }
	if(!eq)
	    break;
	int i;
	for(i = 0; i < NARG; i++)
	    if(!strncasecmp(args[i].name, parm, eq - parm) &&
	       !args[i].name[eq - parm]) {
		if(args[i].val)
		    *args[i].val = atof(eq + 1); // too lazy for validity check
		else if(eq[1])
		    *args[i].sval = eq + 1;
		else
		    *args[i].sval = NULL;
		break;
	    }
	if(i == NARG)
	    break;
    }
    if(argc) {
	if(strcmp(*argv, "--help") && strcmp(*argv, "-h") &&
	   strcasecmp(*argv, "help"))
	    fprintf(stderr, "Invalid parameter %s\n", *argv);
	fprintf(stderr,
		"Usage: %s [flag|parm=val] ...\n"
		"Flags:\n"
		"\t--help|-h|help: Print this message\n"
		"\t-s <n>: Set speed grade for limit defaults (1-3; default 1)\n"
		"\t-m: Use of MMCME2 instead of PLLE2\n"
		"\t    This gives you fractional OUT0/OUTFB dividers, OUT6, inverted outputs\n"
		"\t    Also, allows higher dividers on OUT4 via OUT6\n"
		"\t    Forced on if inverted outputs or OUT6 enabled.\n"
		/* also fine phase, stopped clock signals (not supported) */
		"\t-4: Enable OUT6 to OUT4 cascade (dual dividers on 4)\n"
		"\t-d: Enable dynamic configuration ports (same names as primitive).\n"
		"\n"
		"Parameters (case-insensitive):\n"
		"Frequencies, in MHz (floating point):\n"
		"\tFCLKIN1: Input Frequency\n"
		"\tFCLKOUT0..FCLKOUT6: Output Frequency (0=disable)\n"
		"Limits, in MHz (floating point):\n"
		"\tF(CLKIN|CLKOUT|VCO|PFD)(MIN|MAX)\n"
		"Name overrides (blank = return to default):\n"
		"\tmodname: Module name (pll)\n"
		"\tCLKIN1name CLKOUT0name..CLKOUT6name CLKINSELname: Port name\n"
		"\tCLKIN2name: Port name; suppressed (along with SEL) if blank/default\n"
		"\tCLKInvSuf: Suffix for inverted out; suppressed if blank/default\n"
		"\tCLKFBname RESETname LOCKname: Port name; suppressed if blank/default\n",
		prog);
	exit(1);
    }
    for(int i = 0; i < NARG; i++)
	if(args[i].sval && !*args[i].sval)
	    *args[i].sval = args[i].def;

    if(FCLKOUT[6] || invsuff[0])
	use_mmcm = 1;
    const struct tlimit *deflim;
    if(use_mmcm)
	deflim = &speed_limit[spd];
    else
	deflim = &speed_limit[spd + 3];
    for(int i = 0; i < 8; i++)
	if(!((double *)&limit)[i])
	    ((double *)&limit)[i] = ((const double *)deflim)[i];

    if(FCLKIN1 < limit.FCLKINMIN || FCLKIN1 > limit.FCLKINMAX) {
	fprintf(stderr, "Illegal FCLKIN1 %g; use %g-%g\n",
		FCLKIN1, limit.FCLKINMIN, limit.FCLKINMAX);
	exit(1);
    }
    for(int i = 0; i < 7; i++)
	if(FCLKOUT[i] && (FCLKOUT[i] < limit.FCLKOUTMIN ||
			  FCLKOUT[0] > limit.FCLKOUTMAX)) {
	    fprintf(stderr, "Illegl FCLKOUT%d %g; use %g-%g\n",
		    i, FCLKOUT[i], limit.FCLKOUTMIN, limit.FCLKOUTMAX);
	    exit(1);
	}

    int CLKIN_DIV = 0, CLKOUT_DIV[8] = {};
    #define CLKFB_DIV CLKOUT_DIV[7]
    // XC7 clocks:
    //  Outputs = FCLKOUT0..6
    //   CLKOUTn = FVCO / CLKOUTn_DIV
    //  Feedback clock is CLKFB
    //  ref = CLKIN1 / CLKIN_DIV
    //  ref = FVCO / CLKFB_DIV
    //  FVCO = CLKI / CLKIN_DIV * CLKFB_DIV
    //  Choose highest possible VCO that most closely matches all output clocks
    //    after division:
    // [DIVCLK_DIVIDE = 1-56(!)PLL, 1-16(!)MMCM]
 
/* FCLKIN[12] / DIVCLK_DIVIDE = ref1  // 1-56(!)PLL, 1-106(!)MMCM
 *                                    // note: also 2 external 6-bit in div(?)
 * FCLKOUTn = VCO / CLKOUTOn_DIVIDE // 7-bit: 1-128
 * FCLKOUT0 = VCO / CLKOUTO0_DIVIDE_F // on MMCM; 7+3-bit: 1-128, 2.0..128.0
 * FCLKOUT4 = VCO / CLLKOUTO6_DIVIDE / CLKOUTO4_DIVIDE // MMCM CLKOUT4_CASCADE
 * CLKFBOUT = VCO / CLKFBOUT_MULT = ref2 // 6-bit: 2-64; plus _F on MMCM
 * ref1 = ref2; so VCO = FCLKIN[12] * CLKFBOUT_MULT / DIVCLK_DIVIDE.
 * _F is 1/8 step increments for "fractional divide".  Given as floating pt
 * parameter value (f4pga scales this).  In fact, I guess you're supposed to
 * use the _F version instead of the non-_F version for those two dividers.
 * It's annoying that it only has a high-level interface with auto-calculation
 * of some hidden/undocumented parameters (like COMPENSATION).  The only
 * manual override is to put it in dynamic config mode and program the
 * registers by hand, which is way too much effort (and impossible due to
 * the lack of documentation, although the free tools seem to have reverse
 * engineered the tables and have them in their code to duplicate as needed.
 * It's supposedly also avaialble with the reference design, but I can't
 * figure out how to download the reference design.
 * Note that in order to auto-fill those hidden values, they require you
 * to input CLKIN[12]_PERIOD (ns, float, 0.938..100.0(MMCM)/52.631(PLL)).
 */

/* SS_EN seems important enough that it should be passed down */


    double minerr = FCLKIN1;
    int maxidiv = floor(FCLKIN1 / limit.PFDMIN);
    if(maxidiv > 128)
	maxidiv = 128;
    // PFDMAX == FCLKINMAX (and FCLKOMAX) so 1 is the minimum, always
    // Go in reverse dir so lower dividers are preferred
    // (the last best value is always chosen)
    for(int idiv = maxidiv; idiv >= 1; idiv--) {
	int maxfbdiv = ceil(limit.FVCOMAX / FCLKIN1 * idiv);
	int minfbdiv = floor(limit.FVCOMIN / FCLKIN1 * idiv);
	if(minfbdiv < 2)
	    minfbdiv = 2;
	if(maxfbdiv > 64)
	    maxfbdiv = 64;
	if(use_mmcm)
	    maxfbdiv *= 8;
	// But go in forward direction for multipliers, so the largest VCO
	// will be chosen
	for(int fbdiv = minfbdiv; fbdiv <= maxfbdiv; fbdiv++) {
	    double fvco = FCLKIN1 * fbdiv / idiv;
	    if(use_mmcm)
		fvco /= 8;
	    double ferr = -1;
	    int fdiv[7] = {};
	    for(int c = 0; c < 7; c++) {
		int adj = c || !use_mmcm ? 1 : 8;
		if(FCLKOUT[c]) {
		    int tdiv = floor(fvco * adj / FCLKOUT[c]);
		    double terr, terr2;
		    if(tdiv <= 128 * adj) {
			if(tdiv < 128 * adj)
			    terr2 = fabs(FCLKOUT[c] - fvco / (tdiv + 1) * adj);
			else terr2 = 10000;
			if(tdiv)
			    terr = fabs(FCLKOUT[c] - fvco / tdiv * adj);
			else terr = 10000;
			if(terr2 < terr) {
			    terr = terr2;
			    fdiv[c] = tdiv + 1;
			} else
			    fdiv[c] = tdiv;
			if(terr > ferr)
			    ferr = terr;
		    } else
			continue;
		}
	    }
	    if(ferr >= 0 && ferr <= minerr) {
		minerr = ferr;
		CLKIN_DIV = idiv;
		CLKFB_DIV = fbdiv;
		for(int i = 0; i < 7; i++)
		    CLKOUT_DIV[i] = fdiv[i];
	    }
	}
    }
    if(!CLKIN_DIV) {
	fputs("Can't find a solution.\n", stderr);
	exit(1);
    }

    double fvco = FCLKIN1 * CLKFB_DIV / CLKIN_DIV;
    if(use_mmcm)
	fvco /= 8;

    /* FIXME: elide disabled outputs */
    printf("module %s (\n"
	   "    input wire\n"
           "\t%s, // %g MHz\n", modname, iname, FCLKIN1);
    if(iname2[0])
	printf("\t%s, // input 2; not used in computaions\n"
	       "\t%s, // input 1(1)/2(0) sel\n",
	       iname2, iselname);
    if(resetname[0])
	printf("\t%s, // Active high reset\n", resetname);
    puts("    output wire");
    for(int i = 0; i < 7; i++) {
	char c = lockname[0] || dyn_freq ? ',' : ' ';
	for(int j = i + 1; j < 7; j++)
	    if(FCLKOUT[j])
		c = ',';
	int adj = i || !use_mmcm ? 1 : 8;
	if(FCLKOUT[i])
	    printf("\t%s%c // %g (%g) MHz\n",
		   oname[i], c, FCLKOUT[i], fvco / CLKOUT_DIV[i] * adj);
    }
    printf("\t// VCO = %g / %d * %d%s = %g (%g-%g) MHz\n",
	   FCLKIN1, CLKIN_DIV, CLKFB_DIV, use_mmcm ? " / 8" : "", fvco,
	   limit.FVCOMIN, limit.FVCOMAX);
    if(lockname[0])
	printf("\t%s%s\n", lockname, dyn_freq ? "," : "");
    if(dyn_freq)
	puts("    // Dynamic (re)configuration\n"
	     "    input wire DEN, DCLK, DWE,\n"
	     "    input wire [6:0] DADDR,\n"
             "    input wire [15:0] DI,\n"
	     "    output wire DRDY,\n"
	     "    output wire [15:0] DO");
    puts(");\n"
	 /* default values from ug742 7 Series Clocking */
	 "\t// The following parameters are passed down to the PLL primitive:\n"
	 "parameter\n"
	 "\t// Insufficiently documented for direct support\n"
	 "\tBANDWIDTH = \"OPTIMIZED\", COMPENSATION = \"ZHOLD\",\n"
	 "\tSTARTUP_WAIT = \"FALSE\",\n"
	 "\t// Phase and duty cycle not directly supported");
    for(int i = 0; i < 7; i++) {
	const char c = i == 5 && !use_mmcm ? ';' : ',';
	printf("\t%s_PHASE = 0.0, %s_DUTY_CYCLE = 0.50%c\n", oname[i], oname[i], c);
	if(use_mmcm && !i)
	    printf("\t%s_USE_FINE_PS = \"FALSE\", CLKFBOUT_USE_FINE_PS = \"FALSE\",\n",
		  oname[0]);
	if(c == ';')
	    break;
    }
    if(use_mmcm)
	puts("\t// Not directly supported\n"
	     "\tSS_EN = \"FALSE\", SS_MODE = \"CENTER_HIGH\", SS_MOD_PERIOD = 10000;");
    puts("\n    wire _fbclk_;");
    printf("\n\n    %sE2_ADV #(\n"
	   "\t.CLKIN1_PERIOD(%g), .DIVCLK_DIVIDE(%d),",
	   /* Supposedly CLKIN2_PERIOD is also mandatory, but I don't see how
	    * it could affect parameters, since you can't switch */
	   use_mmcm ? "MMCM" : "PLL", 1000.0 / FCLKIN1, CLKIN_DIV);
    for(int i = 0; i < 8; i++) {
	if(i == 6 && !use_mmcm)
	    continue;
	int adj = !use_mmcm ? 1 : !i || i == 7 ? 8 : 1;
	const char *frac = adj == 8 ? "_F" : "";
	if(!(i%3) || i == 7)
	    fputs("\n\t", stdout);
	else
	    putchar(' ');
	printf(".%s_%s%s(%g),",
	       ocname[i], i < 7 ? "DIVIDE" : "MULT", frac,
	       i == 7 || FCLKOUT[i] ? (double)CLKOUT_DIV[i] / adj : 1.0);
    }
    putchar('\n');
    if(use_mmcm)
	printf("\t.CLKOUT4_CASCADE(\"%s\"),\n",
	       clk6_clk4 ? "TRUE" : "FALSE");
    for(int i = 0; i < 7; i++) {
	printf("\t.CLKOUT%d_PHASE(%s_PHASE),\n"
	       "\t.CLKOUT%d_DUTY_CYCLE(%s_DUTY_CYCLE),\n",
	       i, oname[i], i, oname[i]);
	if(use_mmcm && !i)
	    printf("\t.CLKOUT0_USE_FINE_PS(%s_USE_FINE_PS),\n"
		   "\t.CLKFBOUT_USE_FINE_PS(CLKFBOUT_USE_FINE_PS),\n",
		  oname[0]);
	if(i == 5 && !use_mmcm)
	    break;
    }
    if(use_mmcm)
	puts("\t.SS_EN(SS_EN), .SS_MODE(SS_MODE), .SS_MOD_PERIOD(SS_MOD_PERIOD),");
    puts("\t.BANDWIDTH(BANDWIDTH), .COMPENSATION(COMPENSATION),\n"
	 "\t.STARTUP_WAIT(STARTUP_WAIT)");
    printf("      ) pll (\n"
	   /* inputs */
	   "\t.CLKIN1(%s), .CLKIN2(%s), .CLKINSEL(%s), .RST(%s),\n"
	   /* maybe unused inputs */
	   "\t.DADDR(%s), .DI(%s), .DWE(%s), .DEN(%s), .DCLK(%s),\n"
	   /* unused inputs*/
	   /* well, as it turns out, the schematic indicating connections is */
	   /* wrong, so you need to connect CLKFBIN to CLKFBOUT */
	   "\t.CLKFBIN(_fbclk_), .PWRDWN(1'b0),%s\n"
	   /* outputs */
	   "\t.LOCKED(%s), .CLKOUT0(%s), .CLKOUT1(%s),\n"
	   "\t.CLKOUT2(%s), .CLKOUT3(%s), .CLKOUT4(%s),\n"
	   "\t.CLKOUT5(%s), .CLKFBOUT(_fbclk_),\n",
	   /* inputs */
	   iname, iname2[0] ? iname2 : "1'b0", iname2[0] ? iselname : "1'b1",
	   resetname[0] ? resetname : "1'b0",
	   /* maybe unused inputs */
	   dyn_freq ? "DADDR" : "7'b0", dyn_freq ? "DI" : "15'b0",
	   dyn_freq ? "DWE" : "1'b0", dyn_freq ? "DEN" : "1'b0",
	   dyn_freq ? "DCLK" : "1'b0",
	   /* phase as yet unsupported */
	   use_mmcm ? " .PSEN(1'b0), .PSCLK(1'b0), .PSINCDEC(1'b0)," : "",
	   /* outputs */
	   lockname,
	   FCLKOUT[0] ? oname[0] : "", FCLKOUT[1] ? oname[1] : "",
	   FCLKOUT[2] ? oname[2] : "", FCLKOUT[3] ? oname[3] : "",
	   FCLKOUT[4] ? oname[4] : "", FCLKOUT[5] ? oname[5] : ""/*,
	   oname[7]*/);
    if(use_mmcm)
	printf("\t.CLKOUT6(%s), .CLKOUT0B(%s%s), .CLKOUT1B(%s%s),\n"
	       "\t.CLKOUT2B(%s%s), .CLKOUT3B(%s%s), .CLKFBOUTB(%s%s),\n"
	       "\t.PSDONE(), .CLKINSTOPPED(), .CLKFBSTOPPED(),\n",
	       FCLKOUT[6] ? oname[6] : "",
	       FCLKOUT[0] && invsuff[0] ? oname[0] : "", FCLKOUT[0] ? invsuff : "",
	       FCLKOUT[1] && invsuff[0] ? oname[0] : "", FCLKOUT[1] ? invsuff : "",
	       FCLKOUT[2] && invsuff[0] ? oname[0] : "", FCLKOUT[2] ? invsuff : "",
	       FCLKOUT[3] && invsuff[0] ? oname[0] : "", FCLKOUT[3] ? invsuff : "",
	       invsuff[0] ? oname[7] : "", oname[7][0] ? invsuff : "");
    printf("\t.DO(%s), .DRDY(%s)\n"
	   "      );\n"
	   "endmodule\n",
	   dyn_freq ? "DO" : "", dyn_freq ? "DRDY" : "");
    return 0;
}
