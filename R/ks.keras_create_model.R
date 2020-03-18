#' ks.keras_create_model
#'
#' Helper function for `ks.deep_learning()`
ks.keras_create_model <- function(i, hyperparameters, how_many_features = ncol(x_train_scale)) {
  # tempmodel <- keras_model_sequential() %>%
  #   { if(hyperparameters[i,10]==T) { layer_dense(. , units = hyperparameters[i,1], kernel_regularizer = regularizer_l2(l = 0.001),
  #                                                activation = hyperparameters[i,4], input_shape = c(ncol(x_train_scale))) } else
  #                                  { layer_dense(. , units = hyperparameters[i,1], activation = hyperparameters[i,4],
  #                                                                input_shape = c(ncol(x_train_scale))) } } %>%
  #   { if(hyperparameters[i,7]>0) { layer_dropout(. , rate = hyperparameters[i,7]) } else { . } } %>%
  #   { if(hyperparameters[i,2]>0) {
  #   if(hyperparameters[i,11]==T) { layer_dense(. , units = hyperparameters[i,2], activation = hyperparameters[i,5],
  #               kernel_regularizer = regularizer_l2(l = 0.001)) } else {
  #                 layer_dense(units = hyperparameters[i,2], activation = hyperparameters[i,5]) } } }  %>%
  #   { if(hyperparameters[i,8]>0) { layer_dropout(rate = hyperparameters[i,8]) } else { . } } %>%
  #   { if(hyperparameters[i,3]>0) {
  #   if(hyperparameters[i,12]==T) { layer_dense(units = hyperparameters[i,3], activation = hyperparameters[i,6],
  #                                                kernel_regularizer = regularizer_l2(l = 0.001)) } else
  #                                   {layer_dense(units = hyperparameters[i,3], activation = hyperparameters[i,6])} } else { . } } %>%
  #   { if(hyperparameters[i,9]>0) { layer_dropout(rate = hyperparameters[i,9]) } else { . } } %>%
  #   layer_dense(units = 1, activation = 'sigmoid')
  library(keras)
  tempmodel <- keras_model_sequential()
  if(hyperparameters[i,10]==T) { layer_dense(tempmodel , units = hyperparameters[i,1], kernel_regularizer = regularizer_l2(l = 0.001),
                                             activation = hyperparameters[i,4], input_shape = c(how_many_features)) } else
                                             { layer_dense(tempmodel , units = hyperparameters[i,1], activation = hyperparameters[i,4],
                                                           input_shape = c(how_many_features)) }
  if(hyperparameters[i,7]>0) { layer_dropout(tempmodel , rate = hyperparameters[i,7]) }
  if(hyperparameters[i,2]>0) {
    if(hyperparameters[i,11]==T) { layer_dense(tempmodel , units = hyperparameters[i,2], activation = hyperparameters[i,5],
                                               kernel_regularizer = regularizer_l2(l = 0.001)) } else
                                               {layer_dense(tempmodel, units = hyperparameters[i,2], activation = hyperparameters[i,5]) } }

  if(hyperparameters[i,2]>0 & hyperparameters[i,8]>0) { layer_dropout(tempmodel, rate = hyperparameters[i,8]) }
  if(hyperparameters[i,3]>0) {
    if(hyperparameters[i,12]==T) { layer_dense(tempmodel, units = hyperparameters[i,3], activation = hyperparameters[i,6],
                                               kernel_regularizer = regularizer_l2(l = 0.001)) } else
                                               { layer_dense(tempmodel, units = hyperparameters[i,3], activation = hyperparameters[i,6])} }
  if(hyperparameters[i,3]>0 & hyperparameters[i,9]>0) { layer_dropout(rate = hyperparameters[i,9]) }
  layer_dense(tempmodel, units = 2, activation = 'softmax')

  print(tempmodel)


  dnn_class_model = keras::compile(tempmodel, optimizer = hyperparameters[i,13],
                                   loss = 'binary_crossentropy',
                                   metrics = 'accuracy')

}
