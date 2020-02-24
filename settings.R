#! /usr/bin/Rscript --vanilla
args <- commandArgs(trailingOnly = TRUE)
if(length(args)==0L)stop("STOP! Please supply an argument.")

### packages 
library(here)
library(tidyverse)
library(fs)

### specify simulation conditions 
# different number of layers 
nr_layers <- c(2, 4, 6, 8)
# different number of cells per layer: try varieties of long and wide networks 
nr_cells <- c(2, 8) 
# each setting gets tested in 100 networks 
nr_iteration <- 1:100
# frequencies for generating data 
freqs <- list(c(50, 77, 91, 100))

# creating a grid of simulation conditions 800x4 
conditions <- crossing(
  layers = nr_layers, 
  cells = nr_cells, 
  iteration = nr_iteration,
  freqs = freqs
)

### functions for splitting 
split_equal <- function(data, k){
  split_equal <- seq_len(nrow(data))%%k
  data <- split(data, split_equal)
  names(data) <- seq_len(k)
  data
}

split_fair <- function(data, k, ...){
  # outer level split based on grouping, inner level k equal sized splits
  deep_split <- map(group_split(data, ...), split_equal, k)
  # outer level k equal sized splits, inner level splits based on grouping
  deep_split2 <- transpose(deep_split)
  # rebind
  fair <- map(deep_split2, bind_rows)
  fair
}

### split settings 
conditions <- split_fair(conditions, as.numeric(args[[1]]))

#----write-settings----
dir_create(here("data", "conditions"))
dir_walk(here("data", "conditions"), file_delete)
iwalk(conditions, ~write_rds(.x, here("data", "conditions", str_c(.y, ".rds"))))