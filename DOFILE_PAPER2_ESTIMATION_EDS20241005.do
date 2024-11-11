****Setting up data
clear all
set mem 600m
set more 1
set maxvar 15000

cd "C:\Users\peprc\Downloads\PAPIER_EDS\"
use Data2006_2018merged, replace

****Variables
gen wt = v005/1000000
svyset [iw=wt]

*******************************************************************Inspecting dataset********************************************************************************************

*****Generate  Norms variables 

****cluster on pooled data
***drop if v613 > 30
tab1 v627 v628
clonevar v627_new = v627
clonevar v628_new = v628

replace v627_new = . if v627== 96
replace v628_new = . if v627== 96
graph box v627_new
tabstat v627_new, stat(N mean median sd p1 p25 p75 min max skewness)
tabstat v628_new, stat(N mean median sd p1 p25 p75 min max skewness)
tab v613
tabstat v613, stat(N mean median sd p1 p25 p75 min max skewness)
bysort v001 : egen Living_cluster_New = mean(v218)
bysort v001: egen ideal_cluster2_New = mean(v613) 

gen max = round(30 - 2*2.333602)
gen max1 = round(22 - 1.501331*2)
gen max2 = round(15 - 1.447028*2)
sum max1 max2

gen v627_new_cor = v627_new 
replace  v627_new_cor = 19 if v627_new > 22

gen v628_new_cor = v628_new 
replace  v628_new_cor = 12 if v628_new > 15

graph box v627_new_cor



gen v613_corr = v613
replace v613_corr = 25 if v613 > 25
sum v613_corr
graph box v613_corr
ta v627
ta v202
****recode v202 (0 = 0 " less than 1")(1 2 =)
gen Hav_des_son = 0
replace Hav_des_son = 1 if v202 >= v627
ta Hav_des_son

sum v613_corr v218 if v012 >= 45
****Variables
**Age
gen age = v012
gen age_sq = age*age

***1.	Age at mariage (at first mariage)
sum v511 // Age at first cohabitation
gen Age_FirstMariage = v511 // Age at first birth
recode v511 ( 6 /14 = 1 "[10,14[")(15/17 = 2 "[15, 17[")(18/19 = 3 "[18,20[") ///
(20/21 = 4 "[20,22[")(22/24 = 5 "[22, 25[")(25/49 = 6 "[26, +[")(. = 8 "dk"), gen(Age_FirstMariage_cat)
tab Age_FirstMariage_cat
recode v511 ( 6 /17 = 1 "[10,18[")(18/19 = 2 "[18,20[")(20/49 = 3 "[20,49[") ///
(. = 4 "dk"), gen(Age_FirstMariage_cat_1)
tab Age_FirstMariage_cat_1

***2.	Age  at first birth
sum v212 //Age at first birth
gen Age_FirstBirth = v212 // Age at first birth
recode v212 ( 0 /19 = 1 "[15,20[")(20/29 = 2 "[20, 30[")(30/49 = 3 "[30,49]")(. = 4 "dk"), gen(AgeFirstBirth)
tab AgeFirstBirth

recode v212 ( 0 /19 = 1 "[15,20[")(20/34 = 2 "[20, 35[")(35/49 = 3 "[35,49]")(. = 4 "dk"), gen(AgeFirstBirth_corr)
tab AgeFirstBirth_corr

****Marriage to first birth intervalle
sum v221 // Marriage to first birth intervalle
recode v221  (. = 999 "dk"), gen(MarToBirInt)
ta MarToBirInt

***3.	Sex composition of children of current (surviving) children
tab v218 // living children
tab v202 // son at home
tab v203 // daughter at home
gen SonDaugther = v202 - v203
gen ChildComposit = 0
replace ChildComposit = 1 if SonDaugther > 0
replace ChildComposit = 2 if SonDaugther < 0
replace  ChildComposit = . if v202 ==0 & v203==0
replace ChildComposit = 3 if ChildComposit==.
lab define  ChildComposit 0 "Equal number" 1 " More Son than daughter" 2 " More daughter than son" 3 " dk"
lab value ChildComposit ChildComposit
tab ChildComposit

