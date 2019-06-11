\ENCODING=ISO-8859-1
\Problem name: CLSP-RM_Master

Minimize
 obj: 10000.0 local_art_of_capConstr_2 + 10000.0 local_art_of_capConstr_3
      + 10000.0 local_art_of_sp_lb_3 + 10000.0 local_art_of_sp_lb_2
      + 10000.0 local_art_of_sp_ub_3 + 10000.0 local_art_of_sp_ub_2
      + 10000.0 local_art_of_capConstr_1 + 100000.0 global_pos_art_var
      + 100000.0 global_neg_art_var
Subject To
 capConstr_2 :  -1.0 local_art_of_capConstr_2 - 1.0 global_neg_art_var <= 9.0
 capConstr_1 :  -1.0 local_art_of_capConstr_1 - 1.0 global_neg_art_var <= 9.0
 capConstr_3 :  -1.0 local_art_of_capConstr_3 - 1.0 global_neg_art_var <= 9.0
 sp_ub_2 :  -1.0 local_art_of_sp_ub_2 <= 1.0
 sp_ub_3 :  -1.0 local_art_of_sp_ub_3 <= 1.0
 sp_lb_2 :  + 1.0 local_art_of_sp_lb_2 >= 0.0
 sp_lb_3 :  + 1.0 local_art_of_sp_lb_3 >= 0.0
Bounds
 0 <= local_art_of_capConstr_2 <= 1.0e100
 0 <= local_art_of_capConstr_3 <= 1.0e100
 0 <= local_art_of_sp_lb_3 <= 1.0e100
 0 <= local_art_of_sp_lb_2 <= 1.0e100
 0 <= local_art_of_sp_ub_3 <= 1.0e100
 0 <= local_art_of_sp_ub_2 <= 1.0e100
 0 <= local_art_of_capConstr_1 <= 1.0e100
 0 <= global_pos_art_var <= 1.0e100
 0 <= global_neg_art_var <= 1.0e100
End
