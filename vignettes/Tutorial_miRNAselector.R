#options(warn = -1)
suppressMessages(library(foreach))
suppressMessages(library(doParallel))
suppressMessages(library(parallel))
suppressMessages(library(doSNOW))

m = 1:56 # which methods to check?

cl <- makeCluster(5) # We do not recommend using more than 5 threads, beacuse some of the methods inhereditly use multicore processing.
registerDoSNOW(cl)
on.exit(stopCluster(cl))
iterations = length(m)
pb <- txtProgressBar(max = iterations, style = 3)
progress <- function(n) setTxtProgressBar(pb, n)
opts <- list(progress = progress)
foreach(i = m, .options.snow = opts) %dopar%
{
  suppressMessages(library(miRNAselector))
  # setwd("/miRNAselector/miRNAselector/vignettes") # change it you to your working directory
  ks.miRNAselector(m = i, max_iterations = 1, stamp = "tutorial", debug = F, # we set debug to false (to make the package smaller), you may also want to change stamp to something meaningful, max_iterations was set to 1 to recude the computational time.. in real life scenarios it is resonable to use at least 10 iterations.
                  prefer_no_features = 11, # Few methods are filter rather than wrapper methods, thus requires the maximum number of maximum features.
                  conda_path = "/opt/conda/bin/conda", # Methods line WxNet requires usage of python. In setup script we create conda enviorment. Providing conda_path makes it easier to activate env. We prefer this apporach over use_condaenv.
                  timeout = 600) # We don't want to wait eternity in this tutorial, just 10 minutes. Timeout is useful for complicated methods. Depending on your CPU 2 days may be reasonable for larger projects. Note that some methods cannot be controled with timeout parameter.
}

stopCluster(cl)
#options(warn = 0)
