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
for row in range(0,len(indexed)):
    for tile in range (0,len(indexed[row])):
        f.writelines(f".word t{indexed[row][tile]}\n")

f.writelines("mapend:\n")
for i in range(0,len(pal)):
    f.writelines(f"t{i} = ; #{pal[i]}\n")