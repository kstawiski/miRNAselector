.onAttach <- function(libname, pkgname) {
  # options(rgl.useNULL = TRUE)
  ks.setup(keras = FALSE, msg = FALSE)


  packageStartupMessage("\n\nWelcome to miRNAselector!\nAuthors: Konrad Stawiski M.D. (konrad@konsta.com.pl) and Marcin Kaszkowiak.\n\n\nYou can start with running ks.setup() to be sure that everything is properlly installed.\nFor more details go to https://kstawiski.github.io/miRNAselector/\n")
}

.onLoad <- function(libname, pkgname) {

}