****4.	Sex composition of children based on son
gen HaveSon_home = (v202>= 1) // have at least one son at home
gen HaveSon_anywhere = (v202>= 1 |v204>= 1) // have at least one son anywhere

tab HaveSon_home
tab HaveSon_anywhere




****6.	 structural changes in agriculture 

****7.	Level of education (men  vs women) : Level vs years
sum v133, d
drop  if v133==99
gen MotherEducYear = v133
gen  HusbandEduYear = v715
replace  HusbandEduYear = . if HusbandEduYear==98|HusbandEduYear==99 |HusbandEduYear==.
sum HusbandEduYear,d

recode v106 (0 = 0 "No Education")(1 = 1 "Primaire")(2 3 = 2 "Higher and +") (8 9 . = 3 "dk"), gen(Education_femme)
recode v701 (0 = 0 "No Education")(1 = 1 "Primaire")(2 3 = 2 "Higher and +") (8 9 . = 3 "dk"), gen(Education_epoux)
tab Education_femme
tab Education_epoux


***8.	Employment status ( wowen)
tab v731  
recode v731 (0=0 "No")(1=1 "In the past year")(2=2 "Currently working")(3=3 "On leave")(9=4 "dk"), gen(EmploymentStatus)
ta EmploymentStatus
***9.	Occupation (men vs wowen)
***10.	Activities sectors (men vs wowen)
tab v705
ed  v705
recode v705 ( 0 = 0 "Ne travaille Pas")(4 5 = 1 "Agriculture")(1 3 7 8 96 = 2 "Non- Agriculture")(9 98 99 . = 3 "dk"), gen (OccupationEpoux)
ta OccupationEpoux

recode OccupationEpoux ( 0 = 0 "Unemployed")(1 2 = 1 " Employed")(3 = 3 "dk"), gen (Husband_EmploymentStatus)
ta Husband_EmploymentStatus
recode Husband_EmploymentStatus ( 0 = 0 "Unemployed")(1 2 3 = 1 " Employed"), gen(Husband_EmploymentStatus_corr)
ta Husband_EmploymentStatus_corr

ta v717
recode v717 ( 0 = 0 "Ne travaille Pas")(4 5 = 1 "Agriculture")(1 3 6 7 8 9 96 = 2 "Non- Agriculture")(98 99 . = 3 "dk"), gen (OccupationFemme)
recode OccupationFemme ( 0 = 0 "Unemployed")(1 2 = 1 " Employed")(3 = 2 "dk"), gen (Mother_EmploymentStatus)

recode OccupationFemme ( 0 = 0 "Unemployed")(1 2 3 = 1 " Employed"), gen(Mother_EmploymentStatus_corr)
ta Mother_EmploymentStatus_corr

ta Mother_EmploymentStatus

