#' ks.myclust
#'
#' Helper in heatmap creation. Which method of cultering should be used?
ks.myclust=function(c) {hclust(c,method="average")}
