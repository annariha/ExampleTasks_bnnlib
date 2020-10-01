#! /usr/bin/Rscript --vanilla

#----preparation----
args <- commandArgs(trailingOnly = TRUE)

if(!requireNamespace("pacman"))install.packages("pacman")
pacman::p_load(tictoc, tidyverse, gridExtra, fs, here)

conditions <- read_rds(args[[1]])

# setup for bnnlib 
dyn.load(here("bnnlib", str_c("bnnlib", .Platform$dynlib.ext)))
source(here("bnnlib", "bnnlib.R"))
cacheMetaData(1)
# dir_walk(here("bnnlib", "R"), source)
source(here("bnnlib", "R", "toSequence.R"))

# load functions for simulation 
source(here("sim_gen_frequencies.R"))
source(here("sim_get_errors.R"))

#----workhorse----
conditions <- sample_n(conditions, 2)

tic()
results <- pmap(conditions, get_errors)
toc()

results <- 
  mutate(conditions,
    values_error = results
  )

# unnest results to get df matching conditions and 
# trainerrors for all iterations and models (800x500) 
# and testerrors for all 800 models
results$testerror <- map_dbl(results$values_error, "testerror")
results$trainerror <- lapply(map(results$values_error, "trainerror"), as.data.frame)
results$values_error <- NULL
results <- unnest(results, cols = trainerror)

#----write-simulation----
dir_create(path_dir(args[[2]]))
write_rds(results, args[[2]])
  