EBAZ4205 Miscellany
===================

This is currently just some miscellaneous stuff related to the
EBAZ4205 bit-mining control board, which I use as a Zynq 7010 FPGA
development platform.  I am not a professional, and I stepped off of
the EE path and hobby more than 30 years ago.  My training consists of
reading data sheets and language standards, as well as looking at
other people's code, off and on since mid-March 2022.  My original
goal was to create an educational workflow involving automatic free
tools, but that has not panned out very well.  If I ever revive that,
or get going on another, unrelated project, I might delete this
repository in favor of integrating the results with those.

I also own and use an expansion board which I cannot identify.  It has
3 images of a cartoon girl (two large and one small) on the rear, if
that helps.  I got it from the JSSHENGZHI store on AliExpress.  See
`hdmi-lcd-board-schem.jpg` for a schematic (a merge of the two images
provided on the AliExpress product page,
<https://www.aliexpress.us/item/3256804274079996.html>; I will make no
attempt to ensure this link stays alive).  The board provides a USB
serial port (and power derived from it), an optional 256x256 LCD
display, an HDMI connector, some buttons, some LEDs, a single-wire
buzzer, and a .1" connector for unused USER port pins (compared to the
2mm pins of the EBAZ itself, this is much more convenient).  It costs
about as much as pre-made 2->2.54mm adapters made for it, so it seems
like a good deal.

Building Bitstreams
===================

When I first started, things were simple, and so I created a
relatively simple wrapper script to do everything.  In the mean time,
things have gotten much more complex, so `fpgasynth` has grown out of
control.  I will probably replace this some day, but I'm too occupied
with other things at the moment.  I sort of like the idea of having a
separate configuration utility, rather than command-line options or
commented lines in a script, but `cmake` is too focused on traditional
compilation, and kernel config, as used by `buildroot` and the ESP32
IDF, requires too much extra work for each new project, and I can't
really think of anything else.  I certainly won't use `scons` or
anything else Python-based (which, technically, includes the ESP32
IDF, I guess).

There is on-line help (`-h` option) and an example.  Probably the main
arguments to get started with the EBAZ4205 are `-X z` to select the
Zynq 7010 and `-o whatever` to select an output base name.  All other
arguments can just be Verilog or VHDL files.  Since I'm going to
rewrite it, and I really ought to distribute it as a separate project,
rather than part of this one, that will have to do for documentation.
I have actually left out `mk_testrig.sh` and `testrig.v` (used while I
was trying to see if open cores would compile at all with
`yosys`+`nextpnr`) and `fa2add.jq`, which I was using to experiment
with adding carry chains to manually implemented adders (part of my
original purpose for getting into FPGAs was to allow drawing of
schematics to produce circuits, including manual implementations of
adders).

I originally wanted to only support free software toolchains, `yosys`
and `nextpnr` in particular, but they have proven inadequate.  The
first to fall was Gowin, for which the free tools (based on apicula)
simply lack far too many primitives I am actualy interested in.  The
fact that the full, unlimited commercial toolchain was available free
of charge (with registration) helped as well.  Later I also found that
the commercial toolchain produced output with signifiantly lower
resource utilization, making me wonder of `yosys` (or probably more
precisely `abc`) optimizes at all.  Once I finally got my first
bitstream for Xilinx parts via f4pga, I was happy, until I realized
that it, too lacked many features, and produced lower quality output,
so I ended up using Vivado instead.  In fact, given my other gripes
about f4pga, I completely removed f4pga support in favor of Vivado
and `nextpnr-xilinx`.  Unfortunately, Vivado wants to call home, and
only supports a limited subset of parts, but at least it does support
the Zynq 7010 fully, I guess.  Recently I also had issues with Lattice
parts, but I don't really remember what in particular, and I can't get
Diamond to work, so it's really the only one that has no commercial
toolchain support.  Note that `yosys` is still used even with the
commercial toolchains, to do a bit of preprocessing.  It is also
possible to force the use of `yosys`+`nextpnr` with the `-y` flag.

