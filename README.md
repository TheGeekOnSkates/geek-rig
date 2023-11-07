# TO-DOs

## Phase 1: Finish terminal input/output stuff

https://www.perplexity.ai/search/517beb33-4bbf-4292-b64d-fa734a9b9f16?s=u

* A bonus would be a way to get the terminal size - 2 bytes well worth it
* Double bonus if I can get the character under the cursor
* Hat trick if I can get the text colors/attributes too!

Looks like the AI may have scored the hat trick - needs more work


## Phase 2: Finish system commands from 6502-land

* Now that it works with `system()`, look into `fork` and `execve` instead; it would be awesome to be able to share data between processes (text output, controller state, etc.) and not just return values.
* If it does that... compile this sucker on Termux just to see if I still can!  This would be so cool... if the stupid locked-down world of Android will allow it. :-D

## Phase 3: Write an emulated disk drive

It should use plain old Linux files/folders, cuz at least for now, this thing only runs on Linux.  Here's where the RAM "banking" thing might come up, so maybe it can save bigger files... I have all kinds of ideas on how this could work, but that's far enough away that I just don't want to go there right now. :-)

## Phase 4: Build a kernal

Yes, I'm spelling it like Commodore did - it's more phonetically correct (lol).  Like I'm sure there will be some features I'll be reusing like crazy.  Clearing the screen, getting/setting the cursor position, setting the foreground and background colors etc.

## Phase 5: Try to get cc65 to target the Geek-Rig

I'm decent at 6502 Assembly; I'm way better at C (lol).  It would be awesome to be able to code for the Geek-Rig in C, with a nice library that I'm gonna build around the kernal.  Lord willing, when I get here, it'll be time to...

## Phase 6: Build an operating system

At this point, I'll probably be looking at either a BASIC, a Forth, or a shell like DOS or Bash.  Kinda leaning toward a Forth, just cuz #Forth!  But then again I might not be able to do any better than just an Assembly monitor.  We'll see I guess.

## Phase 7: Write a manual and call it done

Lord willing, when I get here, I'll have what I wanted to build: a lightweight, fairly portable, 6502-in-a-terminal.  Time to tell my fellow geeks about it!  I'm gonna build more software for the Geek-Rig, but wouldn't it be cool if some other people did too?  This could be a lot of fun for a lot of people, maybe even be useful beyond just games.

## Phase 8: Build games and other fun stuff

* Surely, this thing can do a Pong clone - my last attempt at this project (which tried to refresh the entire screen with every cycle) ran a nice title screen for a Snake clone.
* Maybe port one of my text adventures to the Geek-Rig
* I'd kind of like a text editor, or some other not-game software.  Maybe a Bible study tools (cuz I always use my tablet on Sundays lol)
* And I mean if it can do Pong... why not Breakout?  Why not Space Invaders?  Heck, why not a platformer or maze game like Donkey Kong or Pac-Man? :-)


--------------------------------------------------------------------------

# The Geek-Rig: An 8-bit VM for the Linux terminal

## Overview

The Geek-Rig is software that works like a brand new 8-bit computer.  I've heard all kinds of names for projects like this, ranging from "fantasy emulator" to "emulator of a system that doesn't exist" to "virtual machine".  I kind of like the idea of calling it a VM, cuz that really is the most accurate and least wordy description.  Anyway, it runs on an emulated 6502, the same processor as most 8-bit things ran on, and designed to run inside a Linux terminal.  I expect its main purpose will be for games, though of course it's not limited to just that.

## Why the Linux terminal?

* **Performance:** My goal is to create something that works on even very low-spec computers.  I have a Raspberry Pi 1 B+.  Yeah, *that* low-end.  256 *megabytes* of RAM, single-core CPU, probably something most people wouldn't even want spend money on.  But that little device runs a desktop - so this bad boy's gonna *zoom* on the Pi!  Or at least, that's the plan. :)
* **Convenience:** My daily driver laptop is running Linux.  And so is the Pi.  And so is my Android tablet (well, Termux).  So systems like Windows, Haiku, BSDs, Macs etc. are out (for now).  Obviously, someday I'd love to port it to other platforms, but that probably won't happen anytime soon.
* **Capabilities:** Modern terminals are about as powerful as a lot of classic computers.  Most can display 16 colors, draw text anywhere on the screen, and even do crazy stuff like italics, underline and emojis.
* **Fun:** Probably the most important reason for doing any open-source project. :)

## Why build a new system?  Why not a ____ emulator?

