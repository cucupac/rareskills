holds = True
for n in range(1, 101):
    for a in range(100):
        for b in range(100):
            if not a * b % n == a % n * b % n:
                holds = False

print("holds:", holds)
