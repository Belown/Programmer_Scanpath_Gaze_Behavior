library(lme4)
library(glmmTMB)
library(DHARMa)
library(ggplot2)
library(moments)
library(gridExtra)

#' 诊断lmer LMM模型并转换为不同分布族的GLMM
#' 
#' @param lmer_model 已拟合的lmer模型(lmerMod对象)
#' @param response_var 因变量名称(字符串,用于标签)
#' @return 包含最佳模型和诊断结果的列表
diag <- function(lmer_model, response_var = NULL) {
  
  # 检查输入是否为lmer模型
  if (!inherits(lmer_model, "lmerMod")) {
    stop("输入必须是lmer模型(lmerMod对象)")
  }
  
  # 提取数据 - lmer使用@符号
  data <- lmer_model@frame
  
  # 提取公式
  formula_orig <- formula(lmer_model)
  
  # 提取响应变量
  response_data <- model.response(data)
  
  # 如果没有提供response_var,从公式中提取
  if (is.null(response_var)) {
    response_var <- as.character(formula_orig[[2]])
  }
  
  # 1. 详细探索数据特征
  cat("\n=== 数据诊断 ===\n")
  cat("因变量:", response_var, "\n")
  cat("样本量:", length(response_data), "\n")
  cat("均值:", mean(response_data, na.rm = TRUE), "\n")
  cat("中位数:", median(response_data, na.rm = TRUE), "\n")
  cat("标准差:", sd(response_data, na.rm = TRUE), "\n")
  cat("偏度:", skewness(response_data, na.rm = TRUE), "\n")
  cat("峰度:", kurtosis(response_data, na.rm = TRUE), "\n")
  cat("范围:", paste(range(response_data, na.rm = TRUE), collapse = " to "), "\n")
  
  # 2. 可视化
  plot_data <- data.frame(response = response_data)
  
  p1 <- ggplot(plot_data, aes(x = response)) +
    geom_histogram(aes(y = after_stat(density)), bins = 50, 
                   fill = "steelblue", alpha = 0.7) +
    geom_density(color = "red", linewidth = 1) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "darkred") +
    labs(title = paste("Distribution of", response_var),
         x = response_var,
         y = "Density") +
    theme_minimal()
  
  p2 <- ggplot(plot_data, aes(sample = response)) +
    stat_qq() +
    stat_qq_line(color = "red") +
    labs(title = "Q-Q Plot",
         x = "Theoretical Quantiles",
         y = "Sample Quantiles") +
    theme_minimal()
  
  # lmer残差图
  p3 <- ggplot(data.frame(fitted = fitted(lmer_model), 
                          resid = residuals(lmer_model)),
               aes(x = fitted, y = resid)) +
    geom_point(alpha = 0.5) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
    geom_smooth(se = FALSE, color = "blue") +
    labs(title = "Residuals vs Fitted (LMM)",
         x = "Fitted values",
         y = "Residuals") +
    theme_minimal()
  
  print(grid.arrange(p1, p2, p3, ncol = 2))
  
  # 3. 转换为glmmTMB并拟合不同分布族
  cat("\n=== 转换为GLMM并拟合不同分布族 ===\n")
  models <- list()
  
  # 原始LMM作为基准(用glmmTMB重新拟合)
  tryCatch({
    models$gaussian_lmm <- glmmTMB(
      formula_orig,
      data = data,
      family = gaussian()
    )
    cat("✓ 正态分布 (LMM baseline)\n")
  }, error = function(e) {
    cat("✗ 正态分布失败:", conditionMessage(e), "\n")
  })
  
  # 学生t分布
  tryCatch({
    models$t <- glmmTMB(
      formula_orig,
      data = data,
      family = t_family(link = "identity")
    )
    cat("✓ 学生t分布\n")
  }, error = function(e) {
    cat("✗ 学生t分布失败:", conditionMessage(e), "\n")
  })
  
  # 偏斜正态
  tryCatch({
    models$skew <- glmmTMB(
      formula_orig,
      data = data,
      family = skewnormal(link = "identity")
    )
    cat("✓ 偏斜正态分布\n")
  }, error = function(e) {
    cat("✗ 偏斜正态分布失败:", conditionMessage(e), "\n")
  })
  
  # asinh转换 + 正态
  tryCatch({
    data_transformed <- data
    transformed_var <- paste0(response_var, "_asinh")
    data_transformed[[transformed_var]] <- asinh(response_data)
    
    # 构建新公式
    formula_str <- deparse(formula_orig)
    formula_asinh <- as.formula(gsub(response_var, transformed_var, formula_str))
    
    models$asinh <- glmmTMB(
      formula_asinh,
      data = data_transformed,
      family = gaussian()
    )
    cat("✓ asinh转换 + 正态分布\n")
  }, error = function(e) {
    cat("✗ asinh转换失败:", conditionMessage(e), "\n")
  })
  
  # 4. 模型比较
  cat("\n=== 模型比较 ===\n")
  
  # 添加原始lmer模型用于比较
  comparison <- data.frame(
    Model = c("lmer_original", names(models)),
    Family = c("gaussian (lmer)", sapply(models, function(m) family(m)$family)),
    AIC = c(AIC(lmer_model), sapply(models, AIC)),
    BIC = c(BIC(lmer_model), sapply(models, BIC)),
    LogLik = c(as.numeric(logLik(lmer_model)), 
               sapply(models, function(m) as.numeric(logLik(m)))),
    stringsAsFactors = FALSE
  )
  comparison <- comparison[order(comparison$AIC), ]
  rownames(comparison) <- NULL
  print(comparison)
  
  # 5. 残差诊断(对最佳glmmTMB模型)
  cat("\n=== 最佳模型残差诊断 ===\n")
  best_model_name <- comparison$Model[1]
  
  if (best_model_name == "lmer_original") {
    cat("最佳模型是原始LMM,无需转换为GLMM\n")
    cat("使用标准lmer诊断...\n\n")
    
    # lmer的标准诊断
    cat("固定效应:\n")
    print(fixef(lmer_model))
    
    cat("\n随机效应方差:\n")
    print(VarCorr(lmer_model))
    
    best_model <- lmer_model
    sim <- NULL
    
  } else {
    best_model <- models[[best_model_name]]
    
    cat("最佳模型:", best_model_name, 
        "(", comparison$Family[comparison$Model == best_model_name], ")\n", sep = "")
    cat("AIC:", comparison$AIC[1], "\n")
    cat("BIC:", comparison$BIC[1], "\n\n")
    
    # DHARMa残差诊断
    cat("生成模拟残差...\n")
    sim <- simulateResiduals(best_model, n = 250)
    
    cat("\n绘制残差图...\n")
    plot(sim, main = paste("Residuals for", best_model_name))
    
    cat("\n=== 残差检验 ===\n")
    
    cat("\n1. 离散度检验:\n")
    disp_test <- testDispersion(sim)
    print(disp_test)
    
    cat("\n2. 离群值检验:\n")
    outlier_test <- testOutliers(sim)
    print(outlier_test)
    
    cat("\n3. 均匀性检验:\n")
    unif_test <- testUniformity(sim)
    print(unif_test)
    
    # 查看摘要
    cat("\n=== 最佳模型摘要 ===\n")
    print(summary(best_model))
  }
  
  # 6. 基于偏度和峰度的推荐
  cat("\n=== 基于数据特征的推荐 ===\n")
  skew_val <- skewness(response_data, na.rm = TRUE)
  kurt_val <- kurtosis(response_data, na.rm = TRUE)
  
  if (abs(skew_val) > 1) {
    cat("偏度较大 (", round(skew_val, 2), "), 推荐: 偏斜正态分布\n", sep = "")
  } else if (kurt_val > 4) {
    cat("峰度较大 (", round(kurt_val, 2), "), 推荐: 学生t分布\n", sep = "")
  } else {
    cat("数据接近正态分布,原始LMM可能已足够\n")
  }
  
  # 返回结果
  invisible(list(
    original_lmer = lmer_model,
    best_model = best_model,
    best_model_name = best_model_name,
    all_glmm_models = models,
    comparison = comparison,
    residuals = sim,
    data_summary = list(
      mean = mean(response_data, na.rm = TRUE),
      sd = sd(response_data, na.rm = TRUE),
      skewness = skew_val,
      kurtosis = kurt_val
    )
  ))
}

library(lme4)
library(here)

source(file.path(here(), "src", "R", "workflow.R"))
source(file.path(here(), "src", "R", "models.R"))

# 获取lmer模型
base_path <- file.path(here(), "output", "processed_dataset")
exp_type <- "within_trial"
data_set <- "EMIP_corrected"
comp_type <- "between_group"
trial_folder <- "trial_5"

trial_level_path <- file.path(base_path, data_set, comp_type, trial_folder)
model_pack <- within_trial(trial_level_path)
model_list <- model_pack$models

# 诊断Shape维度的模型
result <- diag(model_list$Shape, "Shape")

# 查看结果
print(result$comparison)
summary(result$best_model)

# 如果需要使用最佳模型
best_model <- result$best_model
