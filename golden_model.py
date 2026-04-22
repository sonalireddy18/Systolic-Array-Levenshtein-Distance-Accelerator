def single_row_distance(char_a, string_b):
n = len(string_b)


prev_row = list(range(n + 1))
curr_row = [0] * (n + 1)

curr_row[0] = prev_row[0] + 1

for j in range(1, n + 1):
    cost = 0 if char_a == string_b[j - 1] else 1

    curr_row[j] = min(
        prev_row[j] + 1,
        curr_row[j - 1] + 1,
        prev_row[j - 1] + cost
    )

print("Previous Row:", prev_row)
print("Current Row :", curr_row)
print("Final Output:", curr_row[n])

return curr_row[n]


if __name__ == "__main__":
    char_a = 'K'
    string_b = "SITT"

    result = single_row_distance(char_a, string_b)
    print("Expected Distance =", result)




