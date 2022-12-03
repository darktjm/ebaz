EBAZ4205 Miscellany
===================

This is currently just some miscellaneous stuff I wish to share
publicly related to the EBAZ4205 bitmining control board, which I use
as a Zynq 7010 FPGA development platform.  Keep in mind that before I
had a stupid idea to do something on an FPGA mid-March 2022, I
didn't know jack about FPGAs or anything related to them, other than a
vague awareness of their existence.  It's been more than 30 years
since I was an electronics hobbyist on my aborted EE path.

This repository may disappear at any time, since it is only a
subproject of a larger FPGA-related project, and I might merge it with
that.

I also own and use an expansion board which I cannot identify.  I
got it from the JSSHENGZHI store on AliExpress.   See
`hdmi-lcd-board-schem.jpg` for a schematic (pulled from the AliExpress
product page, <https://www.aliexpress.us/item/3256804274079996.html> and
combined from 2 images into 1 for convenience).

Other files of note:

  - `ebaz.xdc` - physical constraints for all available board
    resources.  Naturally, to use this, you will either need to
    ensure constraint errors are just warnings, or hand-edit it
    for every project.  I don't like hand-editing stuff that
    should be "standard", so I choose the former option.  This
    requires patching f4pga (optcstr.patch).  Good luck.

    Note that this does not include timing constraints.

    I guess placing comments after lines doesn't work as I would
    expect (maybe that's not legal TCL?), because Vivado gives
    warnings about it.  Just ignore them.

  - `mkebaz` - the script I currently use to compile, using f4pga.
    I hate f4pga's use of the Python ecosystem (Python itself is
    awful, but worse yet, pip and conda replace sane package
    management with a joke of a mess), but it's the only thing I
    can currently use to create binaries, without resorting to
    Vivado.  I separated the conda stuff into `f4pga.sh`, which
    mkebaz sources from `~/bin`.  Change the path if you actually
    use this (which I don't recommend, because it's for me, and I
    haven't really cleaned it up yet).  One major deficiency is
    that it tries to skip already-done steps, but doesn't really
    have sufficient knowledge of what might require redoing steps.
    Best to just wipe out the build directory every time before
    use.
  
    For example, to build the ethernet example into `build-ebaz/ebaz.bit`
    (derived from the xdc name):
>     mkebaz -t top eth.v pll.v ebaz.xdc

  - `fpgasynth` - this is my generic wrapper program around the
    yosys+nextpnr toolchain.  It really only works for Lattice
    parts, because the Xilinx and Gowin tools are missing
    important primitives.  In fact, I was so frustrated by the
    lack of support for Gowin parts, that I added `gw_tcl` support
    to `fpgasynth`.  I may eventually merge in `f4pga` support
    from `mkebaz` or even `Vivado -mode tcl` (if I ever find
    usable documentation) if I continue to run into issues in the
    free toolchains.  It's important to note that if you do use
    this for Gowin, I always wrap the Gowin binaries with my `nonet`
    program (see the <https://bitbucket.org/darktjm/gamesup>).  I do
    the same with Vivado, when I actually run it.  I suspect this is
    the reason 2022.1 crashes so much.  Sorry, no phoning home for
    you.

  - `xc7pll.c` - source for a simple PLL generator.  I used
    Verilog to implement this for the Gowin FPGAs, but the code
    was dog slow for anything else, so I rewrote it in C.  Less
    convenient to use, but adequate for now.  Probably the main useful
    feature missing still is the ability to generate register sets for
    dynamic configuration.  This will be important for dynamic HDMI
    resolution changing.  Or I could just generate a fixed list of
    clocks and switch between them, probably.

    For example:

>       xc7-pll FCLKIN1=125 FCLKOUT0=25 CLKIN1name=fclk CLKOUT0name=clk25 >pll.v
>       xc7-pll -m modname=vidpll FCLKIN1=125 FCLKOUT1=371.25 FCLKOUT0=74.25 \
>                  CLKIN1name=fclk CLKOUT0name=clk_pixel \
>                  CLKOUT1name=clk_shift >vid-pll.v

  - `zynq-ps7.v` - macro library to asisst in using the PS7
    component.  This macro library does not work properly in
    Vivado.  I moved the raw semicolon out of the macro
    definitions, which makes it at least work in System Verilog
    mode on 2022.1, but I can't get 2022.1 to do anything useful
    on my machine without crashing, so I use 2017.2, which doesn't
    like it even with the deferred semicolon and System Verilog
    mode.  A workaround is to use a preprocessor like
    `verilator -P -E` (I don't know yet how to set it up to always use
    this, so for my tests, I just generate my top-level this way by
    hand).

  - `ebaz-eth.v` - macro library to easily add raw ethernet
    forwarding.  Depends on `zynq-ps7.v`.  `eth.v` is a sample
    top-level using these macros, as well as (maybe) supplying the
    25MHz clock for boards missing the crystal oscillator (which
    also requires `pll.v`; see above for how to generate).  I say
    maybe because my board has the oscillator, so I haven't really
    tested if it works.

  - `demo` - against my better judgement, I have included my
    simple demo which exercises the components I want: LEDs,
    pushbuttons, speaker, LCD, USB UART (echos @115200), ethernet
    passthrough, and HDMI.  Currently, HDMI doesn't work, and I
    have no idea why.  There also seems to be an issue with the
    LCD backlight, even though another demo I have (the ulx3s-misc
    collatz example ported to the ebaz) seems to work, at least in
    that regard.  Parts were taken from other projects which were
    independently verified as working, to eliminate possible
    errors on my part (but I still managed to sneak an error into
    the uart code):
      - LCD support: <https://github.com/emard/ulx3s-misc> spi_display example
      - HDMI support: <https://github.com/emard/ulx3s-misc> dvi example
      - UART: <https://github.com/jamesbowman/swapforth> j1b (with
	broken merge in progress of j1a/j1b by me)
    These include minor patches to fix compilation issues with Vivado
    and/or f4pga.  I will probably eventually provide a patch list for
    convenience.  Note also that the dvi example code was built from
    VHDL using the ulx3s-misc makefile.  I try to use the GHDL plugin
    for that sort of thing, but it doesn't work with generic
    parameters, and not doing so just elimiates one more source of
    headaches.

During HDMI debugging, I also verified the H4 pins work as expected. 
I have successfully booted from SD card (instead of moving the
resistor, I patched a resistor to a non-connected pin on the JTAG
header, and use a jumper from that pin to either VCC or GND pins on
the same header to switch between boot modes).  I currently prefer to
just boot from flash - see
<https://github.com/xjtuecho/EBAZ4205#reset-the-root-password-of-built-in-linux>
for decent instructions on how to boot from the pre-loaded flash.

Part of the reason I prefer the default flash is that the kernel has
the old `/dev/xcdevcfg` device for programming the FPGA:

>       scp build-*/*.bit ebaz:/tmp && ssh ebaz "cat /tmp/*.bi? >/dev/xdevcfg"

The only SD card images I have require much more work so that I can
actually use the newer firmware-style programming method (e.g. the
kernels I have need a recompile to actually enable the firmware
subystem fully, not just the FPGA-related sub-drivers).

While bootgen is open source/available on github, I have yet to use
bootgen to generate a full binary for flashing or SD card generation,
because I had trouble finding fsbl.  I should be able to use the one
from Vivado now that I've finally given in and installed it.

My grumbling; feel free to ignore
---------------------------------

Some bugs in the free tools have been unaddressed for years now.  Will
the free toolchain ever actually be ready for prime time?  I don't
really care for `vpr` as packaged by `f4pga`, either, given that its
reports are useless and it takes forever (likely due to
<https://github.com/f4pga/f4pga-arch-defs/issues/1863>, mostly).  No
`MMCME2_ADV` or `BUFR` or `PLLE2_BASE` or `MMCME2_BASE` and who knows
how many other missing primitives (it's not worth my time to make a
comprehensie list, like I did for Gowin parts).  Plus apparently even
if it were there, `MMCME2_ADV` is producing incorrect results.  At
least it supports the all-important PS7 primitive, without which there
would be no clocks (or ethernet passthrough, which makes programming
easier).

Unfotunately, even though `nextpnr-xilinx` is much faster and produces
better reports, it has many more missing primitives (maybe because I
built it incorrectly, but it's hard for me to tell either way). I do
not see f4pga going anywhere I want to follow, so if I do put effort
into making a free tool work better, it will be nextpnr-xilinx.
Significantly less than 60k/3G files, and at least far less Python
(seems impossible to get away from it entirely without rewriting
everything from scratch).

Given my frustration with how f4pga is structured and the lack of
support for important things (no devices other than what the free
version of Vivado supports, anyway, but with fewer components, longer
compile times, and just as little control over what happens since
managing 60k/3G installed files is bullshit), I will likely never use
f4pga again.  The only development that might change my mind is
xc7k325t support, which likely won't happen.  The only artifact I have
preserved from my previous use of f4pga is a small patch to reduce the
embedded device name in the binary so the ebaz default kernel will
load it (xc_fasm.patch).  I already mentioned my optional constraints
patch above.  I recall spending a lot of time in the install dir, so I
probably made other changes as well, but I don't remember and I don't
care any more.  I've now chucked them all in favor of a fresh install.

"F4PGA: The GCC of FPGAs".  Right.  Not only is it not a standalone
project (all components except for the crappy Python glue code come
from elsewhere), but it's extremely poorly documented (an example can
supplement, but not replace actual documentation) with frequent
changes and no view whatsoever towards backwards compatibility.  Ever
hear the expression "Bugs are just undocumented features"?  Works both
ways.  All undocumented features are bugs.  Learn to write
documentation before you churn out code.  Pretty much what I expect of
modern open source projects, rather than the standard GCC was based
on.  I certainly hope it doesn't become the (only) standard open
source toolkit for FPGAs.  Or if it does, it becomes better somehow (I
doubt it will drop Python or its completely broken dependency
management systems any time soon, though).

Once again, like with the Gowin parts, I have been fooled into
thinking things were ready, when they weren't.  At least with Gowin I
got a mstly hassle-free full prorprietary Linux toolchain free of
charge; AMD/Xilinx makes no similar offers.  Their proprietary
toolchain has more hassle (less usable documentation, for one) and
only supports a subset of devices (e.g. no Kintex parts at all, even
though Kintex dev boards are now pretty cheap comparitively).

I might abandon the Xilinx FPGA line in general anyway, since it's
steeped in the same bullshit that contributed to my abandonment of the
electronics hobby years ago, such as requiring essentially a club
membership fee in order to use components (lack of documentation
combined with no free-of-charge usable tools to partially compensate,
except for "selected" components, such as no Kintex suppoprt at all).

License Information
-------------------

As with all of my software in the past few years, everything in this
repository is in the Public Domain, except as noted for specific files
(i.e., files I've borrowed from other projects).   If you find I've
violated anybody else's licences with this inclusion, let me know and
I'll remove it, and avoid it at all costs in the future.
