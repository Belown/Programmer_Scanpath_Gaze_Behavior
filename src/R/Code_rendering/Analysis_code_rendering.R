# =========================================================
# Analysis Script for Mixed Effects Models
# =========================================================
# This script performs statistical analysis using linear mixed effects models
# (LMM) and generalized linear mixed effects models (GLMM) for experimental data.
# =========================================================

library(here)
library(performance)

# Load auxiliary functions for model building and validation workflow
source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))
source(file.path(here(), "src", "R", "auxiliary", "code_rendering", "models_cr.R"))

dimensions <- c("Shape", "Length", "Direction", "Position", "Duration")

# --- Experiment Type Configuration ---
data_set <- "code_rendering"  # Dataset identifier

exp_type <- "fix_expertise" #Options: "fix_expertise", "fix_expertise_rendering", "fix_rendering"

base_path <- file.path(here(), "output", "processed_dataset")

case <- "pairtype"

folder_path <- file.path(base_path, data_set, exp_type)

formula_set <- list(
  fix_effect = "render_a + render_b",
  rand_effect = "(1 | exp_a) + (1 | exp_b)"
)

exp_pack <- get_model_pack(folder_path, formula_set, info = TRUE, reml = TRUE, test = FALSE, dataset = data_set, case=case)


# Extract components from model package
folder_path <- exp_pack$folder_path  # Output folder path
dataframe <- exp_pack$data           # Processed dataset

# 拟合交互模型
model_interaction <- glmmTMB(
  Direction ~ render_a * render_b + (1 | exp_a) + (1 | exp_b),
  data = dataframe,
  family = gaussian()
)

# 拟合加法模型
model_additive <- glmmTMB(
  Direction ~ render_a + render_b + (1 | exp_a) + (1 | exp_b),
  data = dataframe,
  family = gaussian()
)

# 似然比检验
lrt_result <- anova(model_additive, model_interaction)
print(lrt_result)

# 提取AIC/BIC
AIC(model_interaction, model_additive)
BIC(model_interaction, model_additive)

# 检查秩亏缺
summary(model_interaction)  # 查看NA参数

# 最终模型诊断
library(DHARMa)
sim_res <- simulateResiduals(model_additive, n = 1000)
plot(sim_res)

# 最终模型结果
summary(model_additive)
