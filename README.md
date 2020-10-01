# simulation-freq-bnnlib

This repository contains R-code for running a simulation study on a Tardis Cluster and was developed as part of my work as a student assistant for Andreas Brandmaier in cooperation with Aaron Peikert at MPIB (Max-Planck Institute of Human Development) in Berlin, see https://github.com/aaronpeikert/maketest for the general idea developed by Aaron Peikert.

`bnnlib` is a R-package (under development as of Sept, 2020) by Andreas Brandmaier that allows the flexible creation of different neural network models in R. The above code requires a version of `bnnlib` in the project folder. See how to install `bnnlib` here: https://github.com/brandmaier/bnnlib

One of the examples in the `bnnlib` vignettes aims at predicting different frequencies e.g. of some oscillating object (see `frequencies.Rmd` in `bnnlib/vignettes/`). 

This example was extended here to test the influence of different number of layers and different number of cells per layer on training and test errors. 
