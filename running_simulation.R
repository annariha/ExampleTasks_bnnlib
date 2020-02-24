args <- commandArgs(trailingOnly = TRUE)

library(tictoc)
library(tidyverse)
library(gridExtra)
library(furrr)
library(readr)
library(fs)

conditions <- read_rds(args[[1]])

# setup for bnnlib 
setwd("/home/elli/Documents/Remote/Github/bnnlib/vignettes")
dyn.load(paste("../bnnlib", .Platform$dynlib.ext, sep=""))
source("../bnnlib.R")
cacheMetaData(1)
source("../R/toSequence.R")
source("../R/plotPredictions.R")
# sapply(list.files("../R/",full.names = TRUE), source)

# load functions for simulation 
setwd("/home/elli/Documents/Uni/Nebenjob/HiWi_MPIB_2019/ExampleTasks_bnnlib/")
source("gen_frequencies.R")
# source("get_errors.R")

# function for getting errors of the different networks over iterations and settings 

get_errors <- function(freqs, layers, cells, iteration, in_size=1, TANH_NODE=1, out_size=length(freqs), iter=c(500), ...) {
  dots <- list(...) # allows for adding of additional arguments 
  if(length(dots)>0) warning("Something seems odd.")
  
  # create data with different frequencies as specified in freqs 
  set.seed(123535)
  seqset <- sim.frequencies(freqs, num.seqs = 8)
  testset <- sim.frequencies(freqs)
  
  # build network 
  network = NetworkFactory_createRecurrentWTANetwork(in_size=in_size,
                                                     hid_type=TANH_NODE,
                                                     num_layers=layers,
                                                     layer_sizes=rep(cells,layers),
                                                     out_size=out_size);
  # initialize trainers and set learning rate 
  trainer = ImprovedRPropTrainer(network);
  Trainer_learning_rate_set(self = trainer, s_learning_rate = 0.0001)
  
  # train the networks 
  Trainer_train2(trainer, seqset, iterations = iter)
  setClass('_p_ImprovedRPropTrainer', contains=c('ExternalReference','_p_Trainer'))
  Trainer_add_abort_criterion__SWIG_0(self = trainer, 
                                      ConvergenceCriterion(0.01), 
                                      steps=10)
  
  # training error 
  train_x <- Trainer_error_train_get(trainer)
  # vector of length 500
  train_value <- .Call('R_swig_toValue', train_x, package="bnnlib") 
  
  # test error 
  # ...
  
  # store evaluation 
  trainerror <- cbind(unlist(train_value))
  # testerror <- ...
  out <- list(trainerror = data.frame(iter = seq_along(trainerror), trainerror = trainerror), 
              testerror = NA) 
  # browser()
  return(out)
}

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
  