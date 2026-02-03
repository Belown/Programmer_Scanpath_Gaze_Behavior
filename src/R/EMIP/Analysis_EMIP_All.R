library(here)

source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))
source(file.path(here(), "src", "R", "auxiliary", "emip", "helper_emip.R"))

# "MultiMatch", "ScaSim", "NLD"

algo <- "MultiMatch"
cat("=========================================\n")
cat("Processing experiments for algorithm:", algo, "\n")
cat("=========================================\n")

within_stimulus_within_rectangle <- get_exp_pack_emip(data_set = "EMIP_corrected",
                                      exp_type = "within_stimulus",
                                      comp_type = "within_group",
                                      stimulus_folder = "rectangle",
                                      case = NULL,
                                      rand_effect = NULL,
                                      info = FALSE,
                                      reml = TRUE,
                                      algo = algo)
within_stimulus_within_vehicle <- get_exp_pack_emip(data_set = "EMIP_corrected",
                                      exp_type = "within_stimulus",
                                      comp_type = "within_group",
                                      stimulus_folder = "vehicle",
                                      case = NULL,
                                      rand_effect = NULL,
                                      info = FALSE,
                                      reml = TRUE,
                                      algo = algo)
within_stimulus_between_rectangle <- get_exp_pack_emip(data_set = "EMIP_corrected",
                                          exp_type = "within_stimulus",
                                          comp_type = "between_group",
                                          stimulus_folder = "rectangle",
                                          case = NULL,
                                          rand_effect = NULL,
                                          info=FALSE,
                                          reml=TRUE,
                                          algo = algo)
within_stimulus_between_vehicle <- get_exp_pack_emip(data_set = "EMIP_corrected",
                                                exp_type = "within_stimulus",
                                                comp_type = "between_group",
                                                stimulus_folder = "vehicle",
                                                case = NULL,
                                                rand_effect = NULL,
                                                info=FALSE,
                                                reml=TRUE,
                                                algo = algo)
within_group <- get_exp_pack_emip(data_set = "EMIP_corrected",
                             exp_type = "within_group",
                             comp_type = NULL,
                             stimulus_folder = NULL,
                             case = NULL,
                             rand_effect = NULL,
                             info = FALSE,
                             reml = TRUE,
                             algo = algo)
between_group_mean_diff <- get_exp_pack_emip(data_set = "EMIP_corrected",
                                        exp_type = "between_group",
                                        comp_type = NULL,
                                        stimulus_folder = NULL,
                                        case = "mean_diff",
                                        rand_effect = NULL,
                                        info = FALSE,
                                        reml = TRUE,
                                        algo = algo)
between_group_pairtype <- get_exp_pack_emip(data_set = "EMIP_corrected",
                                       exp_type = "between_group",
                                       comp_type = NULL,
                                       stimulus_folder = NULL,
                                       case = "pairtype",
                                       rand_effect = NULL,
                                       info = FALSE,
                                       reml = TRUE,
                                       algo = algo)

exps_list <- list(
  within_stimulus_within_rectangle = within_stimulus_within_rectangle,
  within_stimulus_within_vehicle = within_stimulus_within_vehicle,
  within_stimulus_between_rectangle = within_stimulus_between_rectangle,
  within_stimulus_between_vehicle = within_stimulus_between_vehicle,
  within_group = within_group,
  between_group_mean_diff = between_group_mean_diff,
  between_group_pairtype = between_group_pairtype
)

for (exp in names(exps_list)) {
  curr_exp <- exps_list[[exp]]
  sink_dir  <- dirname(curr_exp$config$results_log)
  assign_path(sink_dir)
  
  sink_file <- file.path(sink_dir, "console_output.txt")
  sink(sink_file, split = TRUE)
  tryCatch({
    cat("Processing model for experiment:", exp, "\n")
    work_flow_with_print(curr_exp$m_list, curr_exp$config)
    cat("✅️ Completed processing for experiment:", exp, "\n")
  }, finally = {
    sink()  # Ensure sink is closed even if an error occurs
  })
}