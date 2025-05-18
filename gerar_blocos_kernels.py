M, N = 7, 7
labels = [f"$k{i}{j}" for i in range(M) for j in range(N)]
br_table_line = " ".join(labels + ["$fallback"])
print(f"br_table {br_table_line}")

for i in range(M):
    for j in range(N):
        label = f"$k{i}{j}"
        print(f"(block {label}\n  global.get {label}\n  br $end\n)")
