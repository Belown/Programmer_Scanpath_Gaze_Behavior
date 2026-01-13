library(here)

source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))
source(file.path(here(), "src", "R", "auxiliary", "code_rendering", "helper_cr.R"))

fix_expertise <- get_exp_pack(dataset="code_rendering", exp_type="fix_expertise", case=NULL, rand_effect=NULL, info=TRUE, reml=TRUE)

fix_both <- get_exp_pack(dataset="code_rendering", exp_type="fix_expertise_rendering", case=NULL, rand_effect=NULL, info=TRUE, reml=TRUE)

fix_rendering_pairtype <- get_exp_pack(dataset="code_rendering", exp_type="fix_rendering", case="pairtype", rand_effect=NULL, info=TRUE, reml=TRUE)

fix_rendering_mean_diff <- get_exp_pack(dataset="code_rendering", exp_type="fix_rendering", case="mean_diff", rand_effect=NULL, info=TRUE, reml=TRUE)

exps_list <- list(
  fix_expertise = fix_expertise,
  fix_both = fix_both,
  fix_rendering_pairtype = fix_rendering_pairtype,
  fix_rendering_mean_diff = fix_rendering_mean_diff
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