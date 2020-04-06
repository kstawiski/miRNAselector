#' ks.table
#'
#' A wrapper to draw pretty tables in rmarkdown document
#'
#' @param table Table to draw.
#' @param hight High (default: 400px)
ks.table = function(table, height = "400px")
{
  suppressMessages(library(knitr))
  suppressMessages(library(rmarkdown))
  suppressMessages(library(kableExtra))
  kable(table, "html") %>%
    kable_styling() %>%
    scroll_box(width = "100%", height = height)
}
