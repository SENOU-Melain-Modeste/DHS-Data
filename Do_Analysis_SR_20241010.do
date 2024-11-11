*******
clear all
set mem 600m
set more 1
set maxvar 15000

cd "C:\Users\peprc\Downloads\PAPIER_EDS\revision_papier1_HealthSystem\Merged Data set WAEMU\
use DATA_WAEMU_cleaned_SR, clear 
log using ResultsSR_Revising, text replace
encode v000, gen(country)
*****All countries
recode ParticipationDecision (2 1 = 1 ), gen(AutoDecision)
replace sex_enf = 0 if sex_enf==2
*****Descriptive statistics

bysort country : sum PoidsEnf_Kilo ttprotect age_Mother sex_enf Sex_hhhead i.Mother_educ ///
i.Husband_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal i.country

*************** OLS
svy, vce(linearized): regress lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf ///
 /*Sex_hhhead i.Mother_educ*/ Residence /*i.Wealth_index_qui time_water num_liv_chil antenatal ///
 i.country*/ if PoidsEnf_Kilo>0 
outreg2 using all_MCO_rob_ttprotect.doc, dec(3) ctitle(OLS) replace
outreg2 using all_results_all.doc, dec(3) ctitle(OLS) replace
outreg2 using all_results_Comball_estima.doc, ctitle(OLS) dec(3) replace


****Selection equation
generate PoidsEnf_Kilo_s = (PoidsEnf_Kilo < .)

***********************************Heckman I1********************************************

heckman lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf /*Sex_hhhead*/ ///
i.Mother_educ Residence /*i.Wealth_index_qui time_water num_liv_chil antenatal i.country*/, ///
select(PoidsEnf_Kilo_s =  ttprotect lnage_Mother lnage_mMother_sq sex_enf /*Sex_hhhead*/ i.Mother_educ /// 
i.Husband_educ Residence i.Wealth_index_qui AutoDecision time_water /*num_liv_chil antenatal i.country*/) ///
mills (mills1_ttprotect)
outreg2 using all_Heckman1_ttprotect.doc, dec(3) ctitle(Heckman) replace
outreg2 using all_results_Comball_estima.doc, dec(3) ctitle(Heckman) append


*****Prediction 

probit ttprotect lnage_Mother lnage_mMother_sq /*sex_enf Sex_hhhead time_water*/  i.Mother_educ ///
i.Husband_educ Residence i.Wealth_index_qui AutoDecision /*num_liv_chil antenatal i.country*/
outreg2 using all_prob_ttprotect.doc, dec(3) replace

/*outreg2 using results_Comball_estima.doc, dec(3) ctitle(Heckman) append*/

predict ProbitPredit_ttprotect, xb
gen resid_ttprotect= ttprotect-ProbitPredit_ttprotect

gen ttprotectresid_ttprotect= ttprotect* resid_ttprotect

gen invmills = normalden(ProbitPredit_ttprotect)/normal(ProbitPredit_ttprotect)

gen lambda = cond(ttprotect==1, normalden(ProbitPredit_ttprotect)/normal(ProbitPredit_ttprotect), ///
 - normalden(ProbitPredit_ttprotect)/(1-normal(ProbitPredit_ttprotect)))

****heck with resid and ttprotectresid
heckman lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf /*Sex_hhhead*/ i.Mother_educ ///
 Residence /*i.Wealth_index_qui  time_water num_liv_chil antenatal i.country*/ ///
 /*ttprotectresid_ttprotect resid_ttprotect*/, select(PoidsEnf_Kilo_s =  ttprotect lnage_Mother ///
 lnage_mMother_sq /*sex_enf Sex_hhhead time_water*/  i.Mother_educ i.Husband_educ Residence ///
 i.Wealth_index_qui /*num_liv_chil antenatal i.country*/) mills (mills2_ttprotect)

outreg2 using all_Heckman_resid_vacresid_ttprotect.doc, dec(3) replace
outreg2 using all_results_all.doc, dec(3) append
outreg2 using all_results_Comball_estima.doc, dec(3) append

***Fonction de controle****
reg lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf /*Sex_hhhead*/ i.Mother_educ ///
Residence /*i.Wealth_index_qui time_water num_liv_chil antenatal i.country*/ /*resid_ttprotect*/  ///
ttprotectresid_ttprotect lambda 

outreg2 using all_results_CF_linear.doc, dec(3) replace
outreg2 using all_results_Comball_estima.doc, dec(3) append


