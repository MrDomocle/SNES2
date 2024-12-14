#!/bin/bash
ca65 --cpu 65816 -o main.o main.asm -l main.list && ld65 -C memmap.cfg main.o -o game.sfc