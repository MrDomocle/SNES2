# Generates a character mapping that maps space to 0, comma to 1, the alphabet in CAPS to 2-27 and NULL to 28
f = open("title/charmap.inc", "w")
f.writelines(f".charmap 32,1\n")
f.writelines(f".charmap 44,2\n")

translated_i = 3
for i in range(65,91):
    f.writelines(f".charmap {i},{translated_i}\n")
    translated_i += 1

f.close()