reg lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf /*Sex_hhhead*/ i.Mother_educ ///
Residence i.Wealth_index_qui /*AutoDecision time_water num_liv_chil antenatal i.country*/ ///
resid_ttprotect ttprotectresid_ttprotect invmills lambda

outreg2 using all_results_CF_Nonlinar_invmill.doc, dec(3) append
outreg2 using all_results_Comball_estima.doc, dec(3) append


 
***********************

***Contrôle function

***1ère étape
**dummy
tab ttprotect

probit ttprotect lnage_Mother lnage_mMother_sq /*sex_enf Sex_hhhead time_water*/  i.Mother_educ Residence i.Wealth_index_qui num_liv_chil antenatal i.country
outreg2 using all_prob_ttprotectCF.doc, dec(3) replace
predict Predit_ttprotect
kdensity Predit_ttprotect
ivregress 2sls lnPoidsEnf_Kilo (ttprotect = Predit_ttprotect) lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui  num_liv_chil i.country /*antenatal resid_ttprotect ttprotectresid_ttprotect time_water*/ , vce(robust)

estat firststage
estat endogenous

***************************************************************** Estimation for Benin**************************************************************************************
use DATA_WAEMU_cleaned_SR, clear 
encode v000, gen(country)
recode ParticipationDecision (2 1 = 1 ), gen(AutoDecision)
keep if country == 1

svy, vce(linearized): regress lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal if PoidsEnf_Kilo>0 
outreg2 using Benin_MCO_rob_ttprotect.doc, dec(3) ctitle(OLS) replace
outreg2 using Benin_results_all.doc, dec(3) ctitle(OLS) replace
outreg2 using Benin_results_Comball_estima.doc, ctitle(OLS) dec(3) replace

svy, vce(linearized): regress lnPoidsEnf_Kilo_n ttprotect_n lnage_Mother_n lnage_mMother_sq_n sex_enf_n Sex_hhhead_n i.Mother_educ_n Residence_n i.Wealth_index_qui_n AutoDecision time_water_n num_liv_chil_n antenatal_n 

svy, vce(linearized): regress lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal if PoidsEnf_Kilo>0
outreg2 using Benin_MCO_rob_tet2lastp.doc, ctitle(OLS) dec(3) replace


****Selection equation
generate PoidsEnf_Kilo_s = (PoidsEnf_Kilo < .)

///////////////////***********************************Heckman I1********************************************/////////////////////////////
 /*heckman depvar [indepvars] [if] [in] [weight], select([depvar_s =] varlist_s [, noconstant offset(varname_o)]) [heckman_ml_options]*/


heckman lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal i.country, select(PoidsEnf_Kilo_s =  ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal) mills (mills1_ttprotect)
outreg2 using Benin_Heckman1_ttprotect.doc, dec(3) ctitle(Heckman) replace
outreg2 using Benin_results_Comball_estima.doc, dec(3) ctitle(Heckman) append

/*outreg2 using results_all.doc, dec(3) append*/

*****Prediction 

probit ttprotect lnage_Mother lnage_mMother_sq /*sex_enf Sex_hhhead time_water*/  i.Mother_educ Residence i.Wealth_index_qui AutoDecision num_liv_chil antenatal 
outreg2 using Benin_prob_ttprotect.doc, dec(3) replace

/*outreg2 using results_Comball_estima.doc, dec(3) ctitle(Heckman) append*/

predict ProbitPredit_ttprotect, xb
gen resid_ttprotect= ttprotect-ProbitPredit_ttprotect

gen ttprotectresid_ttprotect= ttprotect* resid_ttprotect

gen invmills = normalden(ProbitPredit_ttprotect)/normal(ProbitPredit_ttprotect)

gen lambda = cond(ttprotect==1, normalden(ProbitPredit_ttprotect)/normal(ProbitPredit_ttprotect), - normalden(ProbitPredit_ttprotect)/(1-normal(ProbitPredit_ttprotect)))

****heck with resid and ttprotectresid
heckman lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal  /*ttprotectresid_ttprotect resid_ttprotect*/, select(PoidsEnf_Kilo_s =  ttprotect lnage_Mother lnage_mMother_sq /*sex_enf Sex_hhhead time_water*/  i.Mother_educ Residence i.Wealth_index_qui num_liv_chil antenatal) mills (mills2_ttprotect)

outreg2 using Benin_Heckman_resid_vacresid_ttprotect.doc, dec(3) replace
outreg2 using Benin_results_all.doc, dec(3) append
outreg2 using Benin_results_Comball_estima.doc, dec(3) append

