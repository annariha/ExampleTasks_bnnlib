# generate data with function that simulates frequencies 
sim.frequencies <- function(freqs, ts.len = 1000, num.seqs = 4) {
  seqset <- SequenceSet() 
  num.freqs <- length(freqs)
  for (j in 1:num.seqs) {
    x <- 1:ts.len
    y <- rep(NA, ts.len)
    truth <- matrix(0, nrow=ts.len, ncol=length(freqs))
    freq <- sample(freqs,1)
    for (i in 1:ts.len) {
      y[i] <- sin(x[i]*freq)
      if (runif(1)>.99) {
        freq <- sample(freqs,1)
      }
      truth[i, which(freqs==freq)] <- 1
    }
    seqdf <- data.frame(y, truth)
    seq <- toSequence(seqdf, 1, 2:(1+num.freqs))
    SequenceSet_add_copy_of_sequence(seqset, seq)
  }
  return(seqset)
}