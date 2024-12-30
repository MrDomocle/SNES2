import imageio.v3 as iio
# Convert image to VRAM image
# Doesn't do anything to the palette, just says what it is.
# It's up to the artist to make sure the palette is correct

im = iio.imread("gfx/src/letter.png")
mode = "letter"
f = open("gfx/src/buffer_letter.txt", "w")
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
            # add trailing zeroes if needed
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
# iterate in 8x8 tiles
for y in range(0,im.shape[0]-7,8):
    for x in range(0, im.shape[1]-7,8):
        arr = []
        for row in range(0,8):
            arr.append([])
            for c in range(0,8):
                n = bin(indexed[row+y][c+x])[2:]
                for i in range(len(n),4):
                    n = "0" + n
                arr[row].append(n)
        f.writelines(f"; {x//8},{y//8}----------------\n")
        for r in arr:
            for bp in range(0,2):
                row = ".byte %"
                for c in r:
                    row += c[3-bp]
                f.writelines(row + "\n")
        for r in arr:
            for bp in range(2,4):
                row = ".byte %"
                for c in r:
                    row += c[3-bp]
                f.writelines(row + "\n") 
    # skip to next VRAM row
    f.writelines(f";=====================ROW END==================\n")
    f.writelines(f".res 8*4*(16-{im.shape[1]//8})\n")
        

f.writelines(f"Palette: {len(pal)} colours" + "\n")
f.writelines(".word $0000 ; transparency" + "\n") # colour 0 always transparent
for i in range(1,len(pal)):
    rs = "0x"+pal[i][0:2]
    gs = "0x"+pal[i][2:4]
    bs = "0x"+pal[i][4:6]
    
    r = int(rs,16)
    g = int(gs,16)
    b = int(bs,16)

    r = r >> 3
    g = g >> 3
    b = b >> 3

    rs = bin(r)[2:]
    gs = bin(g)[2:]
    bs = bin(b)[2:]

    for j in range(len(rs),5):
        rs = "0"+rs
    for j in range(len(gs),5):
        gs = "0"+gs
    for j in range(len(bs),5):
        bs = "0"+bs

    col = ".word %0"+bs+gs+rs
    
    f.writelines(f"{col} ; #{pal[i]}\n")
f.close()