***Fonction de controle****
reg lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal  /*resid_ttprotect*/  ttprotectresid_ttprotect lambda /**/

outreg2 using Benin_results_CF_linear.doc, dec(3) replace
outreg2 using Benin_results_Comball_estima.doc, dec(3) append


reg lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal  resid_ttprotect ttprotectresid_ttprotect invmills lambda

outreg2 using Benin_results_CF_Nonlinar_invmill.doc, dec(3) append
outreg2 using Benin_results_Comball_estima.doc, dec(3) append


sum PoidsEnf_Kilo ttprotect age_Mother sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal 


sum PoidsEnf_Kilo if milieu==1 
sum PoidsEnf_Kilo if milieu==2
 
 
***********************

***Contrôle function

***1ère étape
**dummy
tab ttprotect

probit ttprotect lnage_Mother lnage_mMother_sq /*sex_enf Sex_hhhead time_water*/  i.Mother_educ Residence i.Wealth_index_qui AutoDecision num_liv_chil antenatal 
outreg2 using Benin_prob_ttprotectCF.doc, dec(3) replace
predict Predit_ttprotect
kdensity Predit_ttprotect
ivregress 2sls lnPoidsEnf_Kilo (ttprotect = Predit_ttprotect) lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision  num_liv_chil  /*antenatal resid_ttprotect ttprotectresid_ttprotect time_water*/ , vce(robust)

estat firststage
estat endogenous


***************************************************************** Estimation for Guinea**************************************************************************************
use DATA_WAEMU_cleaned_SR, clear 
encode v000, gen(country)
recode ParticipationDecision (2 1 = 1 ), gen(AutoDecision)
keep if country == 2

svy, vce(linearized): regress lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal if PoidsEnf_Kilo>0 
outreg2 using Guinea_MCO_rob_ttprotect.doc, dec(3) ctitle(OLS) replace
outreg2 using Guinea_results_all.doc, dec(3) ctitle(OLS) replace
outreg2 using Guinea_results_Comball_estima.doc, ctitle(OLS) dec(3) replace

svy, vce(linearized): regress lnPoidsEnf_Kilo_n ttprotect_n lnage_Mother_n lnage_mMother_sq_n sex_enf_n Sex_hhhead_n i.Mother_educ_n Residence_n i.Wealth_index_qui_n AutoDecision time_water_n num_liv_chil_n antenatal_n 

svy, vce(linearized): regress lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal if PoidsEnf_Kilo>0
outreg2 using Guinea_MCO_rob_tet2lastp.doc, ctitle(OLS) dec(3) replace


****Selection equation
generate PoidsEnf_Kilo_s = (PoidsEnf_Kilo < .)

///////////////////***********************************Heckman I1********************************************/////////////////////////////
 /*heckman depvar [indepvars] [if] [in] [weight], select([depvar_s =] varlist_s [, noconstant offset(varname_o)]) [heckman_ml_options]*/


heckman lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal , select(PoidsEnf_Kilo_s =  ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal) mills (mills1_ttprotect)
outreg2 using Guinea_Heckman1_ttprotect.doc, dec(3) ctitle(Heckman) replace
outreg2 using Guinea_results_Comball_estima.doc, dec(3) ctitle(Heckman) append

/*outreg2 using results_all.doc, dec(3) append*/

*****Prediction 

probit ttprotect lnage_Mother lnage_mMother_sq /*sex_enf Sex_hhhead time_water*/  i.Mother_educ Residence i.Wealth_index_qui AutoDecision num_liv_chil antenatal 
outreg2 using Guinea_prob_ttprotect.doc, dec(3) replace

/*outreg2 using results_Comball_estima.doc, dec(3) ctitle(Heckman) append*/

predict ProbitPredit_ttprotect, xb
gen resid_ttprotect= ttprotect-ProbitPredit_ttprotect

gen ttprotectresid_ttprotect= ttprotect* resid_ttprotect

gen invmills = normalden(ProbitPredit_ttprotect)/normal(ProbitPredit_ttprotect)

gen lambda = cond(ttprotect==1, normalden(ProbitPredit_ttprotect)/normal(ProbitPredit_ttprotect), - normalden(ProbitPredit_ttprotect)/(1-normal(ProbitPredit_ttprotect)))

****heck with resid and ttprotectresid
heckman lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal  /*ttprotectresid_ttprotect resid_ttprotect*/, select(PoidsEnf_Kilo_s =  ttprotect lnage_Mother lnage_mMother_sq /*sex_enf Sex_hhhead time_water*/  i.Mother_educ Residence i.Wealth_index_qui num_liv_chil antenatal) mills (mills2_ttprotect)

