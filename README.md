# Space shooter game for SNES
This is my first project for the SNES, written in assembly using ca65.  
It's written from scratch - I didn't use libraries that add a lot of functionality. This includes the tools I used to convert graphics, which I wrote myself in python (you can find them in the `/tool/` directory)  

* **DPAD** - move around  
* **B** - shoot  
* **A** - move faster  
* Win if you get `420,000` points! (send me screenshots if you do lol)  

You can get the game ROM on the Releases page  
Not tested on real hardware, but works on Mesen and bsnes.  
Snes9x does **NOT** work - and seemingly any other emulator that cares about the ROM header.  
## How I made this
I always wanted to make a game for the SNES/NES, inspired by YouTube videos about Mario 3 TASs and other explanations of very low-level computing concepts on those consoles.  
Now I decided to look up a guide on SNES game creation to make my own game. The most challenging part was beginning - I've never wrote assembly before this, and many concepts (like SNES's 16- and 8-bit modes) were very foreign to me. Later on, though, I kinda got into this and realised assembly isn't actually as hard as I thought.  
Thanks to [Alex Ren](https://github.com/qcoral) for the background graphics - I have 0 experience in pixel art, so at least something in the game looks good :)
## Building
* Get ca65 and ld65 binaries on your PATH.
* Run `./build.sh` in bash.
* You will find `game.sfc`, `main.o` and `main.list` in the repo root directory.  
## Graphics tools
The game uses BG mode 1 (4bpp) layers 1 (titles) & 2 (background).  
I wrote my own python scripts to convert .png files to SNES bitplanes, tilemaps and palettes. Those are in the `/tools/` directory and require the `imageio` library (except `charmap.py`).  
* `bitplane.py` is used to convert .png files into bitplanes with the pallette appended at the end (used for `/gfx/charset.asm`, `/gfx/palette.asm`). Doesn't do anything to fit in the 16-colour limit, so you have to keep track of your palette yourself.  
* `tilemap.py` converts a .png file to a tilemap (used for `/gfx/tilemap.asm`). Every colour in the .png represents a different tile, and you will need to set the attribute bytes for each one yourself at the end of the output file.  
* `charmap.py` generates a character map (used for `/gfx/charmap.inc`) for the compiler that's different from ASCII (since my font isn't full ascii and I need to use different offsets).  

## Resources I used
* Wesley Aptekar-Cassels' guide:  
https://blog.wesleyac.com/posts/snes-dev-1-getting-started  
* Retro Game Mechanics Explained's SNES Hardware Features series (that's where the images from `/reference/` come from)  
https://www.youtube.com/playlist?list=PLHQ0utQyFw5KCcj1ljIhExH_lvGwfn6GV
* Hardware register docs  
https://wiki.superfamicom.org/registers  
* 65c816 opcode list (very technical and useful)  
http://www.6502.org/tutorials/65c816opcodes.html 
* The docs to ca65, the assembler I used  
https://www.cc65.org/doc/ca65.html  