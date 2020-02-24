FROM rocker/verse:3.6.2
ARG BUILD_DATE=2020-02-24
RUN install2.r --error --skipinstalled\
  pacman tictoc tidyverse gridExtra furrr fs here
WORKDIR /home/rstudio
