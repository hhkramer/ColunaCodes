Minimize
obj: x_1_1 + x_1_2 + x_1_3 + 10 y_1_1 + 10 y_1_2 + 10 y_1_3 + s_1_1 + s_1_2 + s_1_3 - 10000
Subject to
x_1_1 - s_1_1 = 2
s_1_1 + x_1_2 - s_1_2 = 4
s_1_2 + x_1_3 - s_1_3 = 3
x_1_1 - 10000 y_1_1 <= 0
x_1_2 - 10000 y_1_2 <= 0
x_1_3 - 10000 y_1_3 <= 0
Bounds
0 <= x_1_1 <= 1000000
0 <= x_1_2 <= 1000000
0 <= x_1_3 <= 1000000
0 <= s_1_1 <= 1000000
0 <= s_1_2 <= 1000000
0 <= s_1_3 <= 1000000
0 <= y_1_1 <= 1
0 <= y_1_2 <= 1
0 <= y_1_3 <= 1
Generals
y_1_1 y_1_2 y_1_3
End