It's important to note that I use wrapper scripts for the commercial
tools which at least use `nonet` (see
<https://github.com/darktjm/gamesup>) to disable phoning home (or any
other network access).  I have softened my stance on Vivado 2022.2,
since it crashes at the last minute without network access (although
`tcpdump` doesn't indicate that it's actually phoning home, I suspect
it actually is, or will when I'm not looking).  It had to be done in
order to actually get at least something working.  Hopefully
`nextpnr-xilinx` will improve to the point where I will no longer feel
the need to use Vivado.

Constraints
-----------

The `ebaz.xdc` file documents all available I/O on both the main
EBAZ4205 board and the above-mentioned expansion board.  I don't like
the idea of having to reproduce this for every project, so I have
taken steps to ensure that constraint errors are just warnings.  Hand
editing is also an option, though; you can just consider this a useful
reference guide.  I mean, if you want to adapt existing code, you'll
have to change the names, anyway.

Note that this does not include timing constraints.  For the free
tools in particular, there is no way to provide a common file. For
Vivado, the PLLs auto-create clocks, so it probably isn't necessary
for simple projects.  Really, though, I have no idea what I'm doing
timing-wise, and should probably do more research. Timing constraints
may well be the reason for inconsistently bad behavior of the HDMI
demo.

I guess placing comments after lines doesn't work as I would expect
(maybe that's not legal TCL?), because Vivado gives warnings about it.
I used to say "just ignore them", but I've gone ahead and put the
comments on the next line.

PLLs
----

I used to have a parameterized Verilog PLL wrapper, but somewhere
along the line one of the versions (maybe Xilinx, maybe ECP5) took way
too long to produce an answer with the free tools, so I switched to
using a generator program instead (the same algorithm, but subsecond
execution time instead of several minutes).  It's less convenient to
use, but adequate until I can figure out how to make a more optimal
Verilog version.  I can't use GHDL/VHDL or SystemVerilog/Surelog for
this, because the respective `yosys` plugins do not support generic
parameters, at least as far as I can tell at the time of writing.

`xc7pll.c` is the source code; just compile into an executable in the
usual way.  Probably the main useful feature missing still is the
ability to generate register sets for dynamic configuration.  This
will be important for dynamic HDMI resolution changing.  Or I could
just generate a fixed list of clocks and switch between them,
probably.  In fact, I will probably convert this into a library
routine that can be called fromm a processor-side utility to send the
paraemeters to the FPGA side.

Some example usages:

>       xc7-pll FCLKIN1=125 FCLKOUT0=25 CLKIN1name=fclk CLKOUT0name=clk25 >pll.v
>       xc7-pll -m modname=vidpll FCLKIN1=125 FCLKOUT1=371.25 FCLKOUT0=74.25 \
>               CLKIN1name=fclk CLKOUT0name=clk_pixel \
>               CLKOUT1name=clk_shift >vid-pll.v

Processor Interface
-------------------

`zynq-ps7.v` is a macro library to assist in using the PS7 component.
This macro library does not work properly in Vivado.  I moved the raw
semicolon out of the macro definitions, which makes it at least work
in System Verilog mode on 2022.2.  2017.2 doesn't like the macros no
matter what.  A workaround, which I used to do in my scripts, is to
use a preprocessor like `verilator -P -E`.  I initially implemented
automatic preprocessing in `fpgasynth`, but backed out because I
really don't like managing files this way. 

`ebaz-eth.v` is a macro library which uses `zynq-ps7.v` to easily add
raw ethernet forwarding.  `eth.v` is a sample top-level using these
macros, as well as (maybe) supplying the 25MHz clock for boards
missing the crystal oscillator.  I say maybe because my board has the
oscillator, so I haven't really tested if it works. To build:

>       ./fpgasynth -X z -o ebaz eth.v
>       ./prgebaz

Other
-----

`yosys` doesn't support full SystemVerilog by default, and the
`systemverilog` plugin I am aware of (using `Surelog`) does not
support parameterization, among other issues.  `ysv-supt.v` is a macro
library to assist in one of the issues porting SystemVerilog code to
yosys-native. See `demo/hdmi` for example usage.  While this fixes the
`yosys` array access errors, the HDMI code still does not work with
the free tool chain.

Processor Side
==============

Booting
-------

See <https://github.com/xjtuecho/EBAZ4205#reset-the-root-password-of-built-in-linux>
for decent instructions on how to boot from the pre-loaded flash.  In
summary, disable the bit-miner software and set up the network the way
you like it.

Technically, you don't need to configure the CPU to boot from SD by
default; instead, you can change the flash configuration.  However, I
have not had much success, so I have gone the hardware route.
Instead of moving the resistor to permanently change the default boot
mode, I patched a resistor to a non-connected pin on the JTAG header,
and use a jumper from that pin to either VCC or GND pins on the same
header to switch between boot modes).  Too bad Xilinx didn't feel the
need to fall back in case of failure, or such switching would not be
necessary.

While I have not been able to replace the first partition of the flash
(essentially a Xilinx `boot.bin` containing the FSBL, an initial
bitstream, and U-Boot), replacing the rest works fine.  My flash now
boots a 5.15 kernel (Xilinx v2022.2 from
<https://github.com/Xilinx/linux-xlnx>) and a device tree which
contains additional entries for LED and rear pushbutton support (at
least partially lifted from <https://github.com/blkf2016/ebaz4205>).

My first SD card boot used the image from
<https://github.com/blkf2016/ebaz4205>.  I still use the `boot.bin`,
but I have replaced/updated most other compoennts (see below).  In
particular, booting now uses U-Boot xilinx-v2022.2 (from
<https://github.com/Xilinx/u-boot-xlnx) and the kernel and device tree
mentioned above.

As implied by both of the previous paragraphs, I have yet to generate
a functional `boot.bin` myself.  Every attempt results in absolute
silence, as if there is a problem with the FSBL.  I have tried
building from the official sources at
<https://github.com/Xilinx/embeddedsw>, extracting the FSBL from
working `boot.bin`s (including the one on the default flash), building
with minor changes, building with major changes such as those from
<https://github.com/Halolo/ebaz4205-distro>, building older versions,
building newer versions, etc.  Nothing works.  I have compared the
`boot.bin` headers I generated (using the official `bootgen` utility
from Xilinx from <https://github.com/Xilinx/bootgen>), with no notable
differences.  I have no idea what's wrong, and haven't the means or
patience to deal with it any more.

Linux
-----

The version of Linux on the flash is old, but probably adequate for
most purposes.  It can be replaced, though.  In particular, I have
already replaced the kernel (in `nand-linux`, aka `/dev/mtdpart1`) and
the device tree (in `nand-device-tree`, aka `/dev/mtdpart2`).  The
device tree binary can simply be copied directly.  Since the default
U-Boot expects it, you will have to package the kernel using `mkimage`
first:

>       mkimage -A arm -O linux -T kernel -a 02080000 -e 02080000 -n Linux -C none -d zImage uImage

There is nothing special about the rest of the default partitions, so
I would recommend wiping them all out and starting from scratch.  The
only ones that matter are the first three, and if you somehow manage
to replace the first one (i.e., using a working `boot.bin` with a
different U-Boot), you can resize the first one and do whatever you
want with the rest of the flash.   My original intent was to dedicate
part of the flash for the FPGA to use, but it's probably easier to
just use the SD card for that.

For the SD card, and also to build the cross-compile toolchain,
kernels, U-Boot, and device trees for the above work, I currently use
`buildroot`.  I started with the configuration from
<https://github.com/blkf2016/ebaz4205>, but have redone most of it
from scratch, including some major updates.  I was not able to use the
plain versions of the kernel or U-Boot, or, for that matter, the
Xilinx git heads, so I used xilinx-v2022.2.  I think Xilinx forgot to
send some things upstream.  As mentioned above, the `boot.bin` is the
only thing I have yet to replace.  You can probably see the results of
my work in the `buildroot` subdirectory, but I haven't checked to see
if you can actually build everything from scratch using what's there,
or if I've forgotten something.  I may clear that up some day.

I tried building yocto/OpenEmbedded using
<https://github.com/Halolo/ebaz4205-distro>, but I failed.  The entire
ecosystem is infested with broken Python, so I have little enthusiasm
for fixing it.  The only thing of interest I tried to extract, namely
an alternate way to build the FSBL, I was not able to get running,
either, so it's a wash.

I have not tried PetaLinux or any of the raw Xilinx distros.  I really
don't care too much about what sort of Linux is running, just so I can
run my FPGA support programs on it.  In fact, I don't really need
Linux for that; in some cases, Linux just gets in the way (e.g. the
SPI API is awful, requiring the writing of a kernel device driver to
get anything done.  I also have to use `mem=` to reserve a contiguous
chunk of memory without resorting to a device driver).

FPGA Programming
----------------

The default flash kernel supports very easy programming, if you also
enable passwordless SSH access:

>       scp build-*/*.bit ebaz:/tmp && ssh -n ebaz "cat /tmp/*.bi? >/dev/xdevcfg"

Note that I copy to `/tmp` first so that temporary (or permanent,
depending on the bitstream) network loss won't cause partial bitstream
loss.

The kernel from <https://github.com/blkf2016/ebaz4205> does not
support sysfs firmware updates.  There is a way to update via the
device tree, but I don't want to mess with it.  Check the Xilinx wiki
for instructions on how to do this.  Since I don't want to encourage
this, I won't even give you the link.  Look for it yourself.

Instead, I use a kernel which *does* support sysfs firmware updates.
It's still not as easy to do an update as with the old kernels, but
it's much easier than without.  First, you need to format your
bitstream using `bootgen`; I have updated `fpgasynth` to do this
automatically.  The resulting file will generally have a `.bin`
extension, rather than `.bit`.  The next step is to place this file
under `/lib/firmware` on the ebaz.  I do this by creating soft links
to `/root` and `/tmp`, so that I can copy the bitstream to either
directory for upload.  Then, just echo the path (minus
`/lib/firmware`) into the sysfs file.  I have included my `prgebaz`
script, which works with either the original or new programming style
(but not the device tree method).  If you want to use it, you'll
probably have to at least change the target host name.

Demo Program
============

Against my better judgment, I have included a demo that I use to
exercise the board(s).  As you might expect, it's in the `demo`
subdirectory.  It currently exercises LEDs, pushbuttons, the .100
expansion connector (H4), speaker, LCD, USB UART (echos @115200),
ethernet pass-through, and HDMI.  There seems to be an issue with the
LCD back light, even though another demo I have (the ulx3s-misc
collatz example ported to the ebaz) seems to work, at least in that
regard.  Parts were taken from other projects which were independently
verified as working, to eliminate possible errors on my part (but I
still managed to sneak an error into the UART code):

 - LCD support: <https://github.com/emard/ulx3s-misc> spi_display example

 - HDMI with audio support: <https://github.com/hdl-util/hdmi> with
   some modifications by me.  It's System Verilog, not supported by
   `yosys` directly.  I will (re-)port it to something more
   `yosys`-friendly at some point, but I can't use f4pga to make
   working HDMI, anyway, so I've only made minor modifications.

- UART: <https://github.com/jamesbowman/swapforth> `j1b` (with broken
  merge in progress of `j1a`/`j1b` by me)

These include minor patches to fix compilation issues.

My grumbling; feel free to ignore
=================================

Probably my biggest disappointment is that I had to resort to
commercial tools for this.  I was under the impression that the free
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

So, my question went from "what parts are fully supported by the free
tools" to "what parts are supported well enough by the free tools" to
"what free of charge vendor tools are usable".  The answer to the
former two questions is apparently "none": the free tools are not
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
from elsewhere, although the `yosys` plugins are essentially part of
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
would be no clocks (or ethernet pass-through, which makes programming
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
===================

As with all of my software in the past few years, everything in this
repository is in the Public Domain, except as noted for specific files
(i.e., files I've borrowed from other projects).   If you find I've
violated anybody else's licenses with this inclusion, let me know and
I'll remove it, and avoid it at all costs in the future.
