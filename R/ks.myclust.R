#' ks.myclust
#'
#' Helper in heatmap creation. Which method of cultering should be used?
#'
#' @export
ks.myclust=function(c) {hclust(c,method="average")}
