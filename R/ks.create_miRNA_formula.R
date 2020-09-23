#' ks.create_miRNA_formula
#'
#' Helper function to create formula based on selected miRNAs.
#'
#' @param wybrane_miRy Selected miRNAs as characted vector.
#' @return Formula "Class ~ ..." to be used in another functions.
#'
#' @export
ks.create_miRNA_formula = function(wybrane_miRy) {
  wybrane_miRy<-wybrane_miRy[!is.na(wybrane_miRy)]
  as.formula(paste0("Class ~ ",paste0(as.character(wybrane_miRy), collapse = " + ")))
}
