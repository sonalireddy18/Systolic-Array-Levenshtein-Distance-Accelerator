# ==========================================================
# Python Golden Model for Levenshtein Distance
# ----------------------------------------------------------
# This script computes the Edit Distance between two strings
# using Dynamic Programming.
#
# Purpose:
# - Acts as a software reference model
# - Used to verify Verilog hardware outputs
# - Produces expected ("golden") results
#
# Edit Distance Operations:
# 1. Insertion
# 2. Deletion
# 3. Substitution
# ==========================================================


def edit_distance(s1, s2):

    # ------------------------------------------------------
    # Lengths of input strings
    # ------------------------------------------------------
    m, n = len(s1), len(s2)

    # ------------------------------------------------------
    # DP Table Creation
    #
    # Size:
    #   (m+1) x (n+1)
    #
    # dp[i][j] represents:
    # Minimum edits needed to convert:
    #   s1[0:i] -> s2[0:j]
    # ------------------------------------------------------
    dp = [[0] * (n + 1) for _ in range(m + 1)]



    # ======================================================
    # Initialize First Column
    # ------------------------------------------------------
    # Converting string -> empty string
    # Requires deletions
    # ======================================================
    for i in range(m + 1):
        dp[i][0] = i



    # ======================================================
    # Initialize First Row
    # ------------------------------------------------------
    # Converting empty string -> target string
    # Requires insertions
    # ======================================================
    for j in range(n + 1):
        dp[0][j] = j



    # ======================================================
    # Fill DP Table
    # ======================================================
    for i in range(1, m + 1):

        for j in range(1, n + 1):

            # --------------------------------------------------
            # Substitution Cost
            #
            # cost = 0 if characters match
            # cost = 1 if characters differ
            # --------------------------------------------------
            cost = 0 if s1[i - 1] == s2[j - 1] else 1


            # --------------------------------------------------
            # DP Recurrence Relation
            #
            # Minimum of:
            #
            # 1. Deletion
            # 2. Insertion
            # 3. Substitution
            # --------------------------------------------------
            dp[i][j] = min(

                # Delete character
                dp[i - 1][j] + 1,

                # Insert character
                dp[i][j - 1] + 1,

                # Substitute character
                dp[i - 1][j - 1] + cost
            )



    # ======================================================
    # Final Edit Distance
    # Located at bottom-right corner of DP table
    # ======================================================
    return dp[m][n]



# ==========================================================
# Test Cases
# ----------------------------------------------------------
# Format:
# (String_A, String_B)
# ==========================================================
tests = [

    ("KITT", "SITT"),
    ("BOOK", "BACK"),
    ("FAST", "FAST"),
    ("CHAT", "CATS"),
    ("COOL", "POOL")
]



# ==========================================================
# Execute Golden Model
# ==========================================================

print("\n--- GOLDEN MODEL REFERENCE ---")

for s1, s2 in tests:

    print(
        f"Strings: {s1}, {s2} | "
        f"Expected Distance: {edit_distance(s1, s2)}"
    )

print("------------------------------\n")
