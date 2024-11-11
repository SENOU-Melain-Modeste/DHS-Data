clear all
set mem 600m
set more 1
set maxvar 15000

****Benin
cd "C:\Users\peprc\Downloads\PAPIER_EDS\revision_papier1_HealthSystem\Merged Data set WAEMU\"

use BJIR71FL2017, replace

gen pays = 1
label define pays_label 1 "Benin"
label values pays pays_label

ta v130
ta v130, nol
recode v130 (10 = 0 " No religion")(3 = 1 " Muslim")(4/8 = 2 "Christian")(1 2 9 = 3 "Others"), gen(REL)
tab REL
order v000 v001 v005 v024 v025 v208 m1a_1 m1_1 b19_01 m1d_1 v218 m57m_1 m57e_1 m57f_1 m57g_1 m57h_1 m57m_1 m57n_1 ///
m57r_1 m57x_1 /*s124*/ v106 v701 m19_1 b4_01 v447a v025 v151 v152 b4_01 v025 v115 /*s125*/ v190 v191 v190a ///
v745b v133 v715 v743a v743b v743d v743f v157 v158 v159 v384a v384b v384c v384d REL pays

ta v024
ta v024, nol
save BJIR71FL2018order, replace


****Guinée
use GNIR71FL, replace
gen pays = 2
label define pays_label 2 "Guinée"
label values pays pays_label
ta v130  // muslim ==1  Christian ==2 Animist ==3 No religion ==4
ta v130, nol
recode v130 (4 = 0 " No religion")(1 = 1 " Muslim")(2 = 2 "Christian")(3 = 3 "Others"), gen(REL)


order v000 v001 v005 v024 v025 v208 m1a_1 m1_1 b19_01 m1d_1 v218 m57m_1 m57e_1 m57f_1 m57g_1 m57h_1 m57m_1 m57n_1 ///
m57r_1 m57x_1 /*s124*/ v106 v701 m19_1 b4_01 v447a v025 v151 v152 b4_01 v025 v115 /*s125*/ v190 v191 v190a ///
v745b v133 v715 v743a v743b v743d v743f v157 v158 v159 v384a v384b v384c v384d pays
ta v024
ta v024, nol
save GNIR71FL2018order, replace



****Mali
use MLIR7AFL, replace

gen pays = 3
label define pays_label 3 "Mali"
label values pays pays_label
ta v130 
ta v130, nol 

recode v130 (8 = 0 " No religion")(1 = 1 " Muslim")(2/5 = 2 "Christian")(6 96 = 3 "Others"), gen(REL)


order v000 v001 v005 v024 v025 v208 m1a_1 m1_1 b19_01 m1d_1 v218 m57m_1 m57e_1 m57f_1 m57g_1 m57h_1 m57m_1 m57n_1 ///
m57r_1 m57x_1 /*s124*/ v106 v701 m19_1 b4_01 v447a v025 v151 v152 b4_01 v025 v115 /*s125*/ v190 v191 v190a ///
v745b v133 v715 v743a v743b v743d v743f v157 v158 v159 v384a v384b v384c v384d REL pays
ta v024
ta v024, nol
save MLIR7AFL2018order, replace

****Senegal
use SNIR81FL, replace
gen pays = 4
label define pays_label 4 "Senegal"
label values pays pays_label
ta v130 
ta v130, nol

recode v130 (4 = 0 " No religion")(1 = 1 " Muslim")(2 = 2 "Christian")(96 = 3 "Others"), gen(REL)

order v000 v001 v005 v024 v025 v208 m1a_1 m1_1 b19_01 m1d_1 v218 m57m_1 m57e_1 m57f_1 m57g_1 m57h_1 m57m_1 m57n_1 ///
m57r_1 m57x_1 /*s124*/ v106 v701 m19_1 b4_01 v447a v025 v151 v152 b4_01 v025 v115 /*s125*/ v190 v191 v190a ///
v745b v133 v715 v743a v743b v743d v743f v157 v158 v159 v384a v384b v384c v384d REL pays
ta v024
ta v024, nol

save SNIR81FL2018order, replace


****Appending
use BJIR71FL2018order, clear

append using GNIR71FL2018order MLIR7AFL2018order SNIR81FL2018order
tab pays
ta v024
ta REL

label define pays 1 "Benin" 2 "Guinée" 3 "Mali" 4 "Senegal"
label values pays pays

clonevar age = v012
bysort pays : sum age
****br  all
ed v000 v001 v005 v024 v025 v208 m1a_1 m1_1 b19_01 m1d_1 v218 m57m_1 m57e_1 m57f_1 m57g_1 m57h_1 m57m_1 m57n_1 ///
m57r_1 m57x_1 /*s124*/ v106 v701 m19_1 b4_01 v447a v025 v151 v152 b4_01 v025 v115 /*s125*/ v190 v191 v190a ///
v745b v133 v715 v743a v743b v743d v743f v157 v158 v159 v384a v384b v384c v384d age REL pays 



save Data2018Waemu, replace



