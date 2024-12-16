# Space shooter game for SNES
This is my first major project for the SNES, written in assembly using ca65.  
It's written from scratch - I didn't use libraries that add a lot of functionality. This includes the tools I used to convert graphics, which I wrote myself in python (you can find them in the tool/ directory)  

* **DPAD** - move around
* **B** - shoot
* **A** - accelerate
## How I made this
I always wanted to make a game for the SNES/NES, inspired by YouTube videos about Mario 3 TASs and other explanations of very low-level computing concepts on those consoles.  
Now I decided to look up a guide on SNES game creation to make my own game. The most challenging part was beginning - I've never wrote assembly before this, and many concepts (like SNES's 16- and 8-bit modes) were very foreign to me. Later on, though, I kinda got into this and realised assembly isn't actually as hard as I thought.  
Thanks to [Alex Ren](https://github.com/qcoral) for the background graphics - I have 0 experience in pixel art, so at least something in the game looks good :)
## Building
* Get ca65 and ld65 binaries on your PATH
* Run build.sh from the repo's root using bash (I work on Windows and use Git bash)
* Builds game.sfc, and also main.o (object file) and main.list (listing with addresses in memory)

## Resources I used
* Wesley Aptekar-Cassels' guide:  
https://blog.wesleyac.com/posts/snes-dev-1-getting-started  
* Retro Game Mechanics Explained's SNES hw features series  
https://www.youtube.com/playlist?list=PLHQ0utQyFw5KCcj1ljIhExH_lvGwfn6GV
* The docs to ca65, the 6502/65816 assembler I use  
https://www.cc65.org/doc/ca65.html  
* Console register docs (love the formatting in this one)  
https://wiki.superfamicom.org/registers  