Minimize
obj: 10000 artvar_1 + 10000 artvar_2
Subject to
capConstr_1: <= 9
capConstr_2: <= 9
capConstr_3: <= 9
convexityConstr_1: artvar_1 >= 1
convexityConstr_2: artvar_2 >= 1
Bounds
0 <= artvar_1 <= 1
0 <= artvar_2 <= 1
End