outreg2 using Guinea_Heckman_resid_vacresid_ttprotect.doc, dec(3) replace
outreg2 using Guinea_results_all.doc, dec(3) append
outreg2 using Guinea_results_Comball_estima.doc, dec(3) append

***Fonction de controle****
reg lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal  /*resid_ttprotect*/  ttprotectresid_ttprotect lambda /**/

outreg2 using Guinea_results_CF_linear.doc, dec(3) replace
outreg2 using Guinea_results_Comball_estima.doc, dec(3) append


reg lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal  resid_ttprotect ttprotectresid_ttprotect invmills lambda

outreg2 using Guinea_results_CF_Nonlinar_invmill.doc, dec(3) append
outreg2 using Guinea_results_Comball_estima.doc, dec(3) append


sum PoidsEnf_Kilo ttprotect age_Mother sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal 


sum PoidsEnf_Kilo if milieu==1 
sum PoidsEnf_Kilo if milieu==2
 
 
***********************

***Contrôle function

***1ère étape
**dummy
tab ttprotect

probit ttprotect lnage_Mother lnage_mMother_sq /*sex_enf Sex_hhhead time_water*/  i.Mother_educ Residence i.Wealth_index_qui AutoDecision num_liv_chil antenatal 
outreg2 using Guinea_prob_ttprotectCF.doc, dec(3) replace
predict Predit_ttprotect
kdensity Predit_ttprotect
ivregress 2sls lnPoidsEnf_Kilo (ttprotect = Predit_ttprotect) lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision  num_liv_chil  /*antenatal resid_ttprotect ttprotectresid_ttprotect time_water*/ , vce(robust)

estat firststage
estat endogenous


***************************************************************** Estimation for Mali**************************************************************************************
use DATA_WAEMU_cleaned_SR, clear 
encode v000, gen(country)
recode ParticipationDecision (2 1 = 1 ), gen(AutoDecision)
keep if country == 3

svy, vce(linearized): regress lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal if PoidsEnf_Kilo>0 
outreg2 using Mali_MCO_rob_ttprotect.doc, dec(3) ctitle(OLS) replace
outreg2 using Mali_results_all.doc, dec(3) ctitle(OLS) replace
outreg2 using Mali_results_Comball_estima.doc, ctitle(OLS) dec(3) replace

svy, vce(linearized): regress lnPoidsEnf_Kilo_n ttprotect_n lnage_Mother_n lnage_mMother_sq_n sex_enf_n Sex_hhhead_n i.Mother_educ_n Residence_n i.Wealth_index_qui_n AutoDecision time_water_n num_liv_chil_n antenatal_n 

svy, vce(linearized): regress lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal if PoidsEnf_Kilo>0
outreg2 using Mali_MCO_rob_tet2lastp.doc, ctitle(OLS) dec(3) replace


****Selection equation
generate PoidsEnf_Kilo_s = (PoidsEnf_Kilo < .)

///////////////////***********************************Heckman I1********************************************/////////////////////////////
 /*heckman depvar [indepvars] [if] [in] [weight], select([depvar_s =] varlist_s [, noconstant offset(varname_o)]) [heckman_ml_options]*/


heckman lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal i.country, select(PoidsEnf_Kilo_s =  ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal) mills (mills1_ttprotect)
outreg2 using Mali_Heckman1_ttprotect.doc, dec(3) ctitle(Heckman) replace
outreg2 using Mali_results_Comball_estima.doc, dec(3) ctitle(Heckman) append

/*outreg2 using results_all.doc, dec(3) append*/

*****Prediction 

probit ttprotect lnage_Mother lnage_mMother_sq /*sex_enf Sex_hhhead time_water*/  i.Mother_educ Residence i.Wealth_index_qui AutoDecision num_liv_chil antenatal 
outreg2 using Mali_prob_ttprotect.doc, dec(3) replace

/*outreg2 using results_Comball_estima.doc, dec(3) ctitle(Heckman) append*/

predict ProbitPredit_ttprotect, xb
gen resid_ttprotect= ttprotect-ProbitPredit_ttprotect

gen ttprotectresid_ttprotect= ttprotect* resid_ttprotect

gen invmills = normalden(ProbitPredit_ttprotect)/normal(ProbitPredit_ttprotect)

gen lambda = cond(ttprotect==1, normalden(ProbitPredit_ttprotect)/normal(ProbitPredit_ttprotect), - normalden(ProbitPredit_ttprotect)/(1-normal(ProbitPredit_ttprotect)))

