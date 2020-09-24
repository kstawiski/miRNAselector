  
options(warn = -1)
if(file.exists("task.log")) { file.remove("task.log") }
con <- file("task.log")
sink(con, append=TRUE)
sink(con, append=TRUE, type = "message")

library(miRNAselector)

mm = read.csv("selected_benchmark.csv")
m = as.character(mm$m) # which methods to check?

mxnet = ifelse(readLines("var_mxnet.txt", warn = F) == "TRUE", TRUE, FALSE)
search_iters_mxnet = as.numeric(readLines("var_search_iters_mxnet.txt", warn = F))
search_iters = as.numeric(readLines("var_search_iters.txt", warn = F))
holdout = ifelse(readLines("var_holdout.txt", warn = F) == "TRUE", TRUE, FALSE)

ks.benchmark(
  wd = getwd(),
  search_iters = search_iters,
  keras_epochs = 5000,
  keras_threads = floor(parallel::detectCores()/2),
  search_iters_mxnet = search_iters_mxnet,
  cores = detectCores() - 1,
  input_formulas = readRDS("featureselection_formulas_final.RDS"),
  output_file = "benchmark.csv",
  mxnet = mxnet,
  gpu = F,
  algorithms = m,
  holdout = holdout,
  stamp = "mirnaselector"
)

cat("[miRNAselector: TASK COMPLETED]")
sink() 
sink(type = "message")