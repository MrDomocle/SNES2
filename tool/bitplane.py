# Convert decimal-indexed to 4bpp bitplanes
arr = []
print("Enter image in decimal:")
for i in range(8):
  arr.append([])
  line = input()
  for c in line:
    n = bin(int(c))[2:]
    if len(n) < 4:
        d = 4 - len(n)
        for j in range(d):
            n = "0" + n
    arr[i].append(n)
print("===BP0-3===")
for bp in range(0,3):
    for r in arr:
        row = ""
        for c in r:
            row += c[3-bp]
        print(row)