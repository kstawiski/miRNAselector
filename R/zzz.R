.onAttach <- function(libname, pkgname) {
  options(rgl.useNULL = TRUE)
  suppressWarnings(suppressMessages(require("curl", character.only = TRUE)))
  suppressWarnings(suppressMessages(require("devtools", character.only = TRUE)))
  if(curl::has_internet()) {
    source_url("https://raw.githubusercontent.com/kstawiski/miRNAselector/master/vignettes/setup.R")
  }
  
  packageStartupMessage("Welcome to miRNAselector!\nAuthors: Konrad Stawiski M.D. (konrad@konsta.com.pl) and Marcin Kaszkowiak.\nFor more details go to https://kstawiski.github.io/miRNAselector/\n")
}

.onLoad <- function(libname, pkgname) {
  
  invisible(rownames(installed.packages()))
  }
