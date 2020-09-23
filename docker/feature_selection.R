options(warn = -1)
con <- file("task.log")
sink(con, append=F)
sink(con, append=F, type="message")

library(miRNAselector)
suppressMessages(library(foreach))
suppressMessages(library(doParallel))
suppressMessages(library(parallel))
suppressMessages(library(doParallel))

mm = read.csv("selected_methods.csv")
m = as.numeric(mm$m) # which methods to check?

cl <- makePSOCKcluster(useXDR = TRUE, 3) # We do not recommend using more than 5 threads, beacuse some of the methods inhereditly use multicore processing.
registerDoParallel(cl)

# Choose number of iterations
n <- length(m)

# Progress combine function
f <- function(iterator){
  pb <- txtProgressBar(min = 1, max = iterator - 1, style = 3)
  count <- 0
  function(...) {
    count <<- count + length(list(...)) - 1
    setTxtProgressBar(pb, count)
    flush.console()
    cbind(...) # this can feed into .combine option of foreach
  }
}


foreach(i = m, .combine = f(n)) %dopar%
{
  suppressMessages(library(miRNAselector))
  prefer_no_features = readLines("var_prefer_no_features.txt", warn = F)
  max_iterations = readLines("var_max_iterations.txt", warn = F)
  timeout_sec = readLines("var_timeout_sec.txt", warn = F)
  # setwd("/miRNAselector/miRNAselector/vignettes") # change it you to your working directory
  con <- file("task.log")
  sink(con, append=T)
  sink(con, append=T, type="message")
  ks.miRNAselector(m = i, max_iterations = 1, stamp = "fs", debug = F, # we set debug to false (to make the package smaller), you may also want to change stamp to something meaningful, max_iterations was set to 1 to recude the computational time.. in real life scenarios it is resonable to use at least 10 iterations.
                  prefer_no_features = prefer_no_features, # Few methods are filter rather than wrapper methods, thus requires the maximum number of maximum features.    
                  timeout_sec = timeout_sec) # We don't want to wait eternity in this tutorial, just 10 minutes. Timeout is useful for complicated methods. Depending on your CPU 2 days may be reasonable for larger projects. Note that some methods cannot be controled with timeout parameter.
  sink() 
  sink(type="message")
}
stopCluster(cl)

prefer_no_features = readLines("var_prefer_no_features.txt", warn = F)
selected_sets_of_miRNAs = ks.merge_formulas(max_miRNAs = prefer_no_features)

cat("[miRNAselector: TASK COMPLETED]")
sink() 
sink(type="message")