***11.	Employment duration (full time, part time ( year),  from time to time ( men vs wowen)

tab v732
recode  v732 (1 = 0 "All year")(2= 1 "Seasonal")(3 = 2 "Occasional")(9 .= 3 "dk"), gen(EmploymentDuration)
ta EmploymentDuration

***12.	women’s economic participation : omen empowerment as a variables was derived from respondent’s decision making capacity on own health care, large household purchases, and visits to family and relatives
tab v739 //person who usually decides how to spend respondent's earnings
ed v745a v745b // own house or land alone or jointly
tab v745a
tab v745b

***13.	Women’s parity
tab v746 // respondent earns more than husband/partner
***ed v743a v743b v743c v743d v743e v743f // person who usually decides on respondent's .....
ta v743a // health care
ta v743b // large purchase
ta v743d // Visit to family
ta v743f // how to spend husband money

gen decisionMaking1 = 0
replace decisionMaking = 1 if v743a == 1 & v743b == 1 & v743d == 1 
ta decisionMaking1
gen decisionMaking2 = 0
replace decisionMaking2 = 1 if (v743a == 1|v743a == 2) & (v743b == 1 | v743b == 2) & (v743d == 1|v743d == 2)
tab decisionMaking2 
gen decisionMaking3 = 0
replace decisionMaking3 = 1 if (v743a == 1|v743a == 2) & (v743b == 1 | v743b == 2) | (v743a == 1|v743a == 2) & (v743d == 1|v743d == 2) |(v743b == 1|v743b == 2) & (v743d == 1|v743d == 2)
tab decisionMaking3 
gen deci1 = 0
replace  deci1 = 1 if v743a == 2
gen deci2 = 0
replace  deci2 = 1 if v743b == 2
gen deci3 = 0
replace  deci3 = 1 if v743d == 2
/*
pca deci1 deci2 deci3
predict pc1 pc2 pc3, score
gen score = pc1 + 1.329033 */

*****Autonomisation des femmes

recode v743a (1/3 = 1 "Yes")(else = 0 "No"), gen(HealthCareDecision)
recode v743b (1/3 = 1 "Yes")(else = 0 "No"), gen(LargePurchaseDecision)
recode v743d (1/3 = 1 "Yes")(else = 0 "No"), gen(VisitFamilyDecision)
recode v743f (1/2 = 1 "Yes")(else = 0 "No"), gen(SpendHusbandmoneyDecision)
pca HealthCareDecision LargePurchaseDecision VisitFamilyDecision SpendHusbandmoneyDecision
predict pc1 pc2 pc3 pc4, score
gen Woman_Empowerment_Score = pc1 + 1.54
sum Woman_Empowerment_Score
ta Woman_Empowerment_Score
ta v743a,nol

recode v743a (2 = 1 "Yes")(else = 0 "No"), gen(HealthCareDecision_corr)
recode v743b (2 = 1 "Yes")(else = 0 "No"), gen(LargePurchaseDecision_corr)
recode v743d (2 = 1 "Yes")(else = 0 "No"), gen(VisitFamilyDecision_corr)
gen PriseDeciTotal = HealthCareDecision_corr + LargePurchaseDecision_corr + VisitFamilyDecision_corr
tab PriseDeciTotal

recode PriseDeciTotal (1 2 = 1)(3=2), gen(ParticipationDecision)
ta ParticipationDecision



**** 


****Generer les instruments: Proportion d'enfant non desirers
gen Inst = 0
replace Inst = 1 if v613 == 0
gen Inst1 = 0
replace Inst1 = 1 if v218 == 2 & v613 == 0
gen Inst2 = 0
replace Inst2 = 1 if v218 == 4 & v613 == 0
gen Inst3 = 0
replace Inst3 = 1 if v218 == 6 & v613 == 0
gen Sterelized = 0
replace Sterelized = 1 if v320 != .
gen Infecund = 1 if (v3a08e == 1)
recode Infecund (. = 0)
ta Infecund

***ed v744a v744b v744c v744d v744e// beating justified....
ta v744a
ta v744b
ta v744c
ta v744d
ta v744e

gen beating_justified = 0
replace beating_justified = 1 if v744a==1 | v744b==1 |v744c==1|v744d==1|v744e==1
lab define beating_justified 0 "No" 1 "Yes"
lab value beating_justified beating_justified
tab beating_justified

***14.	Religion (man vs women)

recode v130 (10 71 = 0 " No religion")(1 2 11 12 = 1 "Traditional")(4/8 31 41 42 51 52 = 2 " Chritian")(3 21 = 3 "Muslim")(9 61 99= 4 "Others"), gen (Religion_group)
tab Religion_group
***15.	Years of Marriage
tab v508 // year of first cohabitation
tab v512 // year since  first cohabitation

****16.	Child loss experience

gen DeathChild =  v201 - v218
ta DeathChild

****17.	Number of marital unions

recode v503 (1 = 0 "Once")(2 = 1 " More than once")(9 . = 2 " dk"), gen(NumberUnion)
ta NumberUnion

recode v535 ( 0 = 0 "No")( 1 = 1 "Formely married")( 2 = 2 "Lived with a man")( . = 3 "dk"), gen(BeenInMarriage)
tab BeenInMarriage

****18.	Ever use of modern contraceptives
recode  v364 (1 = 1 "Yes")(2 3 4 = 0 "No"), gen(ModernContraception)
recode  v364 (1 2 = 1 "Yes")(3 4 = 0 "No"), gen(Contraception)
ta Contraception
ta ModernContraception

***19.	Couple’s fertility preference
ta v621
recode v621 (1 = 0 "Both want same")(2 = 1 "Husband wants more")(3 = 2 "Husband wants fewer")(8 9 . = 3 "dk"), gen(FertilityPreference)
tab FertilityPreference


****20.	Place of residence

recode v025 (1 = 1 "Urban")(2 = 0 "Rural"), gen(Residence)
ta Residence

****5.	urbanization

/*bysort v001: egen pop = total(wtpop)
ed pop*/
gen Rural = 1 if Residence == 0
gen Urbain = 1 if Residence == 1
tab1 Rural Urbain
bysort v001: egen popRural = total(Rural)
bysort v001: egen popUrbain = total(Urbain)
gen popTotal = popUrbain + popRural
gen RationUrbRur = popUrbain / popTotal
gen TauxUrbanisation = RationUrbRur * 100
save DATA_Appended_2006_2018_Analysismerged, replace

****21.	Ethnicity
clonevar Ethnicity = v131

****22.	Wealth index

clonevar WealthIndex = v190 
recode WealthIndex ( 1 2 = 0 "pauvre")(3 = 1 "Moyen")(4 5 = 2 "Riche"),gen(Wealth_Tercile)
recode WealthIndex ( 1 2 = 1 "pauvre")(3/5 = 0 "Non pauvre"),gen(Pauvre)
ta Pauvre

****23.	Sons at home
tab v202
clonevar Num_SonatHome = v202 

***24.	Daughters at home
ta v203
clonevar Num_DaugtheratHome = v203 // daughter at home

***25.Exposition aux media
tab v157 
tab v158 
tab v159

gen MediaExposure = 0
replace MediaExposure = 1 if v157 == 1 |v157 == 2 | v158 == 1 |v158 == 2 | v159 == 1 |v159 == 2
lab def MediaExposure  0 "No" 1 "Yes"
lab val MediaExposure MediaExposure
tab MediaExposure

***Heard family planning on media

ta v384a 
ta v384b 
ta v384c 
ta v384d

gen FP_MediaExposure = 0
replace FP_MediaExposure = 1 if v384a == 1 |v384b == 1 | v384c == 1 |v384d == 1 
lab def FP_MediaExposure  0 "No" 1 "Yes"
lab val FP_MediaExposure FP_MediaExposure
ta FP_MediaExposure

****Living child,Living child+ pregnacy & living child+ pregnancy (group)
ta v218 
ta v219 
ta v220
***** Desired for more child and husband's desired child
ta v605 
ta v621
**** Ideal number of children and ideal number of children grouped
ta v613 
ta v614

*****Ideal number of boys, girls and both sex
ta v627 
ta v628 
ta v629
bysort v001: egen Living_cluster = mean(v218)
bysort v001: egen ideal_cluster = mean(v613)


bysort v001: egen NumChild_cluster = total(v218)
gen FertileWomen = 1
bysort v001: egen FertileWomen_cluster = total(FertileWomen)
gen Spatial_Norms = NumChild_cluster/FertileWomen_cluster


****Social norms
bysort Religion_group: egen NumChild_Religion = total(v218)
bysort Religion_group: egen FertileWomen_Religion = total(FertileWomen)
gen Social_Norms = NumChild_Religion/FertileWomen_Religion
tab Social_Norms

bysort v001: egen ideal_Median_cluster = median(v613)
bysort v001: egen Media_cluster = mean(MediaExposure)
recode Media_cluster (0/0.5 . = 0 "No")(0.5/1 = 1 "Yes"), gen(Media_cluster_bin)
ta Media_cluster_bin
bysort v001: egen FP_Media_cluster = mean(FP_MediaExposure)
recode FP_Media_cluster (0/0.5 . = 0 "No")(0.5/1 = 1 "Yes"), gen(FP_Media_cluster_bin)
ta FP_Media_cluster_bin

***Visit for FP
tab v393
gen visitForFP = 0
replace visitForFP= 1 if v393a==1
lab def visitForFP  0 "No" 1 "Yes"
lab val visitForFP visitForFP
ta visitForFP

bysort v001: egen visitForFP_cluster = mean(visitForFP)
replace visitForFP_cluster = 1 if visitForFP_cluster > 0
ta visitForFP_cluster

gen FP_Discussion_Commu = 0
replace FP_Discussion_Commu = 1 if s816a ==1 | s816b == 1 | s816c == 1 | s816d ==1 | s816e == 1 | s816f == 1 | s816g == 1 | s816h == 1 | s816i == 1
ta FP_Discussion_Commu
lab def FP_Discussion_Commu  0 "No" 1 "Yes"
lab val FP_Discussion_Commu FP_Discussion_Commu
ta FP_Discussion_Commu

bysort v001: egen FP_Discussion_Commu_cluster = mean(FP_Discussion_Commu)
replace FP_Discussion_Commu_cluster = 1 if FP_Discussion_Commu_cluster > 0
lab def FP_Discussion_Commu_cluster  0 "No" 1 "Yes"
lab val FP_Discussion_Commu_cluster FP_Discussion_Commu_cluster
ta FP_Discussion_Commu_cluster

***Part de chaque groupe réligieux 
ta Religion_group
ta Religion_group, nol
gen SansReligion = 1 if (Religion_group==0) 
gen Traditionnelle = 1 if (Religion_group==1) 
gen Chretien = 1 if (Religion_group==2)
gen Musulman = 1 if (Religion_group==3)
gen Others = 1 if (Religion_group==4)

bysort v001: egen SansReligion_freq = count(SansReligion)
bysort v001: egen Traditionnelle_freq = count(Traditionnelle)
bysort v001: egen Chretien_freq = count(Chretien)
bysort v001: egen Musulman_freq = count(Musulman)
bysort v001: egen Others_freq = count(Others)
bysort v001: egen Tot_freq = count(Religion_group)

bysort v001: gen SansReligion_share1 =  SansReligion_freq/Tot_freq
bysort v001: gen Traditionnelle_share1 =  Traditionnelle_freq/Tot_freq
bysort v001: gen Chretien_share1 =  Chretien_freq/Tot_freq
bysort v001: gen Musulman_share1 =  Musulman_freq/Tot_freq
bysort v001: gen Others_share1 =  Others_freq/Tot_freq

bysort v001: egen Traditionnelle_share = pc(Religion_group==1), prop
bysort v001: egen Chretien_share = pc(Religion_group==2), prop
bysort v001: egen Musulman_share = pc(Religion_group==3), prop
bysort v001: egen Tot_share = pc(Tot_freq), prop

********Generate fertility desire gap 
sum v613
sum v218
gen DesIdeal1 = v613 - v218
ta DesIdeal1
recode DesIdeal1 (-12 /-1 = 1 "Above")(0 = 2 "Exact")(1/99 = 3 " Under"), gen(RealisaAttentes) 
recode  RealisaAttentes (2 = 1 "Exact")(1 3 = 0 "Less or more"), gen(RealisaAttentes_Bin)
tab DesIdeal 
tab RealisaAttentes 
tab RealisaAttentes_Bin

recode  RealisaAttentes (3 = 1 "Yes")(1 2 = 0 "No"), gen(OverAchievement)
tab OverAchievement


******Corrected on 20240622 

gen DesIdeal_corr = v613_corr - v201
ta DesIdeal_corr
recode DesIdeal_corr (-14 /-1 = 1 "Above")(0 = 2 "Exact")(1/25 = 3 " Under"), gen(RealisaAttentes_corr_new) 
ta RealisaAttentes_corr_new [iw=wt] if v012 > 40 
ta RealisaAttentes_corr_new 
recode  RealisaAttentes_corr_new (2 = 0 "Exact")(1 3 = 1 "Less or more"), gen(RealisaAttentes_Bin_corr_new)
tab RealisaAttentes_Bin_corr_new 


****** Correcting the fertility gap 
gen Corected_DC =  v613
replace Corected_DC = v613 + 1 if RealisaAttentes == 1 & v367 == 1 |v367 == 2
replace Corected_DC = v613 - 1 if RealisaAttentes == 3 & v605 > 3
gen DesIdeal2 = Corected_DC - v218
recode DesIdeal2 (-12 /-1 = 1 "Above")(0 = 2 "Exact")(1/30 = 3 " Under"), gen(RealisaAttentes_corr) 
recode  RealisaAttentes_corr (2 = 1 "Exact")(1 3 = 0 "Less or more"), gen(RealisaAttentes_Bin_corr)
recode  RealisaAttentes_corr (3 = 1 "Yes")(1 2 = 0 "No"), gen(OverAchievement_corr)
ta OverAchievement_corr

egen total_ideal = rowtotal (v627_new_cor v628_new_cor) 
gen diff = v613_corr - total_ideal
sum diff
gen check = 0
replace check = 1 if diff!= 0
tab check

ed v613_corr v627_new_cor v628_new_cor  diff if check == 1
gen Ideal_corr = v613 if check == 0
replace Ideal_corr = total_ideal if check == 1
ta Ideal_corr

*****

gen DesIdeal1new = total_ideal - v218
ta DesIdeal1new
recode DesIdeal1new (-13 /-1 = 1 "Above")(0 = 2 "Exact")(1/31 = 3 " Under"), gen(RealisaAttentesnew) 
tab RealisaAttentesnew v013, col
tab RealisaAttentes_corr v013,col
graph bar total_ideal v218, over (v013)

tab RealisaAttentes 


sum v218

***kdensity living vs desires
gen LogLivingChildren = log(v218 +1 )
gen LogDesireChildren = log(v613 +1 )
sum LogLivingChildren
sum LogDesireChildren


****Marital status
recode v501 (0 = 0 "Celibataire")(1 2 = 1 "Marie")(3 4 5 = 2 "Autre"), gen(SituationMatri)
ta SituationMatri

***
recode v745b (0 .= 0 "No")(1 2 3 = 1 "Yes"), gen(Land)
ta Land

xtile  quintileLivingChild = v218 , nq(5)
xtile quintileDesireChildr =  v613, nq(5)
tab quintileDesireChildr quintileLivingChild if SituationMatri==2 & quintileLivingChild > 0, r chi2

recode v119 (0 7 .= 0 "No")(1 = 1 "Yes"), gen(AccessElectricity)
ta AccessElectricity

//Ideal number of children
recode v613 (0=0 "0") (1=1 "1") (2=2 "2") (3=3 "3") (4=4 "4") (5=5 "5") (6/94=6 "6+") (95/99=9 "non-numeric response"), gen(ff_ideal_num) 
label var ff_ideal_num "Ideal number of children"
ta ff_ideal_num

//Mean ideal number of children - all women
sum v613 if v613<95 [iw=v005/1000000]
gen ff_ideal_mean_all=round(r(mean),0.1)
label var ff_ideal_mean_all	"Mean ideal number of children for all"

//Mean ideal number of children - married women
sum v613 if v613<95 & v502==1 [iw=v005/1000000]
gen ff_ideal_mean_mar=round(r(mean),0.1)
label var ff_ideal_mean_mar	"Mean ideal number of children for married"

// Average ideal number of children per cluster
bysort v001: egen AINC_cluster = mean(v613)
bysort v001: egen AINC_cluster_corr = mean(v613_corr)

sum AINC_cluster
sum AINC_cluster_corr 

// Average living number of children per cluster
bysort v001: egen ALNC_cluster = mean(v218)
sum ALNC_cluster

//Year1
recode v007 (2006 = 1 "2006")(2011 2012 = 2 "2011 &2012")(2017 2018 = 3 "2017 & 2018"), gen (Year1)

***Media exposure winthin cluster
ta MediaExposure
bysort v001: gen Media_cluster_New = 1 if MediaExposure == 1
replace Media_cluster_New = 0 if Media_cluster_New == .
replace Media_cluster_New = 1 if Media_cluster_New > 0
ta Media_cluster_New

bysort v001: gen FP_Media_cluster_New = 1 if FP_MediaExposure == 1
replace FP_Media_cluster_New = 0 if FP_Media_cluster_New == .
replace FP_Media_cluster_New = 1 if FP_Media_cluster_New > 0
ta FP_Media_cluster_New

******create variable Target
recode  v605 (5/7 = 1 "Yes")(else = 0 "No"), gen(target)
recode  v605 (5/6 = 1 "Yes")(else = 0 "No"), gen(target2)

tab1 target target2
sum v613 v218 if v605==7
sum age v613 v218 if v605==7

****Child lost experience
recode DeathChild (0 = 0 "No")(else = 1 "Yes"), gen(ChildLost_Exp)
   /// en classe
tab ChildLost_Exp
*****Never give born
recode v220 (0 = 1 " Yes")(else = 0 "No"), gen(NeverGiveBorn)

****Urbanisation

gen v005pop = v005*v136


gen wtpop = v005pop/1000000

***Reechantillonnage
display 50016 / 17489  // 2.8598548
display 50016 / 16599 // 3.0131936
display 50016 / 15928 // 3.1401306

gen a2006_2018 = 0
replace a2006_2018 = 2.8598548 if Year1 == 1
replace a2006_2018 = 3.0131936 if Year1 == 2
replace a2006_2018 = 3.1401306 if Year1 == 3
tab a2006_2018

gen wtpop2006_2018 =  a2006_2018 * wtpop
ed wtpop2006_2018
svyset [iw=wtpop2006_2018]

* Save data
save DATA_Appended_2006_2018_Analysismerged, replace



ta v613 [iw=wtpop]
tab1 v218 v201 v613

recode v613 (94/99 = .), gen(v613corr)
graph box  v613corr
graph box  v201
tabstat v613corr, stat(p25 p50 p75)

bysort v025: ta v001
tab Residence 

****generate targets (married/union women who wanted no more children, were sterilized or declared infecund, and provided numerical answers for fertility desire (ideal number of children))
gen Target0 = 0
replace Target0 = 1 if v012 > 39
tab Target0


gen Target1 = 0
replace Target1 = 1 if SituationMatri == 1 & (v605 == 5 | v605 == 6 | v605 == 7) & (v613 != 94 | v613 != 95 | v613 != 96 | v613 != 99)
tab Target1

gen Target2 = 0
replace Target2 = 1 if Target1 == 1 & (ChildLost_Exp == 1) & (v201 != 0) & (Target0 == 1)
tab Target2


****Normes
**

gen CEB = v201
gen LivingChild = v218
***********Descriptive statistics
ta RealisaAttentes_corr_new 
svy:ta RealisaAttentes_corr_new 
kwallis CEB /*[iw=wtpop2006_2018]*/ if Target1 == 1, by(RealisaAttentes_corr_new)
oneway CEB RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, tabulate
oneway  DeathChild RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, tabulate

svy: tab ChildLost_Exp RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, pearson  row
oneway LivingChild RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, tabulate
ta Residence RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, row  chi2
svy: ta Residence RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, pearson  row

oneway MotherEducYear RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, tabulate

ta Education_femme RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, row  chi2
svy: ta Education_femme RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, pearson  row

ta Education_epoux RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, row  chi2
svy: ta Education_epoux RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, pearson  row


 
ta AgeFirstBirth RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, row  chi2
svy:ta AgeFirstBirth RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, pearson col row

ta AgeFirstBirth_corr RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, row  chi2
svy: ta AgeFirstBirth_corr RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, pearson  row


ta NumberUnion RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, row  chi2
svy: ta NumberUnion RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, pearson  row

ta Contraception RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, row  chi2
svy: ta Contraception RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, pearson  row

ta ModernContraception RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, row  chi2
svy: ta ModernContraception RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, pearson  row

ta MediaExposure RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, row  chi2
svy:ta MediaExposure RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, pearson  row

svy: ta FP_MediaExposure RealisaAttentes_corr_new if Target1 == 1 & v012 > 39,pearson row 



ta ParticipationDecision RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, row  chi2
svy: ta ParticipationDecision RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, pearson col row

recode ParticipationDecision (0 1 = 0) (2 = 1), gen(ParticipationDecision2)
ta ParticipationDecision2
svy: ta ParticipationDecision2 RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, pearson row 

ta beating_justified RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, row  chi2
svy: ta beating_justified RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, pearson  row

oneway AINC_cluster_corr RealisaAttentes_corr_new  if Target1 == 1 & v012 > 39, tabulate
oneway AINC_cluster RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, tabulate
oneway ALNC_cluster RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, tabulate

ta Education_epoux RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, row  chi2
svy: ta Education_epoux RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, pearson col row

ta FertilityPreference RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, row  chi2
svy: ta FertilityPreference RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, pearson  row

ta HaveSon_home RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, row  chi2
svy:ta HaveSon_home RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, pearson  row


oneway TauxUrbanisation RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, tabulate
ta Year1 RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, row  chi2
svy: ta Year1 RealisaAttentes_corr_new if Target1 == 1 & v012 > 39,  pearson  row


ta Mother_EmploymentStatus_corr RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, row  chi2
svy: ta Mother_EmploymentStatus_corr RealisaAttentes_corr_new if Target1 == 1 & v012 > 39,pearson  row
svy:ta Husband_EmploymentStatus_corr RealisaAttentes_corr_new if Target1 == 1 & v012 > 39,pearson  row 

ta EmploymentDuration RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, row  chi2
svy: ta EmploymentDuration RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, pearson  row

ta Pauvre RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, row  chi2
svy: ta Pauvre RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, pearson  row

ta Religion_group RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, row  chi2
svy: ta Religion_group RealisaAttentes_corr_new  if Target1 == 1 & v012 > 39, pearson  row  

ta  RealisaAttentes_corr_new if Target1 == 1 & v012 > 39
svy: ta  RealisaAttentes_corr_new if Target1 == 1 & v012 > 39, col 



bysort RealisaAttentes_corr_new: sum v218 [iw=wtpop2006_2018] if Target1 == 1 & v012 > 39
bysort RealisaAttentes_corr_new: sum v201 [iw=wtpop2006_2018] if Target1 == 1 & v012 > 39

bysort RealisaAttentes_corr_new: sum DeathChild [iw=wtpop2006_2018] if Target1 == 1 & v012 > 39
bysort RealisaAttentes_corr_new: sum v613_corr [iw=wtpop2006_2018] if Target1 == 1 & v012 > 39

****Graph

graph dot v613_corr, over(v013) by(RealisaAttentes_corr_new)
graph dot v218, over(v013) by(RealisaAttentes_corr_new)

graph box v218, by(v613_corr)
graph box v613_corr, by(v613_corr)


*******Construction des variables pour la selection 
****construiction de C
gen C = 1 == (Target1 == 1)

*******Variable de selection= select

gen select = 1 == (C == 1 & (v613 >= 0 & v613 < 31) & (v201 >= 0))
replace select = . if C == 0

ta select
ed select

****** B.    Facteur de correction du poids echantionnal
/*N1= Effectif de la cible (C) dans la base initiale == 50016
N2:  Effectif de la cible (C) dans la base constituée ( taille de l’echantillion de C) == 11040
f=N1/N2 =  
Weight_cor=weight ancien* f*/
display 50016 / 11040
gen Weight_corr = wtpop * 4.5304348

* Save data
save DATA_Appended_2006_2018_Analysismerged, replace



******ESTIMATIONS
preserve 

keep if C == 1
****Variable de selection: age, education , ethnie, religion , milieu, region de residence

****no more children, were sterilized or declared infecund or provided numerical answers for fertility desire
ta select
ed select

recode RealisaAttentes_corr_new (1=2) (2=1), gen(RealisaAttentes_corr_new2)
/*mprobit RealisaAttentes_corr_new Education_femme Education_epoux Religion_group AgeFirstBirth_corr NumberUnion ModernContraception MediaExposure beating_justified ParticipationDecision , base(2)*/
mlogit RealisaAttentes_corr_new Education_femme Education_epoux Religion_group AgeFirstBirth_corr NumberUnion ModernContraception MediaExposure beating_justified ParticipationDecision , base(2)
 tab1 RealisaAttentes_corr_new RealisaAttentes_corr_new2

cmp (RealisaAttentes_corr_new = i.Education_femme i.Education_epoux i.Religion_group i.AgeFirstBirth_corr NumberUnion ModernContraception MediaExposure beating_justified ParticipationDecision)(select = Residence v024 i.Education_femme i.Religion_group Infecund Sterelized ChildLost_Exp NeverGiveBorn), ind( $cmp_mprobit $cmp_probit) nolr 

restore


 




