.onAttach <- function(libname, pkgname) {
  options(rgl.useNULL = TRUE)
  #ks.setup(keras = FALSE, msg = FALSE)

  suppressMessages(suppressWarnings(library(devtools)))
  suppressMessages(suppressWarnings(library(curl)))
  if(curl::has_internet()) {
  source_url("https://raw.githubusercontent.com/kstawiski/miRNAselector/master/vignettes/setup.R") }


  packageStartupMessage("\n\nWelcome to miRNAselector!\nAuthors: Konrad Stawiski M.D. (konrad@konsta.com.pl) and Marcin Kaszkowiak.\n\n\nYou can start with running ks.setup() to be sure that everything is properlly installed.\nFor more details go to https://kstawiski.github.io/miRNAselector/\n")
}

.onLoad <- function(libname, pkgname) {

}