****heck with resid and ttprotectresid
heckman lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal  /*ttprotectresid_ttprotect resid_ttprotect*/, select(PoidsEnf_Kilo_s =  ttprotect lnage_Mother lnage_mMother_sq /*sex_enf Sex_hhhead time_water*/  i.Mother_educ Residence i.Wealth_index_qui num_liv_chil antenatal) mills (mills2_ttprotect)

outreg2 using Mali_Heckman_resid_vacresid_ttprotect.doc, dec(3) replace
outreg2 using Mali_results_all.doc, dec(3) append
outreg2 using Mali_results_Comball_estima.doc, dec(3) append

***Fonction de controle****
reg lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal  /*resid_ttprotect*/  ttprotectresid_ttprotect lambda /**/

outreg2 using Mali_results_CF_linear.doc, dec(3) replace
outreg2 using Mali_results_Comball_estima.doc, dec(3) append


reg lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal  resid_ttprotect ttprotectresid_ttprotect invmills lambda

outreg2 using Mali_results_CF_Nonlinar_invmill.doc, dec(3) append
outreg2 using Mali_results_Comball_estima.doc, dec(3) append


sum PoidsEnf_Kilo ttprotect age_Mother sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal 


sum PoidsEnf_Kilo if milieu==1 
sum PoidsEnf_Kilo if milieu==2
 
 
***********************

***Contrôle function

***1ère étape
**dummy
tab ttprotect

probit ttprotect lnage_Mother lnage_mMother_sq /*sex_enf Sex_hhhead time_water*/  i.Mother_educ Residence i.Wealth_index_qui AutoDecision num_liv_chil antenatal 
outreg2 using Mali_prob_ttprotectCF.doc, dec(3) replace
predict Predit_ttprotect
kdensity Predit_ttprotect
ivregress 2sls lnPoidsEnf_Kilo (ttprotect = Predit_ttprotect) lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision  num_liv_chil  /*antenatal resid_ttprotect ttprotectresid_ttprotect time_water*/ , vce(robust)

estat firststage
estat endogenous


***************************************************************** Estimation for Senegal**************************************************************************************
use DATA_WAEMU_cleaned_SR, clear 
encode v000, gen(country)
recode ParticipationDecision (2 1 = 1 ), gen(AutoDecision)
keep if country == 4

svy, vce(linearized): regress lnPoidsEnf_Kilo ttprotect /*lnage_Mother lnage_mMother_sq*/ sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal if PoidsEnf_Kilo>0 
outreg2 using Senegal_MCO_rob_ttprotect.doc, dec(3) ctitle(OLS) replace
outreg2 using Senegal_results_all.doc, dec(3) ctitle(OLS) replace
outreg2 using Senegal_results_Comball_estima.doc, ctitle(OLS) dec(3) replace

svy, vce(linearized): regress lnPoidsEnf_Kilo_n ttprotect_n /*lnage_Mother_n lnage_mMother_sq_n*/ sex_enf_n Sex_hhhead_n i.Mother_educ_n Residence_n i.Wealth_index_qui_n AutoDecision time_water_n num_liv_chil_n antenatal_n 

svy, vce(linearized): regress lnPoidsEnf_Kilo ttprotect /*lnage_Mother lnage_mMother_sq*/ sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal if PoidsEnf_Kilo>0
outreg2 using Senegal_MCO_rob_tet2lastp.doc, ctitle(OLS) dec(3) replace


****Selection equation
generate PoidsEnf_Kilo_s = (PoidsEnf_Kilo < .)

///////////////////***********************************Heckman I1********************************************/////////////////////////////
 /*heckman depvar [indepvars] [if] [in] [weight], select([depvar_s =] varlist_s [, noconstant offset(varname_o)]) [heckman_ml_options]*/


heckman lnPoidsEnf_Kilo ttprotect /*lnage_Mother lnage_mMother_sq*/ sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal i.country, select(PoidsEnf_Kilo_s =  ttprotect /*lnage_Mother lnage_mMother_sq*/ sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal) mills (mills1_ttprotect)
outreg2 using Senegal_Heckman1_ttprotect.doc, dec(3) ctitle(Heckman) replace
outreg2 using Senegal_results_Comball_estima.doc, dec(3) ctitle(Heckman) append

/*outreg2 using results_all.doc, dec(3) append*/

*****Prediction 

