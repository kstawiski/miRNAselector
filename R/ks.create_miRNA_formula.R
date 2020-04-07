#' ks.create_miRNA_formula
#'
#' Helper function to create formula based on selected miRNAs.
#'
#' @param wybrane_miRy Selected miRNAs as characted vector.
#' @return Formula "Class ~ ..." to be used in another functions.
ks.create_miRNA_formula = function(wybrane_miRy) {
  as.formula(paste0("Class ~ ",paste0(as.character(wybrane_miRy), collapse = " + ")))
}
