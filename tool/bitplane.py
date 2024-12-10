import imageio.v3 as iio
im = iio.imread("gfx/img.png")
pal = []
indexed = []

i = 0
for row in im:
    indexed.append([])
    for c in row:
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
    i += 1

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
            
        
                
        for r in arr:
            for bp in range(0,2):
                row = ".byte %"
                for c in r:
                    row += c[3-bp]
                print(row)
        for r in arr:
            for bp in range(2,4):
                row = ".byte %"
                for c in r:
                    row += c[3-bp]
                print(row) 
    print("============VRAM row end=============")

print("Palette:")

for i in range(len(pal)):
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

    #print(rs,gs,bs)

    for j in range(len(rs),5):
        rs = "0"+rs
    for j in range(len(gs),5):
        gs = "0"+gs
    for j in range(len(bs),5):
        bs = "0"+bs

    col = ".word %0"+bs+gs+rs
    
    print(col)