probit ttprotect /*lnage_Mother lnage_mMother_sq*/ /*sex_enf Sex_hhhead time_water*/  i.Mother_educ Residence i.Wealth_index_qui AutoDecision num_liv_chil antenatal 
outreg2 using Senegal_prob_ttprotect.doc, dec(3) replace

/*outreg2 using results_Comball_estima.doc, dec(3) ctitle(Heckman) append*/

predict ProbitPredit_ttprotect, xb
gen resid_ttprotect= ttprotect-ProbitPredit_ttprotect

gen ttprotectresid_ttprotect= ttprotect* resid_ttprotect

gen invmills = normalden(ProbitPredit_ttprotect)/normal(ProbitPredit_ttprotect)

gen lambda = cond(ttprotect==1, normalden(ProbitPredit_ttprotect)/normal(ProbitPredit_ttprotect), - normalden(ProbitPredit_ttprotect)/(1-normal(ProbitPredit_ttprotect)))

****heck with resid and ttprotectresid
heckman lnPoidsEnf_Kilo ttprotect /*lnage_Mother lnage_mMother_sq*/ sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal  /*ttprotectresid_ttprotect resid_ttprotect*/, select(PoidsEnf_Kilo_s =  ttprotect /*lnage_Mother lnage_mMother_sq*/ /*sex_enf Sex_hhhead time_water*/  i.Mother_educ Residence i.Wealth_index_qui num_liv_chil antenatal) mills (mills2_ttprotect)

outreg2 using Senegal_Heckman_resid_vacresid_ttprotect.doc, dec(3) replace
outreg2 using Senegal_results_all.doc, dec(3) append
outreg2 using Senegal_results_Comball_estima.doc, dec(3) append

***Fonction de controle****
reg lnPoidsEnf_Kilo ttprotect /*lnage_Mother lnage_mMother_sq*/ sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal  /*resid_ttprotect*/  ttprotectresid_ttprotect lambda /**/

outreg2 using Senegal_results_CF_linear.doc, dec(3) replace
outreg2 using Senegal_results_Comball_estima.doc, dec(3) append


reg lnPoidsEnf_Kilo ttprotect /*lnage_Mother lnage_mMother_sq*/ sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal  resid_ttprotect ttprotectresid_ttprotect invmills lambda

outreg2 using Senegal_results_CF_Nonlinar_invmill.doc, dec(3) append
outreg2 using Senegal_results_Comball_estima.doc, dec(3) append


sum PoidsEnf_Kilo ttprotect /*age_Mother*/ sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal 


sum PoidsEnf_Kilo if milieu==1 
sum PoidsEnf_Kilo if milieu==2
 
 
***********************

***Contrôle function

***1ère étape
**dummy
tab ttprotect

probit ttprotect /*lnage_Mother lnage_mMother_sq*/ /*sex_enf Sex_hhhead time_water*/  i.Mother_educ Residence i.Wealth_index_qui AutoDecision num_liv_chil antenatal 
outreg2 using Senegal_prob_ttprotectCF.doc, dec(3) replace
predict Predit_ttprotect
kdensity Predit_ttprotect
ivregress 2sls lnPoidsEnf_Kilo (ttprotect = Predit_ttprotect) /*lnage_Mother lnage_mMother_sq*/ sex_enf Sex_hhhead i.Mother_educ Residence i.Wealth_index_qui AutoDecision num_liv_chil  /*antenatal resid_ttprotect ttprotectresid_ttprotect time_water*/ , vce(robust)

estat firststage
estat endogenous




***************************************************************** Estimation for urban**************************************************************************************
use DATA_WAEMU_cleaned_SR, clear 
encode v000, gen(country)
recode ParticipationDecision (2 1 = 1 ), gen(AutoDecision)
keep if Residence == 1

svy, vce(linearized): regress lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ  i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal if PoidsEnf_Kilo>0 
outreg2 using Urban_MCO_rob_ttprotect.doc, dec(3) ctitle(OLS) replace
outreg2 using Urban_results_all.doc, dec(3) ctitle(OLS) replace
outreg2 using Urban_results_Comball_estima.doc, ctitle(OLS) dec(3) replace

svy, vce(linearized): regress lnPoidsEnf_Kilo_n ttprotect_n lnage_Mother_n lnage_mMother_sq_n sex_enf_n Sex_hhhead_n i.Mother_educ_n  i.Wealth_index_qui_n AutoDecision time_water_n num_liv_chil_n antenatal_n 

svy, vce(linearized): regress lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ  i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal if PoidsEnf_Kilo>0
outreg2 using Urban_MCO_rob_tet2lastp.doc, ctitle(OLS) dec(3) replace


