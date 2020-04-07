#' ks.get_benchmark
#'
#' Load benchmark results from csv file.
#'
#' @param benchmark_csv Path to csv file.
#' @return Benchmark data frame.
ks.get_benchmark = function(benchmark_csv = "benchmark1578929876.21765.csv"){
  benchmark = read.csv(benchmark_csv, stringsAsFactors = F)
  rownames(benchmark) = make.names(benchmark$method, unique = T)
  benchmark$method = rownames(benchmark)
  return(benchmark)
}
