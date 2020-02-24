### function for getting errors of the different networks over iterations and settings 

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
  return(out)
}