****Selection equation
generate PoidsEnf_Kilo_s = (PoidsEnf_Kilo < .)

///////////////////***********************************Heckman I1********************************************/////////////////////////////
 /*heckman depvar [indepvars] [if] [in] [weight], select([depvar_s =] varlist_s [, noconstant offset(varname_o)]) [heckman_ml_options]*/


heckman lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ  i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal i.country, select(PoidsEnf_Kilo_s =  ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ  i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal) mills (mills1_ttprotect)
outreg2 using Urban_Heckman1_ttprotect.doc, dec(3) ctitle(Heckman) replace
outreg2 using Urban_results_Comball_estima.doc, dec(3) ctitle(Heckman) append

/*outreg2 using results_all.doc, dec(3) append*/

*****Prediction 

probit ttprotect lnage_Mother lnage_mMother_sq /*sex_enf Sex_hhhead time_water*/  i.Mother_educ  i.Wealth_index_qui AutoDecision num_liv_chil antenatal 
outreg2 using Urban_prob_ttprotect.doc, dec(3) replace

/*outreg2 using results_Comball_estima.doc, dec(3) ctitle(Heckman) append*/

predict ProbitPredit_ttprotect, xb
gen resid_ttprotect= ttprotect-ProbitPredit_ttprotect

gen ttprotectresid_ttprotect= ttprotect* resid_ttprotect

gen invmills = normalden(ProbitPredit_ttprotect)/normal(ProbitPredit_ttprotect)

gen lambda = cond(ttprotect==1, normalden(ProbitPredit_ttprotect)/normal(ProbitPredit_ttprotect), - normalden(ProbitPredit_ttprotect)/(1-normal(ProbitPredit_ttprotect)))

****heck with resid and ttprotectresid
heckman lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ  i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal  /*ttprotectresid_ttprotect resid_ttprotect*/, select(PoidsEnf_Kilo_s =  ttprotect lnage_Mother lnage_mMother_sq /*sex_enf Sex_hhhead time_water*/  i.Mother_educ Residence i.Wealth_index_qui num_liv_chil antenatal) mills (mills2_ttprotect)

outreg2 using Urban_Heckman_resid_vacresid_ttprotect.doc, dec(3) replace
outreg2 using Urban_results_all.doc, dec(3) append
outreg2 using Urban_results_Comball_estima.doc, dec(3) append

***Fonction de controle****
reg lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ  i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal  /*resid_ttprotect*/  ttprotectresid_ttprotect lambda /**/

outreg2 using Urban_results_CF_linear.doc, dec(3) replace
outreg2 using Urban_results_Comball_estima.doc, dec(3) append


reg lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ  i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal  resid_ttprotect ttprotectresid_ttprotect invmills lambda

outreg2 using Urban_results_CF_Nonlinar_invmill.doc, dec(3) append
outreg2 using Urban_results_Comball_estima.doc, dec(3) append


sum PoidsEnf_Kilo ttprotect age_Mother sex_enf Sex_hhhead i.Mother_educ  i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal 


sum PoidsEnf_Kilo if milieu==1 
sum PoidsEnf_Kilo if milieu==2
 
 
***********************

***Contrôle function

***1ère étape
**dummy
tab ttprotect

probit ttprotect lnage_Mother lnage_mMother_sq /*sex_enf Sex_hhhead time_water*/  i.Mother_educ  i.Wealth_index_qui AutoDecision num_liv_chil antenatal 
outreg2 using Urban_prob_ttprotectCF.doc, dec(3) replace
predict Predit_ttprotect
kdensity Predit_ttprotect
ivregress 2sls lnPoidsEnf_Kilo (ttprotect = Predit_ttprotect) lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ  i.Wealth_index_qui AutoDecision  num_liv_chil  /*antenatal resid_ttprotect ttprotectresid_ttprotect time_water*/ , vce(robust)

estat firststage
estat endogenous



***************************************************************** Estimation for Rural**************************************************************************************
use DATA_WAEMU_cleaned_SR, clear 
encode v000, gen(country)
recode ParticipationDecision (2 1 = 1 ), gen(AutoDecision)
keep if Residence == 0

svy, vce(linearized): regress lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ  i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal if PoidsEnf_Kilo>0 
outreg2 using Rural_MCO_rob_ttprotect.doc, dec(3) ctitle(OLS) replace
outreg2 using Rural_results_all.doc, dec(3) ctitle(OLS) replace
outreg2 using Rural_results_Comball_estima.doc, ctitle(OLS) dec(3) replace

