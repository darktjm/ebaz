EBAZ4205 Miscellany
===================

This is currently just some miscellaneous stuff I wish to share
publicly related to the EBAZ4205 bit-mining control board, which I use
as a Zynq 7010 FPGA development platform.  Keep in mind that before I
had a stupid idea to do something on an FPGA mid-March 2022, I
didn't know jack about FPGAs or anything related to them, other than a
vague awareness of their existence.  It's been more than 30 years
since I was an electronics hobbyist on my aborted EE path.

This repository may disappear at any time, since it is only a
sub-project of a larger (not yet public) FPGA-related project, and I
might merge it with that.  That project is stalled for now, though.
The stall is both for technical issues and a slight divergence into
another side project, which is even larger in some respects.

I also own and use an expansion board which I cannot identify.  I got
it from the JSSHENGZHI store on AliExpress.  See
`hdmi-lcd-board-schem.jpg` for a schematic (pulled from the AliExpress
product page, <https://www.aliexpress.us/item/3256804274079996.html>;
I will make no attempt to ensure this link stays alive) and combined
from 2 images into 1 for convenience).

Other files of note:

  - `ebaz.xdc` - physical constraints for all available board
    resources.  Naturally, to use this, you will either need to
    ensure constraint errors are just warnings, or hand-edit it
    for every project.  I don't like hand-editing stuff that
    should be "standard", so I choose the former option.

    Note that this does not include timing constraints.  For the free
    tools in particular, there is no way to provide a common file.
    For Vivado, the PLLs auto-create clocks, so it probably isn't
    necessary for simple projects.  Really, though, I have no idea
    what I'm doing timing-wise, and should probably do more research.
    Timing constraints may well be the reason for inconsistently bad
    behavior of the HDMI demo.

    I guess placing comments after lines doesn't work as I would
    expect (maybe that's not legal TCL?), because Vivado gives
    warnings about it.  I used to say "just ignore them", but I've
    gone ahead and put the comments on the next line.

  - `fpgasynth` - this is my generic wrapper program for converting
    source to bitstreams.  Originally, I only wanted to support `yosys`
    and `nextpnr` with Verilog source.  As I was playing with open
    cores, I added VHDL support.  In generally, as my needs grew, so did
    the script.  It's become unmanageable, so I will eventually
    rewrite it.  Maybe once I finally get some basics working right.
    This replaces my old `mkebaz` script now, as well.  For Xilinx, it
    supports Vivado and `nextpnr-xilinx` (don't know what version; I just
    keep git up-to-date for now).  I used to support f4pga, but since it
    produced bad results (and didn't support everything it should to begin
    with) in my tests, I have removed it entirely from my system.  Since
    `nextpnr-xilinx` also can't produce usable output most of the
    time, I made Vivado the default, and recommend using it unless you're
    feeling masochistic.

    There is on-line help (`-h` option) and an example.  Since I'm
    going to rewrite it, and I really ought to distribute it as a
    separate project, rather than part of this one, that will have to
    do for documentation.  I have actually left out `mk_testrig.sh`
    and `testrig.v` (used while I was trying to see if open cores
    would compile at all with `yosys`+`nextpnr`) and `fa2add.jq`,
    which I was using to experiment with adding carry chains to
    manually implemented adders (part of my original purpose for
    getting into FPGAs was to allow drawing of schematics to produce
    circuits, including manual implementations of adders).

    It's important to note that I use wrapper scripts for the
    commercial tools which at least use `nonet` (see
    <https://github.com/darktjm/gamesup>) to disable phoning
    home (or any other network access).  I suspect this is the
    reason that Vivado 2022 crashes so much (no testing for
    behavior on failure to access the network).  I won't even try
    without:  sorry, no phoning home for you.

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

  - `zynq-ps7.v` - macro library to assist in using the PS7
    component.  This macro library does not work properly in
    Vivado.  I moved the raw semicolon out of the macro
    definitions, which makes it at least work in System Verilog
    mode on 2022.2.  2022.2 crashes a lot if I wrap it in `nonet`, so
    I've disabled the wrapper for now.  It doesn't appear to call home,
    anyway, so I'm not even sure why it crashes.  2017.2 does not crash,
    but it doesn't like the macros no matter what.  A workaround, which
    I used to do in my scripts, is to use a preprocessor like
    `verilator -P -E`.  I initially implemented automatic preprocessing
    in `fpgasynth`, but backed out because I really don't like
    managing files this way. 

  - `ebaz-eth.v` - macro library to easily add raw ethernet
    forwarding.  Depends on `zynq-ps7.v`.  `eth.v` is a sample
    top-level using these macros, as well as (maybe) supplying the
    25MHz clock for boards missing the crystal oscillator.  I say
    maybe because my board has the oscillator, so I haven't really
    tested if it works.  To build:

>       ./fpgasynth -X z -o ebaz -t top eth.v
>       ./prgebaz

  - `ysv-supt.v` - macro library to assist in one of the issues porting
    SystemVerilog code to yosys-native (rather than the Surelog
    plugin).  See `demo/hdmi` for example usage.  While this fixes the
    yosys array access errors, the HDMI code still does not work with
    the free tool chain.

  - `demo` - against my better judgment, I have included my
    simple demo which exercises the components I want: LEDs,
    push buttons, expansion connector (H4), speaker, LCD, USB UART
    (echos @115200), ethernet pass through, and HDMI.  There seems to
    be an issue with the LCD back light, even though another demo I
    have (the ulx3s-misc collatz example ported to the ebaz) seems to
    work, at least in that regard.  Parts were taken from other
    projects which were independently verified as working, to
    eliminate possible errors on my part (but I still managed to sneak
    an error into the UART code):
      - LCD support: <https://github.com/emard/ulx3s-misc> spi_display example
      - HDMI with audio support: <https://github.com/hdl-util/hdmi> with
        some modifications by me.  It's System Verilog, not supported by
	yosys directly.  I will (re-)port it to something more yosys-friendly
	at some point, but I can't use f4pga to make working HDMI, anyway,
	so I've only made minor modifications.
      - UART: <https://github.com/jamesbowman/swapforth> j1b (with
	broken merge in progress of j1a/j1b by me)
    These include minor patches to fix compilation issues with Vivado
    and/or f4pga.

Booting
-------

I have successfully booted from SD card (instead of moving the
resistor, I patched a resistor to a non-connected pin on the JTAG
header, and use a jumper from that pin to either VCC or GND pins on
the same header to switch between boot modes).  I currently prefer to
just boot from flash - see
<https://github.com/xjtuecho/EBAZ4205#reset-the-root-password-of-built-in-linux>
for decent instructions on how to boot from the pre-loaded flash.  In
summary, disable the bit-miner software and set up the network the way
you like it.

Part of the reason I prefer the default flash is that the kernel has
the old `/dev/xcdevcfg` device for programming the FPGA:

>       scp build-*/*.bit ebaz:/tmp && ssh -n ebaz "cat /tmp/*.bi? >/dev/xdevcfg"

I have added my `prgebaz` script that I use to upload an image.  It
probably at least needs the host name changed.

I have made an SD card image using `buildroot`, partially based on
<https://github.com/blkf2016/ebaz4205>.  I made a number of changes to
the configuration; see the `buildroot` sub-directory.  I also attempted
(so far unsuccessfully) to build a `boot.bin` from scratch.  Instead,
I continue to use the one from the aforementioned site.  The
bitstream is `eth.v`, compiled using `yosys` and `nextpnr-xilinx`,
and the main payload is `u-boot` generated by `buildroot`.  Just as
with the default ROM, no registers are adjusted before the fsbl is
loaded.  The missing component is the fsbl itself
(<https://github.com/Xilinx/embededsw>), which I can't seem to make
properly.  Do not use the `fsbl.elf` or the `boot.bin` generated with
it; the fsbl will not start, even though it compiled without errors
after much effort.  While the `boot.bin` from the afore-mentioned
project is sufficient for SD card booting, my inability to replace the
FSBL may make it impossible to fully replace the default flash image.

While I suppose it might have been possible to use the device tree
overlay method Xilinx describes in its wiki to program using the
supplied SD card file system image from
<https://github.com/blkf2016/ebaz4205>, I instead enabled support for
programming through sysfs.  See `prgebaz` for the method I used.  I
also updated `fpgasynth` to invoke `bootgen` (from
<https://github.com/Xilinx/bootgen>) to generate the necessary file
format.  I was unable to use non-Xilinx kernels, or, for that matter,
Xilinx' git head, so I used `xilinx-v2022.2` from
<https://github.com/Xilinx/linux-xlnx>.  I think Xilinx forgot to send
some things upstream.
 
My grumbling; feel free to ignore
---------------------------------

Probably my biggest disappointment is that I had to resort to
commercial tools for this (and Gowin support, and, more recently, even
for Lattice ECP5 support).  I was under the impression that the free
tools were at least mostly ready; it appears that I was misled.  It
really only works for simple demos.  With luck, you might get other
stuff to work as well (barely).  In the case of Gowin, it is missing
critically important primitives and support for non-primitive on-board
hardware; this was the first one I replaced with the commercial tool
in `fpgasynth` (June 2022).  For Xilinx, I was able to initially work
around the lack of important primitives in f4pga (Oct 2022), but, even
then, in some tests, Vivado produces perfect working bitstreams, where
f4pga produces mostly garbage (Jan 2023).  At least both commercial
tools have Linux binaries, so I don't have to additionally deal with
wine issues.  Both have their own way of spraying files all over the
place, but can be mostly controlled via scripting.  At least the
free-of-charge Gowin tool chain (not the educational version) supports
all devices and all device features.  The free-of-charge Xilinx
tool chain supports the xc7z010 on the EBAZ, but doesn't support most
other parts (in particular, there are now cheap xc7k325t boards that
aren't supported).  I guess they don't want to sell those parts to
hobbyists, who don't want to invest a ton of money into just the
stupid software (and can't write their own software because the modern
way is to not ever document anything: you're lucky if publicly
available data sheets include a pinout and DC/AC characteristics of
sorts).  Both vendors like to force you to use proprietary IP blocks
(what I call "secret sauce"), which I will continue to avoid like the
plague that they are, until of course I find a need for one and have
to capitulate yet again.

Addendum to prev. paragraph, Feb. 2023:  And now, the last one has
fallen.  Even the Lattice ECP5 doesn't work right with the free tools,
as far as I can tell.  I have yet to build a bitstream with Diamond,
but the HDMI sound test doesn't produce any output, even though the
same, identical code (except for what primitives are being used) works
with both Gowin and Xilinx commercial tools.  The free tools provide
no warnings or errors to indicate anything is wrong; it simply
produces no output, and I don't feel like tracing it with a 'scope.
In fact, I don't feel like wading through yet another poorly commercial
tool chain to script it all, so I may just abandon the ECP5 for now.
So, my question went from "what parts are fully supported by the free
tools" to "what parts are supported well enough by the free tools" to
"what free of charge vendor tools are usable".  The answer to the
former two questions is apparently "none":  the free tools are not
ready for prime time, and I am not willing to fix them myself right
now so that they are.  The answer to the latter question is "Only
Gowin supports all parts and features, and also documents the
scripting in a usable manner".

I despise Python with the passion of a thousand fiery suns.  The
language (uncompilable, whitespace as a control structure, other
issues common with interpreted languages, like significant file names
and forced file structuring and simple integrity checks impossible to
do until run-time) and its interpreter(s) (consumes all available
resources if possible) are bad enough, but the ecosystem is even
worse.  Instead of providing a stable environment, every Python
program has to have an entire Python distribution attached.  No single
binary, but a whole tree for every Python program.  Python
"environments" managed by crappy package managers (pip and conda)
which bypass the system package manager to do their own thing, in your
home directory (where installed software does not belong).  This all
seems like a poor joke.  F4pga installs 60,000 files, consuming 3GB.
Entire usable operating systems with user space are smaller and better
managed.  These comments apply both to f4pga in particular and the
various reverse engineering projects, as well.  I have no idea how
Python ever got so popular, but it's become the new Visual BASIC.
Popular, but impossible to actually write good code in.

"F4PGA:  The GCC of FPGAs".  Right.  Not only is it not a standalone
project (all components except for the crappy Python glue code come
from elsewhere, although the yosys plugins are essentially part of
f4pga as well), but it's extremely poorly documented (an example can
supplement, but not replace actual documentation, and forcing people
to use your poorly written makefiles is inadequate at best) with
frequent changes and no view whatsoever towards backwards
compatibility.  Ever hear the expression "Bugs are just undocumented
features"?  Works both ways.  All undocumented features are bugs.
Learn to write documentation before you churn out code.  Pretty much
what I expect of modern open source projects, rather than the standard
GCC was based on.  I certainly hope it doesn't become the (only)
standard open source toolkit for FPGAs.  Or if it does, it becomes
better somehow (I doubt it will drop Python or its completely broken
dependency management systems any time soon, though).

Some bugs in the free tools have been unaddressed for years now.  Will
the free tool chain ever actually be ready for prime time?  I don't
really care for `vpr` as packaged by f4pga, either, given that its
reports are useless and it takes forever (likely due to
<https://github.com/f4pga/f4pga-arch-defs/issues/1863>, mostly).  No
`MMCME2_ADV` or `BUFR` or `PLLE2_BASE` or `MMCME2_BASE` and who knows
how many other missing primitives (it's not worth my time to make a
comprehensive list, like I did for Gowin parts).  Plus apparently even
if it were there, `MMCME2_ADV` is producing incorrect results.  At
least it supports the all-important PS7 primitive, without which there
would be no clocks (or ethernet pass through, which makes programming
easier).

Unfortunately, even though `nextpnr-xilinx` is much faster and produces
better reports, it has more missing primitives and can't even compile
my simple HDMI test (maybe because I built it incorrectly, but it's
hard for me to tell either way, especially given the wonderful
documentation).  I do not see f4pga going anywhere I want to follow,
so if I do put effort into making a free tool work better, it will be
`nextpnr-xilinx`.  Significantly less than 60k/3GB files, and at least
far less Python (seems impossible to get away from it entirely without
rewriting everything from scratch).

Given my frustration with how f4pga is structured and the lack of
support for important things (no devices other than what the free
version of Vivado supports, anyway, but with fewer components, longer
compile times, and just as little control over what happens since
managing 60k/3GB installed files is bullshit), I will likely never use
f4pga again.  The only development that might change my mind is full
xc7k325t support and MMCME2 for the xc7z010, which likely won't
happen.  I have removed all artifacts of f4pga from this project (but
obviously not all mentions), although you can get them from previous
commits if you insist.

I might abandon the Xilinx FPGA line in general anyway, since it's
steeped in the same bullshit that contributed to my abandonment of the
electronics hobby years ago, such as requiring essentially a club
membership fee in order to use components (lack of documentation
combined with no free-of-charge usable tools to partially compensate,
except for "selected" components, such as no Kintex support at all).
Plus even more bullshit, like the xc7a35t artificial limitations in the
commercial tool chain (i.e., it's really an xc7a50t hardware-wise).

License Information
-------------------

As with all of my software in the past few years, everything in this
repository is in the Public Domain, except as noted for specific files
(i.e., files I've borrowed from other projects).   If you find I've
violated anybody else's licenses with this inclusion, let me know and
I'll remove it, and avoid it at all costs in the future.
