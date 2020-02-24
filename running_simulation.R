#! /usr/bin/Rscript --vanilla

#----preparation----
args <- commandArgs(trailingOnly = TRUE)

if(!requireNamespace("pacman"))install.packages("pacman")
pacman::p_load(tictoc, tidyverse, gridExtra, furrr, fs, here)

conditions <- read_rds(args[[1]])

# setup for bnnlib 
dyn.load(paste(here("bnnlib"), .Platform$dynlib.ext, sep=""))
source(here("bnnlib", "bnnlib.R"))
cacheMetaData(1)
dir_walk(here("bnnlib", "R"), source)

# load functions for simulation 
source(here("gen_frequencies.R"))
source(here("get_errors.R"))

#----workhorse----
tic()
results <- 
  conditions %>% 
  sample_n(4) %>% 
  mutate(.,
    values_error = pmap(., get_errors)
    # values_error = future_pmap(., get_errors)
  )
toc()

# unnest results to get df matching conditions and 
# trainerrors for all iterations and models (800x500) 
# and testerrors for all 800 models
results <- results %>% mutate(testerror = map_dbl(values_error, "testerror"),
                   trainerror = map(values_error, "trainerror")) %>% 
  select(-values_error) %>% 
  unnest(cols = trainerror)

#----write-simulation----
dir_create(path_dir(args[[2]]))
write_rds(results, args[[2]])
  