svy, vce(linearized): regress lnPoidsEnf_Kilo_n ttprotect_n lnage_Mother_n lnage_mMother_sq_n sex_enf_n Sex_hhhead_n i.Mother_educ_n  i.Wealth_index_qui_n AutoDecision time_water_n num_liv_chil_n antenatal_n 

svy, vce(linearized): regress lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ  i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal if PoidsEnf_Kilo>0
outreg2 using Rural_MCO_rob_tet2lastp.doc, ctitle(OLS) dec(3) replace


****Selection equation
generate PoidsEnf_Kilo_s = (PoidsEnf_Kilo < .)

///////////////////***********************************Heckman I1********************************************/////////////////////////////
 /*heckman depvar [indepvars] [if] [in] [weight], select([depvar_s =] varlist_s [, noconstant offset(varname_o)]) [heckman_ml_options]*/


heckman lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ  i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal i.country, select(PoidsEnf_Kilo_s =  ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ  i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal) mills (mills1_ttprotect)
outreg2 using Rural_Heckman1_ttprotect.doc, dec(3) ctitle(Heckman) replace
outreg2 using Rural_results_Comball_estima.doc, dec(3) ctitle(Heckman) append

/*outreg2 using results_all.doc, dec(3) append*/

*****Prediction 

probit ttprotect lnage_Mother lnage_mMother_sq /*sex_enf Sex_hhhead time_water*/  i.Mother_educ  i.Wealth_index_qui AutoDecision num_liv_chil antenatal 
outreg2 using Rural_prob_ttprotect.doc, dec(3) replace

/*outreg2 using results_Comball_estima.doc, dec(3) ctitle(Heckman) append*/

predict ProbitPredit_ttprotect, xb
gen resid_ttprotect= ttprotect-ProbitPredit_ttprotect

gen ttprotectresid_ttprotect= ttprotect* resid_ttprotect

gen invmills = normalden(ProbitPredit_ttprotect)/normal(ProbitPredit_ttprotect)

gen lambda = cond(ttprotect==1, normalden(ProbitPredit_ttprotect)/normal(ProbitPredit_ttprotect), - normalden(ProbitPredit_ttprotect)/(1-normal(ProbitPredit_ttprotect)))

****heck with resid and ttprotectresid
heckman lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ  i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal  /*ttprotectresid_ttprotect resid_ttprotect*/, select(PoidsEnf_Kilo_s =  ttprotect lnage_Mother lnage_mMother_sq /*sex_enf Sex_hhhead time_water*/  i.Mother_educ Residence i.Wealth_index_qui num_liv_chil antenatal) mills (mills2_ttprotect)

outreg2 using Rural_Heckman_resid_vacresid_ttprotect.doc, dec(3) replace
outreg2 using Rural_results_all.doc, dec(3) append
outreg2 using Rural_results_Comball_estima.doc, dec(3) append

***Fonction de controle****
reg lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ  i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal  /*resid_ttprotect*/  ttprotectresid_ttprotect lambda /**/

outreg2 using Rural_results_CF_linear.doc, dec(3) replace
outreg2 using Rural_results_Comball_estima.doc, dec(3) append


reg lnPoidsEnf_Kilo ttprotect lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ  i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal  resid_ttprotect ttprotectresid_ttprotect invmills lambda

outreg2 using Rural_results_CF_Nonlinar_invmill.doc, dec(3) append
outreg2 using Rural_results_Comball_estima.doc, dec(3) append


sum PoidsEnf_Kilo ttprotect age_Mother sex_enf Sex_hhhead i.Mother_educ  i.Wealth_index_qui AutoDecision time_water num_liv_chil antenatal 


sum PoidsEnf_Kilo if milieu==1 
sum PoidsEnf_Kilo if milieu==2
 
 
***********************

***Contrôle function

***1ère étape
**dummy
tab ttprotect

probit ttprotect lnage_Mother lnage_mMother_sq /*sex_enf Sex_hhhead time_water*/  i.Mother_educ  i.Wealth_index_qui AutoDecision num_liv_chil antenatal 
outreg2 using Rural_prob_ttprotectCF.doc, dec(3) replace
predict Predit_ttprotect
kdensity Predit_ttprotect
ivregress 2sls lnPoidsEnf_Kilo (ttprotect = Predit_ttprotect) lnage_Mother lnage_mMother_sq sex_enf Sex_hhhead i.Mother_educ  i.Wealth_index_qui AutoDecision  num_liv_chil  /*antenatal resid_ttprotect ttprotectresid_ttprotect time_water*/ , vce(robust)

estat firststage
estat endogenous



log close
