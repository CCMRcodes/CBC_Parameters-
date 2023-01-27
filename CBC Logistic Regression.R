
# Logistic Regressions - generating C-statistics for each 90-day outcome and each CBC parameter

# Date Created: 2/28/22
# Author: Jennifer Cano

library(tidyverse)
library(rlang) 
library(haven) 
library(rms)
library(pROC)
library(lmtest)

setwd("insert working directory path here")

#import SAS data set of primary cohort with only complete data (no missing CBC parameters, including ratios) and save 
cbc_complete = read_sas("nameofdataset.sas7bdat")

### 90-day mortality or readmission ###

## Reduced Model (clinical base model) ##

base = lrm(formula = mort_readm_90 ~ age_cat + gender + icu_hosp + hosp_los +
               pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
               aod_liver_hosp + aod_lung_hosp + htn_prior540 +
               chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
               pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
               hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
               lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
               obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
               etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)


# c-stat - 0.6756
auc(cbc_complete$mort_readm_90, predict(base))


##  WBC  ##

full_wbc = lrm(formula = mort_readm_90 ~ rcs(final_wbc_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6781
auc(cbc_complete$mort_readm_90, predict(full_wbc))


##  HGB  ##

full_hgb = lrm(formula = mort_readm_90 ~ rcs(final_hemoglobin_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.684
auc(cbc_complete$mort_readm_90, predict(full_hgb))



##  Plate  ##

full_platelet = lrm(formula = mort_readm_90 ~ rcs(final_platelet_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6779
auc(cbc_complete$mort_readm_90, predict(full_platelet))



##  Neut  ##

full_neut = lrm(formula = mort_readm_90 ~ rcs(final_neut_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                   pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                   aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                   chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                   pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                   hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                   lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                   obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                   etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6793
auc(cbc_complete$mort_readm_90, predict(full_neut))



##  Lymph  ##

full_lymph = lrm(formula = mort_readm_90 ~ rcs(final_lymph_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                      pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                      aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                      chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                      pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                      hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                      lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                      obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                      etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6792
auc(cbc_complete$mort_readm_90, predict(full_lymph))



##  NLR  ##

full_nlr = lrm(formula = mort_readm_90 ~ rcs(final_nlr_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                   pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                   aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                   chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                   pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                   hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                   lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                   obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                   etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6823
auc(cbc_complete$mort_readm_90, predict(full_nlr))



##  PLR  ##

full_plr = lrm(formula = mort_readm_90 ~ rcs(final_plr_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6774
auc(cbc_complete$mort_readm_90, predict(full_plr))




##  SII  ##

full_sii = lrm(formula = mort_readm_90 ~ rcs(final_sii_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6798
auc(cbc_complete$mort_readm_90, predict(full_sii))



##  Model with all CBC parameters  ##

full_all_cbc = lrm(formula = mort_readm_90 ~ rcs(final_wbc_hosp, 4) + rcs(final_hemoglobin_hosp, 4) +
                     rcs(final_platelet_hosp, 4) + rcs(final_neut_hosp, 4) + rcs(final_lymph_hosp, 4) +
                     rcs(final_nlr_hosp, 4) + rcs(final_plr_hosp, 4) + rcs(final_sii_hosp, 4) +
                     age_cat + gender + icu_hosp + hosp_los + pressor_in_72hr + aod_heme_hosp +
                     aod_kidney_hosp + aod_lactate_hosp + aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                     chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                     pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                     hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                     lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                     obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                     etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6929
auc(cbc_complete$mort_readm_90, predict(full_all_cbc))



### 90-day mortality ###

## Reduced Model (clinical base model) ##

base = lrm(formula = follby_mort90 ~ age_cat + gender + icu_hosp + hosp_los +
             pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
             aod_liver_hosp + aod_lung_hosp + htn_prior540 +
             chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
             pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
             hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
             lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
             obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
             etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

#print(summary(base))

# c-stat - 0.759
auc(cbc_complete$follby_mort90, predict(base))


##  WBC  ##

full_wbc = lrm(formula = follby_mort90 ~ rcs(final_wbc_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.7658
auc(cbc_complete$follby_mort90, predict(full_wbc))



##  HGB  ##

full_hgb = lrm(formula = follby_mort90 ~ rcs(final_hemoglobin_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.7673
auc(cbc_complete$follby_mort90, predict(full_hgb))


##  Plate  ##

full_platelet = lrm(formula = follby_mort90 ~ rcs(final_platelet_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                      pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                      aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                      chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                      pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                      hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                      lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                      obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                      etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.7656
auc(cbc_complete$follby_mort90, predict(full_platelet))



##  Neut  ##

full_neut = lrm(formula = follby_mort90 ~ rcs(final_neut_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                  pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                  aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                  chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                  pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                  hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                  lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                  obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                  etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.7698
auc(cbc_complete$follby_mort90, predict(full_neut))



##  Lymph  ##

full_lymph = lrm(formula = follby_mort90 ~ rcs(final_lymph_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                   pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                   aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                   chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                   pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                   hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                   lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                   obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                   etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.7666
auc(cbc_complete$follby_mort90, predict(full_lymph))



##  NLR  ##

full_nlr = lrm(formula = follby_mort90 ~ rcs(final_nlr_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.7772
auc(cbc_complete$follby_mort90, predict(full_nlr))



##  PLR  ##

full_plr = lrm(formula = follby_mort90 ~ rcs(final_plr_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.7621
auc(cbc_complete$follby_mort90, predict(full_plr))



##  SII  ##

full_sii = lrm(formula = follby_mort90 ~ rcs(final_sii_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.7678
auc(cbc_complete$follby_mort90, predict(full_sii))



##  Model with all CBC parameters  ##

full_all_cbc = lrm(formula = follby_mort90 ~ rcs(final_wbc_hosp, 4) + rcs(final_hemoglobin_hosp, 4) +
                     rcs(final_platelet_hosp, 4) + rcs(final_neut_hosp, 4) + rcs(final_lymph_hosp, 4) +
                     rcs(final_nlr_hosp, 4) + rcs(final_plr_hosp, 4) + rcs(final_sii_hosp, 4) +
                     age_cat + gender + icu_hosp + hosp_los + pressor_in_72hr + aod_heme_hosp +
                     aod_kidney_hosp + aod_lactate_hosp + aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                     chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                     pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                     hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                     lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                     obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                     etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.7936
auc(cbc_complete$follby_mort90, predict(full_all_cbc))



### 90-day readmission (all-cause) ###

## Reduced Model (clinical base model) ##

base = lrm(formula = follby_readm90_vapd ~ age_cat + gender + icu_hosp + hosp_los +
             pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
             aod_liver_hosp + aod_lung_hosp + htn_prior540 +
             chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
             pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
             hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
             lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
             obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
             etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

#print(summary(base))

# c-stat - 0.6318
auc(cbc_complete$follby_readm90_vapd, predict(base))


##  WBC  ##

full_wbc = lrm(formula = follby_readm90_vapd ~ rcs(final_wbc_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6323
auc(cbc_complete$follby_readm90_vapd, predict(full_wbc))


##  HGB  ##

full_hgb = lrm(formula = follby_readm90_vapd ~ rcs(final_hemoglobin_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat - 0.6386
auc(cbc_complete$follby_readm90_vapd, predict(full_hgb))


##  Plate  ##

full_platelet = lrm(formula = follby_readm90_vapd ~ rcs(final_platelet_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                      pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                      aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                      chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                      pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                      hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                      lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                      obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                      etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6326
auc(cbc_complete$follby_readm90_vapd, predict(full_platelet))


##  Neut  ##

full_neut = lrm(formula = follby_readm90_vapd ~ rcs(final_neut_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                  pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                  aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                  chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                  pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                  hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                  lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                  obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                  etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6322
auc(cbc_complete$follby_readm90_vapd, predict(full_neut))


##  Lymph  ##

full_lymph = lrm(formula = follby_readm90_vapd ~ rcs(final_lymph_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                   pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                   aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                   chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                   pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                   hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                   lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                   obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                   etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6324
auc(cbc_complete$follby_readm90_vapd, predict(full_lymph))


##  NLR  ##

full_nlr = lrm(formula = follby_readm90_vapd ~ rcs(final_nlr_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6323
auc(cbc_complete$follby_readm90_vapd, predict(full_nlr))


##  PLR  ##

full_plr = lrm(formula = follby_readm90_vapd ~ rcs(final_plr_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6324
auc(cbc_complete$follby_readm90_vapd, predict(full_plr))



##  SII  ##

full_sii = lrm(formula = follby_readm90_vapd ~ rcs(final_sii_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6323
auc(cbc_complete$follby_readm90_vapd, predict(full_sii))



##  Model with all CBC parameters  ##

full_all_cbc = lrm(formula = follby_readm90_vapd ~ rcs(final_wbc_hosp, 4) + rcs(final_hemoglobin_hosp, 4) +
                     rcs(final_platelet_hosp, 4) + rcs(final_neut_hosp, 4) + rcs(final_lymph_hosp, 4) +
                     rcs(final_nlr_hosp, 4) + rcs(final_plr_hosp, 4) + rcs(final_sii_hosp, 4) +
                     age_cat + gender + icu_hosp + hosp_los + pressor_in_72hr + aod_heme_hosp +
                     aod_kidney_hosp + aod_lactate_hosp + aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                     chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                     pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                     hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                     lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                     obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                     etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6406
auc(cbc_complete$follby_readm90_vapd, predict(full_all_cbc))




### 90-day readmission (potential infection) ###

## Reduced Model (clinical base model) ##

base = lrm(formula = follby_readm90_happi ~ age_cat + gender + icu_hosp + hosp_los +
             pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
             aod_liver_hosp + aod_lung_hosp + htn_prior540 +
             chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
             pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
             hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
             lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
             obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
             etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

#print(summary(base))

# c-stat - 0.6289
auc(cbc_complete$follby_readm90_happi, predict(base))


##  WBC  ##

full_wbc = lrm(formula = follby_readm90_happi ~ rcs(final_wbc_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6313
auc(cbc_complete$follby_readm90_happi, predict(full_wbc))



##  HGB  ##

full_hgb = lrm(formula = follby_readm90_happi ~ rcs(final_hemoglobin_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat - 0.6322
auc(cbc_complete$follby_readm90_happi, predict(full_hgb))


##  Plate  ##

full_platelet = lrm(formula = follby_readm90_happi ~ rcs(final_platelet_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                      pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                      aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                      chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                      pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                      hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                      lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                      obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                      etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6306
auc(cbc_complete$follby_readm90_happi, predict(full_platelet))


##  Neut  ##

full_neut = lrm(formula = follby_readm90_happi ~ rcs(final_neut_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                  pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                  aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                  chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                  pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                  hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                  lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                  obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                  etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6307
auc(cbc_complete$follby_readm90_happi, predict(full_neut))



##  Lymph  ##

full_lymph = lrm(formula = follby_readm90_happi ~ rcs(final_lymph_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                   pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                   aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                   chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                   pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                   hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                   lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                   obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                   etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.63
auc(cbc_complete$follby_readm90_happi, predict(full_lymph))



##  NLR  ##

full_nlr = lrm(formula = follby_readm90_happi ~ rcs(final_nlr_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6296
auc(cbc_complete$follby_readm90_happi, predict(full_nlr))



##  PLR  ##

full_plr = lrm(formula = follby_readm90_happi ~ rcs(final_plr_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6298
auc(cbc_complete$follby_readm90_happi, predict(full_plr))



##  SII  ##

full_sii = lrm(formula = follby_readm90_happi ~ rcs(final_sii_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6299
auc(cbc_complete$follby_readm90_happi, predict(full_sii))



##  Model with all CBC parameters  ##

full_all_cbc = lrm(formula = follby_readm90_happi ~ rcs(final_wbc_hosp, 4) + rcs(final_hemoglobin_hosp, 4) +
                     rcs(final_platelet_hosp, 4) + rcs(final_neut_hosp, 4) + rcs(final_lymph_hosp, 4) +
                     rcs(final_nlr_hosp, 4) + rcs(final_plr_hosp, 4) + rcs(final_sii_hosp, 4) +
                     age_cat + gender + icu_hosp + hosp_los + pressor_in_72hr + aod_heme_hosp +
                     aod_kidney_hosp + aod_lactate_hosp + aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                     chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                     pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                     hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                     lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                     obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                     etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6406
auc(cbc_complete$follby_readm90_happi, predict(full_all_cbc))



### 90-day readmission (sepsis) ###

## Reduced Model (clinical base model) ##

base = lrm(formula = follby_readm90_sepsis ~ age_cat + gender + icu_hosp + hosp_los +
             pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
             aod_liver_hosp + aod_lung_hosp + htn_prior540 +
             chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
             pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
             hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
             lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
             obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
             etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

#print(summary(base))

# c-stat - 0.6381
auc(cbc_complete$follby_readm90_sepsis, predict(base))


##  WBC  ##

full_wbc = lrm(formula = follby_readm90_sepsis ~ rcs(final_wbc_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6405
auc(cbc_complete$follby_readm90_sepsis, predict(full_wbc))



##  HGB  ##

full_hgb = lrm(formula = follby_readm90_sepsis ~ rcs(final_hemoglobin_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat - 0.6445
auc(cbc_complete$follby_readm90_sepsis, predict(full_hgb))



##  Plate  ##

full_platelet = lrm(formula = follby_readm90_sepsis ~ rcs(final_platelet_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                      pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                      aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                      chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                      pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                      hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                      lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                      obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                      etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6414
auc(cbc_complete$follby_readm90_sepsis, predict(full_platelet))


##  Neut  ##

full_neut = lrm(formula = follby_readm90_sepsis ~ rcs(final_neut_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                  pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                  aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                  chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                  pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                  hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                  lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                  obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                  etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6403
auc(cbc_complete$follby_readm90_sepsis, predict(full_neut))



##  Lymph  ##

full_lymph = lrm(formula = follby_readm90_sepsis ~ rcs(final_lymph_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                   pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                   aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                   chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                   pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                   hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                   lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                   obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                   etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6386
auc(cbc_complete$follby_readm90_sepsis, predict(full_lymph))



##  NLR  ##

full_nlr = lrm(formula = follby_readm90_sepsis ~ rcs(final_nlr_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6388
auc(cbc_complete$follby_readm90_sepsis, predict(full_nlr))



##  PLR  ##

full_plr = lrm(formula = follby_readm90_sepsis ~ rcs(final_plr_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6388
auc(cbc_complete$follby_readm90_sepsis, predict(full_plr))




##  SII  ##

full_sii = lrm(formula = follby_readm90_sepsis ~ rcs(final_sii_hosp, 4) + age_cat + gender + icu_hosp + hosp_los +
                 pressor_in_72hr + aod_heme_hosp + aod_kidney_hosp + aod_lactate_hosp +
                 aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6392
auc(cbc_complete$follby_readm90_sepsis, predict(full_sii))



##  Model with all CBC parameters  ##

full_all_cbc = lrm(formula = follby_readm90_sepsis ~ rcs(final_wbc_hosp, 4) + rcs(final_hemoglobin_hosp, 4) +
                 rcs(final_platelet_hosp, 4) + rcs(final_neut_hosp, 4) + rcs(final_lymph_hosp, 4) +
                 rcs(final_nlr_hosp, 4) + rcs(final_plr_hosp, 4) + rcs(final_sii_hosp, 4) +
                 age_cat + gender + icu_hosp + hosp_los + pressor_in_72hr + aod_heme_hosp +
                 aod_kidney_hosp + aod_lactate_hosp + aod_liver_hosp + aod_lung_hosp + htn_prior540 +
                 chf_prior540 + cardic_arrhym_prior540 + valvular_d2_prior540 + pulm_circ_prior540 +
                 pvd_prior540 + paralysis_prior540 + neuro_prior540 + pulm_prior540 + dm_uncomp_prior540 + dm_comp_prior540 +
                 hypothyroid_prior540 + renal_prior540 + liver_prior540 + pud_prior540 + ah_prior540 +
                 lymphoma_prior540 + cancer_met_prior540 + cancer_nonmet_prior540 + ra_prior540 + coag_prior540 +
                 obesity_prior540 + wtloss_prior540 + fen_prior540 + anemia_cbl_prior540 + anemia_def_prior540 +
                 etoh_prior540 + drug_prior540 + psychoses_prior540 + depression_prior540, data = cbc_complete)

# c-stat -  0.6503
auc(cbc_complete$follby_readm90_sepsis, predict(full_all_cbc))

