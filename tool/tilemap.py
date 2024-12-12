import imageio.v3 as iio
# Convert image to tilemap
# Every colour is a different tile
# Remember what colour you used in the image for each tile type,
# then fill the tile's address in the end (tn assembler var definitions)

im = iio.imread("gfx/map.png")
mode = "bg"
f = open("gfx/map_buffer.txt", "w")
pal = ["transparent"]
indexed = []

i = 0
for row in im:
    indexed.append([])
    for c in row:
        if c[3] != 0: # if not transparent
            r = hex(c[0])[2:]
            g = hex(c[1])[2:]
            b = hex(c[2])[2:]
            # add leading zeroes if needed
            for j in range(len(r),2):
                r = "0"+r
            for j in range(len(g),2):
                g = "0"+g
            for j in range(len(b),2):
                b = "0"+b
            chex = r+g+b
            if chex not in pal:
                pal.append(chex)
            indexed[i].append(pal.index(chex))
        else:
            indexed[i].append(0)
    i += 1
f.writelines(".segment \"CODE\"\nmapstart:\n")
blank_line = False
blank_count = 0
last = 0
for row in range(0,len(indexed)):
    for tile in range (0,len(indexed[row])):
        if blank_line:
            if indexed[row][tile] != 0: # end of blank line
                f.writelines(f".repeat {blank_count}\n.word t0\n.endrepeat\n")
                blank_line = False
            elif last == 0: # inside blank line
                blank_count += 1
            if row == len(indexed)-1 and tile == len(indexed[row])-1: # last tile - write what we have
                f.writelines(f".repeat {blank_count}\n.word t0\n.endrepeat\n")
                blank_line = False

        elif indexed[row][tile] == 0: # start of blank line
            blank_line = True
            blank_count = 1
        
        if not blank_line: # not blank
            f.writelines(f".word t{indexed[row][tile]}\n")
        last = indexed[row][tile]

f.writelines("mapend:\n")
for i in range(0,len(pal)):
    f.writelines(f"t{i} = ; #{pal[i]}\n")