library(here)
source(file.path(here(), "src", "R", "auxiliary", "helper.R"))

random_effect = "(1 | exp_a) + (1 | exp_b)"
info = FALSE

within_trial_within_2 <- get_exp_pack("within_trial", "EMIP_corrected", "within_group", "trial_2", "", random_effect, info, reml = TRUE)
within_trial_within_5 <- get_exp_pack("within_trial", "EMIP_corrected", "within_group", "trial_5", "", random_effect, info, reml = TRUE)
within_trial_between_2 <- get_exp_pack("within_trial", "EMIP_corrected", "between_group", "trial_2", "", random_effect, info, reml = TRUE)
within_trial_between_5 <- get_exp_pack("within_trial", "EMIP_corrected", "between_group", "trial_5", "", random_effect, info, reml = TRUE)
within_group <- get_exp_pack("within_group", "EMIP_corrected", "", "", "", random_effect, info, reml = TRUE)
between_group_mean_diff <- get_exp_pack("between_group", "EMIP_corrected", "", "", "mean_diff", random_effect, info, reml = TRUE)
between_group_pairtype <- get_exp_pack("between_group", "EMIP_corrected", "", "", "pairtype", random_effect, info, reml = TRUE)