At first, I *wanted* to build an emulator.  An emulator that runs in console mode sounded awesome!  So I got to messing around.  The Commodore PET was my best bet (since you couldn't change what characters looked like on it, and it had no sprites) but the Linux terminal is short one row.  Not to mention, cool-retro-term and xterm and others have zoom, so there might be less than 40 (or more than 80) visible characters per row.  I also thought about maybe using pixel-drawing characters to create a sort of bitmap. If that worked, it would be possible to create something even better, like a VIC-20.  But as I played with updating the entire screen using something like that, I found it kinda flickered a bit, and not in a fun CRT-like way (not to mention the different sizes and other settings I just talked about).  So I ultimately decided that the Linux console is not exactly ideal for emulators.  Not unless I was going to write to the frame buffer directly, which is more work than I have time for. :)

## What does "geek-rig" mean? :D

I'd call it the Jerry-Rig, but my name isn't Jerry. :)

In case you don't get the joke, sometimes when people try something iffy, that they don't expect to work (and probably shouldn't), they call it "Jerry-rigging" (there's also the expression N{not-a-nice word}-rigging, which IMO is not cool).  I'm a geek, and I'm trying to "rig" a 6502 for the Linux terminal, so, it's a geek-rig.  I actually use the expression "geek-rig" just in general, to refer to anything like that.

## Project plan

### The Geek-Rig 4000

For the "original model", the goal is simple: build something that works in the terminal, runs 6502 machine code, and is fun to tinker with.  The finished system will have:

* 4 KB of RAM (technically 4096 bytes, but 4000 sounds better)
* A monochrome display with up to 40 by 24 characters
* All 256 PETSCII characters (both character sets)
* A "disk drive" for reading/writing files
* A couple nice little extras, like a random number generator and a timer
* Mouse support - IMO the mouse is the new "paddle"
* A couple little games
* A little text editor

### The Geek-Rig 8000

If the 4000 works how I think it will, even on the Pi 1 and/or Termux, then it all comes down to pushing the limits to make the system as fun as possible.  Some things I'd like the 800 to have include:

* Up the RAM to 8 KB
* Go up to the full 80 columns of text
* Add color
* I can't change what the characters look like, but I could have a way to change *which* characters are available.  That way it could support characters that weren't in PETSCII - foreign letters, more box-drawing characters, emojis etc.
* Rework the text editor I built for the 4000 as an Assembly language monitor, or maybe a Forth (or both?).  At this point we're starting to get out of the realm of what I know I can do with my after-hours schedule and into pipe-dreaming, lol).
* Upgrade the games to take advantage of the better specs
* Build another game or two

### The Geek-Rig 16000

If (and Lord willing, *when*) I reach this point, what I have will be starting to look more like how I envisioned this system to work.  Some features I have in mind for this phase include:

* Up the RAM to 16 KB
* Add controller support - what kind of game system doesn't have that? :)
* Improve the disk drive so it can read from flash drives, micro SD cards, etc.  Might require linking libusb or something, and idk if/how it would work in Termux, but I like the idea anyway. :)
* Add sound (probably gonna have to link SDL2_mixer, cuz Linux' current options for audio kinda suck ice... sox maybe?).  Probably just a simple beeper speaker, maybe two if I can figure out how.
* Build another game, or maybe a Forth if I haven't already

### The Geek-Rig 32000

Assuming I haven't pushed my little Raspberry Pi to the max, it's time to:

* Up the RAM to 32K
* Add a better sound system - maybe like the VIC-20 or the NES.
* Start looking at a BASIC.  It probably won't be as robust as I hope Breakaway BASIC will be someday.  If I can figure out how the 8-Bit Guy geek-rigged Commodore's BASIC, maybe I can get it to run my own port!
* Add a speech synthesizer.  Cuz audio gamers will probably need/want that (and if I ever port to Windows, I can use Tolk instead of espeak, which is awesome).
* Add internet access - something like wget - download {url} and insert into RAM.

### The Geek-Rig 64000

At this point it's all about polishing and pushing things to the max:

* Up the RAM to 64K, and investigate the possibility of "banking" (probably just having 2 bytes for the bank number, and then 65536 different "banks" for blocks of memory - I'll need to research that tho)
* A sound system comparable to the Commander X16 - or at least the C64 :)
* A better speech synthesizer (or at least one with more options, like the rate/pitch/voice/etc.)
* At this point, it's gotta have a BASIC, with disk drive commands and probably some others I haven't thought of yet.
* Anything else I think it needs, and games!  :)
