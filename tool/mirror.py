# mirrors decimal indexed image
arr = []
print("Enter image:")
for i in range(8):
  line = input()
  arr.append(line[::-1])
print("=====")
for l in arr:
    print(l)