library(lme4)
library(here)

source(file.path(here(), "src", "R", "auxiliary", "workflow.R"))
source(file.path(here(), "src", "R", "auxiliary", "helper.R"))
source(file.path(here(), "src", "R", "auxiliary", "test_helper.R"))

test_random_effects()