# load packages
if(!requireNamespace("pacman"))install.packages("pacman")
pacman::p_load(tictoc, tidyverse, gridExtra, fs, here)

# load data from results folder and bind it together by rows
# results <- readRDS(list.files(path = here("data", "results"), pattern = ".rds"))
# results <- list.files(path = here("data", "results"), pattern = ".rds") %>%
#   readRDS()

results <- list.files(path = here("data", "results"), pattern = ".rds") %>%
  map_dfr(readRDS)

# plot trainerror over iterations for different settings
# using facet_wrap() with rows: nr of cells and columns: nr of layers
ggplot(results, aes(x=iter, y=trainerror)) + 
  geom_line() + 
  facet_grid(rows = vars(cells), 
             cols = vars(layers),
             labeller = label_both,
             scales = "fixed") +
  labs(title = "Training Error", 
       subtitle = "Networks with different Nr of Layers and Cells") +
  theme_bw()