#' ks.deep_learning
#'
#' Finding the best deep feed-forward neural network.
#' To be described fully...
#'
#'
#'
#' @export
ks.deep_learning = function(selected_miRNAs = ".", wd = getwd(),
                            SMOTE = F, keras_batch_size = 64, clean_temp_files = T,
                            save_threshold_trainacc = 0.85, save_threshold_testacc = 0.8, keras_epochae = 5000,
                            keras_epoch = 2000, keras_patience = 50,
                            hyperparameters = expand.grid(layer1 = seq(3,11, by = 2), layer2 = c(0,seq(3,11, by = 2)), layer3 = c(0,seq(3,11, by = 2)),
                                                          activation_function_layer1 = c("relu","sigmoid"), activation_function_layer2 = c("relu","sigmoid"), activation_function_layer3 = c("relu","sigmoid"),
                                                          dropout_layer1 = c(0, 0.1), dropout_layer2 = c(0, 0.1), dropout_layer3 = c(0),
                                                          layer1_regularizer = c(T,F), layer2_regularizer = c(T,F), layer3_regularizer = c(T,F),
                                                          optimizer = c("adam","rmsprop","sgd"), autoencoder = c(0,7,-7), balanced = SMOTE, formula = as.character(ks.create_miRNA_formula(selected_miRNAs))[3], scaled = c(T,F),
                                                          stringsAsFactors = F), miRNAselector_docker_set = TRUE,
                            keras_threads = ceiling(parallel::detectCores()/2), start = 1, end = nrow(hyperparameters), output_file = "deeplearning_results.csv", save_all_vars = F)
{
  suppressMessages(library(plyr))
  suppressMessages(library(dplyr))
  suppressMessages(library(edgeR))
  suppressMessages(library(epiDisplay))
  suppressMessages(library(rsq))
  suppressMessages(library(MASS))
  suppressMessages(library(Biocomb))
  suppressMessages(library(caret))
  suppressMessages(library(dplyr))
  suppressMessages(library(epiDisplay))
  suppressMessages(library(pROC))
  suppressMessages(library(ggplot2))
  suppressMessages(library(DMwR))
  suppressMessages(library(ROSE))
  suppressMessages(library(gridExtra))
  suppressMessages(library(gplots))
  suppressMessages(library(devtools))
  suppressMessages(library(stringr))
  suppressMessages(library(data.table))
  suppressMessages(library(tidyverse))
  codename = sub(pattern = "(.*)\\..*$", replacement = "\\1", basename(output_file))
  #options(warn=-1)
  oldwd = getwd()
  setwd = setwd(wd)
  set.seed(1)
  temp_dir = tempdir()
  options(bitmapType = 'cairo', device = 'png')
  suppressMessages(library(dplyr))
  suppressMessages(library(keras))
  suppressMessages(library(plyr))
  suppressMessages(library(foreach))
  suppressMessages(library(doParallel))
  suppressMessages(library(data.table))
  fwrite(hyperparameters, paste0("hyperparameters_",output_file))

  dane = ks.load_datamix(wd = wd, replace_smote = F); train = dane[[1]]; test = dane[[2]]; valid = dane[[3]]; train_smoted = dane[[4]]; trainx = dane[[5]]; trainx_smoted = dane[[6]]
  if (SMOTE == T) { train = train_smoted }

  #cores=detectCores()
  cat(paste0("\nTemp dir: ", temp_dir, "\n"))
  cat("\nStarting preparing cluster..\n")
  #cl <- makePSOCKcluster(useXDR = FALSE, keras_threads) #not to overload your computer
  cl = makePSOCKcluster(useXDR = FALSE, keras_threads, outfile=paste0("temp/", ceiling(as.numeric(Sys.time())), "deeplearning_cluster.log"))
  suppressMessages(library(doParallel))
   registerDoParallel(cl)
  # on.exit(stopCluster(cl))
  cat("\nCluster prepared..\n")



  #args= names(mget(ls()))
  #export = export[!export %in% args]

  # tu musi isc iteracja
  cat(paste0("\nStarting parallel loop.. There are: ", end-start+1, " hyperparameter sets to be checked.\n"))
  final <- foreach(i=as.numeric(start):as.numeric(end), .combine=rbind, .verbose=TRUE, .inorder=FALSE
                   ,.errorhandling="remove", .export = ls(), .packages = loadedNamespaces()
  ) %dopar% {


    if(miRNAselector_docker_set) {
      reticulate::use_python('/opt/conda/bin/python')

      require(tensorflow)
      require(reticulate)
      require(keras)

      is_keras_available()
      Sys.setenv(TENSORFLOW_PYTHON='/opt/conda/bin/python')
      use_python('/opt/conda/bin/python')

      py_discover_config('tensorflow')
      py_discover_config('keras')

    }

    start_time <- Sys.time()
    suppressMessages(library(keras))
    suppressMessages(library(ggplot2))
    suppressMessages(library(dplyr))
    suppressMessages(library(data.table))
    set.seed(1)

    cat("\nStarting hyperparameters..\n")
    print(hyperparameters[i,])
    source("/home/konrad/snorlax/helpers/ks_miRNAhelpers.R")
    options(bitmapType = 'cairo', device = 'png')
    model_id = paste0(format(i, scientific = FALSE), "-", ceiling(as.numeric(Sys.time())))
    if(SMOTE == T) { model_id = paste0(format(i, scientific = FALSE), "-SMOTE-", ceiling(as.numeric(Sys.time()))) }
    tempwyniki = data.frame(model_id=model_id)
    tempwyniki[1, "model_id"] = model_id


    if(!dir.exists(paste0(temp_dir,"/models"))) { dir.create(paste0(temp_dir,"/models"))}
    if(!dir.exists(paste0(temp_dir,"/models/keras",model_id))) { dir.create(paste0(temp_dir,"/models/keras",model_id))}
    cat(paste0("\nTraining model: ",temp_dir,"/models/keras",model_id,"\n"))
    #pdf(paste0(temp_dir,"/models/keras",model_id,"/plots.pdf"), paper="a4")

    con <- file(paste0(temp_dir,"/models/keras",model_id,"/training.log"))
    sink(con, append=TRUE)
    sink(con, append=TRUE, type="message")

    early_stop <- callback_early_stopping(monitor = "val_loss", mode="min", patience = keras_patience)
    cp_callback <- callback_model_checkpoint(
      filepath =  paste0(temp_dir,"/models/keras",model_id,"/finalmodel.hdf5"),
      save_best_only = TRUE, period = 5, monitor = "val_loss",
      verbose = 0
    )
    ae_cp_callback <- callback_model_checkpoint(
      filepath =  paste0(temp_dir,"/models/keras",model_id,"/autoencoderweights.hdf5"),
      save_best_only = TRUE, save_weights_only = T, period = 5, monitor = "val_loss",
      verbose = 0
    )

    x_train <- train %>%
      { if (selected_miRNAs != ".") { dplyr::select(., selected_miRNAs) } else { dplyr::select(., starts_with("hsa")) } } %>%
      as.matrix()
    y_train <- train %>%
      dplyr::select("Class") %>%
      as.matrix()
    y_train[,1] = ifelse(y_train[,1] == "Cancer",1,0)


    x_test <- test %>%
      { if (selected_miRNAs != ".") { dplyr::select(.,selected_miRNAs) } else { dplyr::select(.,starts_with("hsa")) } } %>%
      as.matrix()
    y_test <- test %>%
      dplyr::select("Class") %>%
      as.matrix()
    y_test[,1] = ifelse(y_test[,1] == "Cancer",1,0)

    x_valid <- valid %>%
      { if (selected_miRNAs != ".") { dplyr::select(.,selected_miRNAs) } else { dplyr::select(.,starts_with("hsa")) } } %>%
      as.matrix()
    y_valid <- valid %>%
      dplyr::select("Class") %>%
      as.matrix()
    y_valid[,1] = ifelse(y_valid[,1] == "Cancer",1,0)

    if(hyperparameters[i, 17] == T) {
      x_train_scale = x_train %>% scale()

      col_mean_train <- attr(x_train_scale, "scaled:center")
      col_sd_train <- attr(x_train_scale, "scaled:scale")

      x_test_scale <- x_test %>%
        scale(center = col_mean_train,
              scale = col_sd_train)

      x_valid_scale <- x_valid %>%
        scale(center = col_mean_train,
              scale = col_sd_train)
    }
    else {
      x_train_scale = x_train
      x_test_scale <- x_test
      x_valid_scale <- x_valid
    }

    input_layer <- layer_input(shape = c(ncol(x_train_scale)))

    #psych::describe(x_test_scale)

    # czy autoenkoder?
    if(hyperparameters[i,14] != 0) {


      n1 <- hyperparameters[i,14]
      n3 <- ncol(x_train_scale)

      if (hyperparameters[i,14]>0) {
        encoder <-
          input_layer %>%
          #layer_dense(units = ceiling(n3/2), activation = hyperparameters[i,6])    %>%
          layer_dense(units = n1, activation = "sigmoid")  # dimensions of final encoding layer

        decoder <- encoder %>%
          #layer_dense(units = ceiling(n3/2), activation = hyperparameters[i,6]) %>%
          layer_dense(units = n3, hyperparameters[i,6])  # dimension of original variable
      }
      else {
        n1 = -n1
        encoder <-
          input_layer %>%
          layer_dense(units = n1, activation = "sigmoid")  # dimensions of final encoding layer

        decoder <- encoder %>%
          layer_dense(units = n3, hyperparameters[i,6])  # dimension of original variable
      }
      ae_model <- keras_model(inputs = input_layer, outputs = decoder)
      ae_model

      ae_model %>%
        keras::compile(loss = "mean_absolute_error",
                       optimizer = hyperparameters[i,13],
                       metrics = c("mean_squared_error"))

      summary(ae_model)



      #ae_tempmodelfile = tempfile()
      ae_history <- fit(ae_model, x = x_train_scale,
                        y = x_train_scale,
                        epochs = keras_epochae, batch_size = keras_batch_size,
                        shuffle = T, verbose = 0,
                        view_metrics = FALSE,
                        validation_data = list(x_test_scale, x_test_scale),
                        callbacks = list(ae_cp_callback, early_stop))
      #file.copy(ae_tempmodelfile, paste0(temp_dir,"/models/keras",model_id,"/finalmodel.hdf5"), overwrite = T)

      ae_history_df <- as.data.frame(ae_history)
      fwrite(ae_history_df, paste0(temp_dir,"/models/keras",model_id,"/autoencoder_history_df.csv.gz"))

      compare_cx <- data.frame(
        train_loss = ae_history$metrics$loss,
        test_loss = ae_history$metrics$val_loss
      ) %>%
        tibble::rownames_to_column() %>%
        mutate(rowname = as.integer(rowname)) %>%
        tidyr::gather(key = "type", value = "value", -rowname)

      plot1 = ggplot(compare_cx, aes(x = rowname, y = value, color = type)) +
        geom_line() +
        xlab("epoch") +
        ylab("loss") +
        theme_bw()


      ggplot2::ggsave(file = paste0(temp_dir,"/models/keras",model_id,"/training_autoencoder.png"), grid.arrange(plot1, nrow =1, top = "Training of autoencoder"))

      cat("\n- Reloading autoencoder to get weights...\n")
      encoder_model <- keras_model(inputs = input_layer, outputs = encoder)
      encoder_model %>% load_model_weights_hdf5(paste0(temp_dir,"/models/keras",model_id,"/autoencoderweights.hdf5"),
                                                skip_mismatch = T,
                                                by_name = T)

      cat("\n- Autoencoder saving...\n")
      save_model_hdf5(encoder_model, paste0(temp_dir,"/models/keras",model_id,"/autoencoder.hdf5"))


      cat("\n- Creating deep features...\n")

      ae_x_train_scale <- encoder_model %>%
        predict(x_train_scale) %>%
        as.matrix()
      fwrite(ae_x_train_scale, paste0(temp_dir,"/models/keras",model_id,"/deepfeatures_train.csv"))

      ae_x_test_scale <- encoder_model %>%
        predict(x_test_scale) %>%
        as.matrix()
      fwrite(ae_x_test_scale, paste0(temp_dir,"/models/keras",model_id,"/deepfeatures_test.csv"))

      ae_x_valid_scale <- encoder_model %>%
        predict(x_valid_scale) %>%
        as.matrix()
      fwrite(ae_x_valid_scale, paste0(temp_dir,"/models/keras",model_id,"/deepfeatures_valid.csv"))

      # # podmiana żeby nie edytować kodu
      x_train_scale = as.matrix(ae_x_train_scale)
      x_test_scale = as.matrix(ae_x_test_scale)
      x_valid_scale = as.matrix(ae_x_valid_scale)

      cat("\n- Training model based on deep features...\n")
      dnn_class_model <- ks.keras_create_model(i, hyperparameters = hyperparameters, how_many_features = ncol(x_train_scale))

      #tempmodelfile = tempfile()
      history <- fit(dnn_class_model, x = x_train_scale,
                     y = to_categorical(y_train),
                     epochs = keras_epoch,
                     validation_data = list(x_test_scale, to_categorical(y_test)),
                     callbacks = list(cp_callback, early_stop),
                     verbose = 0,
                     view_metrics = FALSE,
                     batch_size = keras_batch_size, shuffle = T)
      print(history)
      #plot(history, col="black")
      history_df <- as.data.frame(history)
      fwrite(history_df, paste0(temp_dir,"/models/keras",model_id,"/history_df.csv.gz"))

      cat("\n- Saving history and plots...\n")
      compare_cx <- data.frame(
        train_loss = history$metrics$loss,
        test_loss = history$metrics$val_loss
      ) %>%
        tibble::rownames_to_column() %>%
        mutate(rowname = as.integer(rowname)) %>%
        tidyr::gather(key = "type", value = "value", -rowname)

      plot1 = ggplot(compare_cx, aes(x = rowname, y = value, color = type)) +
        geom_line() +
        xlab("Epoch") +
        ylab("Loss") +
        theme_bw()

      compare_cx <- data.frame(
        train_accuracy = history$metrics$accuracy,
        test_accuracy = history$metrics$val_accuracy
      ) %>%
        tibble::rownames_to_column() %>%
        mutate(rowname = as.integer(rowname)) %>%
        tidyr::gather(key = "type", value = "value", -rowname)

      plot2 = ggplot(compare_cx, aes(x = rowname, y = value, color = type)) +
        geom_line() +
        xlab("Epoch") +
        ylab("Accuracy") +
        theme_bw()

      ggplot2::ggsave(file = paste0(temp_dir,"/models/keras",model_id,"/training.png"), grid.arrange(plot1, plot2, nrow =2, top = "Training of final neural network"))

      # ewaluacja
      cat("\n- Saving final model...\n")
      dnn_class_model = load_model_hdf5(paste0(temp_dir,"/models/keras",model_id,"/finalmodel.hdf5"))
      y_train_pred <- predict(object = dnn_class_model, x = x_train_scale)
      y_test_pred <- predict(object = dnn_class_model, x = x_test_scale)
      y_valid_pred <- predict(object = dnn_class_model, x = x_valid_scale)


      # wybranie odciecia
      pred = data.frame(`Class` = train$Class, `Pred` = y_train_pred)
      suppressMessages(library(cutpointr))
      cutoff = cutpointr(pred, Pred.2, Class, pos_class = "Cancer", metric = youden)
      summary(cutoff)
      ggplot2::ggsave(file = paste0(temp_dir,"/models/keras",model_id,"/cutoff.png"), plot(cutoff))
      wybrany_cutoff = cutoff$optimal_cutpoint
      #wyniki[i, "training_AUC"] = cutoff$AUC
      tempwyniki[1, "training_AUC"] = cutoff$AUC
      #wyniki[i, "cutoff"] = wybrany_cutoff
      tempwyniki[1, "cutoff"] = wybrany_cutoff
      cat(paste0("\n\n---- TRAINING AUC: ",cutoff$AUC," ----\n\n"))
      cat(paste0("\n\n---- OPTIMAL CUTOFF: ",wybrany_cutoff," ----\n\n"))
      cat(paste0("\n\n---- TRAINING PERFORMANCE ----\n\n"))
      pred$PredClass = ifelse(pred$Pred.2 >= wybrany_cutoff, "Cancer", "Control")
      pred$PredClass = factor(pred$PredClass, levels = c("Control","Cancer"))
      cm_train = caret::confusionMatrix(pred$PredClass, pred$Class, positive = "Cancer")
      print(cm_train)

      t1_roc = pROC::roc(Class ~ as.numeric(Pred.2), data=pred)
      tempwyniki[1, "training_AUC2"] = t1_roc$auc
      tempwyniki[1, "training_AUC_lower95CI"] = as.character(ci(t1_roc))[1]
      tempwyniki[1, "training_AUC_upper95CI"] = as.character(ci(t1_roc))[3]
      saveRDS(t1_roc, paste0(temp_dir,"/models/keras",model_id,"/training_ROC.RDS"))

      tempwyniki[1, "training_Accuracy"] = cm_train$overall[1]
      tempwyniki[1, "training_Sensitivity"] = cm_train$byClass[1]
      tempwyniki[1, "training_Specificity"] = cm_train$byClass[2]
      tempwyniki[1, "training_PPV"] = cm_train$byClass[3]
      tempwyniki[1, "training_NPV"] = cm_train$byClass[4]
      tempwyniki[1, "training_F1"] = cm_train$byClass[7]
      saveRDS(cm_train, paste0(temp_dir,"/models/keras",model_id,"/cm_train.RDS"))

      cat(paste0("\n\n---- TESTING PERFORMANCE ----\n\n"))
      pred = data.frame(`Class` = test$Class, `Pred` = y_test_pred)
      pred$PredClass = ifelse(pred$Pred.2 >= wybrany_cutoff, "Cancer", "Control")
      pred$PredClass = factor(pred$PredClass, levels = c("Control","Cancer"))
      cm_test = caret::confusionMatrix(pred$PredClass, pred$Class, positive = "Cancer")
      print(cm_test)
      tempwyniki[1, "test_Accuracy"] = cm_test$overall[1]
      tempwyniki[1, "test_Sensitivity"] = cm_test$byClass[1]
      tempwyniki[1, "test_Specificity"] = cm_test$byClass[2]
      tempwyniki[1, "test_PPV"] = cm_test$byClass[3]
      tempwyniki[1, "test_NPV"] = cm_test$byClass[4]
      tempwyniki[1, "test_F1"] = cm_test$byClass[7]
      saveRDS(cm_test, paste0(temp_dir,"/models/keras",model_id,"/cm_test.RDS"))

      cat(paste0("\n\n---- VALIDATION PERFORMANCE ----\n\n"))
      pred = data.frame(`Class` = valid$Class, `Pred` = y_valid_pred)
      pred$PredClass = ifelse(pred$Pred.2 >= wybrany_cutoff, "Cancer", "Control")
      pred$PredClass = factor(pred$PredClass, levels = c("Control","Cancer"))
      cm_valid = caret::confusionMatrix(pred$PredClass, pred$Class, positive = "Cancer")
      print(cm_valid)
      tempwyniki[1, "valid_Accuracy"] = cm_test$overall[1]
      tempwyniki[1, "valid_Sensitivity"] = cm_test$byClass[1]
      tempwyniki[1, "valid_Specificity"] = cm_test$byClass[2]
      tempwyniki[1, "valid_PPV"] = cm_test$byClass[3]
      tempwyniki[1, "valid_NPV"] = cm_test$byClass[4]
      tempwyniki[1, "valid_F1"] = cm_test$byClass[7]
      saveRDS(cm_valid, paste0(temp_dir,"/models/keras",model_id,"/cm_valid.RDS"))

      mix = rbind(train,test,valid)
      mixx = rbind(x_train_scale, x_test_scale, x_valid_scale)
      y_mixx_pred <- predict(object = dnn_class_model, x = mixx)

      mix$Podzial = c(rep("Training",nrow(train)),rep("Test",nrow(test)),rep("Validation",nrow(valid)))
      mix$Pred = y_mixx_pred[,2]
      mix$PredClass = ifelse(mix$Pred >= wybrany_cutoff, "Cancer", "Control")
      fwrite(mix, paste0(temp_dir,"/models/keras",model_id,"/data_predictions.csv.gz"))
      fwrite(cbind(hyperparameters[i,], tempwyniki), paste0(temp_dir,"/models/keras",model_id,"/wyniki.csv"))

      wagi = get_weights(dnn_class_model)
      saveRDS(wagi, paste0(temp_dir,"/models/keras",model_id,"/finalmodel_weights.RDS"))
      save_model_weights_hdf5(dnn_class_model, paste0(temp_dir,"/models/keras",model_id,"/finalmodel_weights.hdf5"))
      saveRDS(dnn_class_model, paste0(temp_dir,"/models/keras",model_id,"/finalmodel.RDS"))

      # czy jest sens zapisywac?
      #sink()
      #sink(type="message")
      cat(paste0("\n\n== ",model_id, ": ", tempwyniki[1, "training_Accuracy"], " / ", tempwyniki[1, "test_Accuracy"], " ==> ", tempwyniki[1, "training_Accuracy"]>save_threshold_trainacc & tempwyniki[1, "test_Accuracy"]>save_threshold_testacc))
      if(tempwyniki[1, "training_Accuracy"]>save_threshold_trainacc & tempwyniki[1, "test_Accuracy"]>save_threshold_testacc) {
        # zapisywanie modelu do właściwego katalogu
        if (save_all_vars) { save(list = ls(all=TRUE), file = paste0(temp_dir,"/models/keras",model_id,"/all.Rdata.gz"), compress = "gzip", compression_level = 9) }
        if(!dir.exists(paste0("models/",codename,"/"))) { dir.create(paste0("models/",codename,"/")) }
        zip(paste0("models/",codename,"/",codename, "_", model_id,".zip"),list.files(paste0(temp_dir,"/models/keras",model_id), full.names = T, recursive = T, include.dirs = T))
        # file.copy(list.files(paste0(temp_dir,"/models/keras",model_id), pattern = "_wyniki.csv$", full.names = T, recursive = T, include.dirs = T),paste0("temp/",codename,"_",model_id,"_deeplearningresults.csv"))
        if (!dir.exists(paste0("temp/",codename,"/"))) { dir.create(paste0("temp/",codename,"/")) }
        file.copy(list.files(paste0(temp_dir,"/models/keras",model_id), pattern = "_wyniki.csv$", full.names = T, recursive = T, include.dirs = T),paste0("temp/",codename,"/",model_id,"_deeplearningresults.csv"))
        #dev.off()
      }
    } else {
      x_train <- train %>%
        { if (selected_miRNAs != ".") { dplyr::select(.,selected_miRNAs) } else { dplyr::select(.,starts_with("hsa")) } } %>%
        as.matrix()
      y_train <- train %>%
        dplyr::select("Class") %>%
        as.matrix()
      y_train[,1] = ifelse(y_train[,1] == "Cancer",1,0)


      x_test <- test %>%
        { if (selected_miRNAs != ".") { dplyr::select(.,selected_miRNAs) } else { dplyr::select(.,starts_with("hsa")) } } %>%
        as.matrix()
      y_test <- test %>%
        dplyr::select("Class") %>%
        as.matrix()
      y_test[,1] = ifelse(y_test[,1] == "Cancer",1,0)

      x_valid <- valid %>%
        { if (selected_miRNAs != ".") { dplyr::select(.,selected_miRNAs) } else { dplyr::select(.,starts_with("hsa")) } } %>%
        as.matrix()
      y_valid <- valid %>%
        dplyr::select("Class") %>%
        as.matrix()
      y_valid[,1] = ifelse(y_valid[,1] == "Cancer",1,0)

      if(hyperparameters[i, 17] == T) {
        x_train_scale = x_train %>% scale()

        col_mean_train <- attr(x_train_scale, "scaled:center")
        col_sd_train <- attr(x_train_scale, "scaled:scale")

        x_test_scale <- x_test %>%
          scale(center = col_mean_train,
                scale = col_sd_train)

        x_valid_scale <- x_valid %>%
          scale(center = col_mean_train,
                scale = col_sd_train)
      }
      else {
        x_train_scale = x_train
        x_test_scale <- x_test
        x_valid_scale <- x_valid
      }


      dnn_class_model <- ks.keras_create_model(i, hyperparameters = hyperparameters, how_many_features = ncol(x_train_scale))

      history <-  fit(dnn_class_model, x = x_train_scale,
                      y = to_categorical(y_train),
                      epochs = keras_epoch,
                      validation_data = list(x_test_scale, to_categorical(y_test)),
                      callbacks = list(
                        cp_callback,
                        #callback_reduce_lr_on_plateau(monitor = "val_loss", factor = 0.1),
                        #callback_model_checkpoint(paste0(temp_dir,"/models/keras",model_id,"/finalmodel.hdf5")),
                        early_stop),
                      verbose = 0,
                      view_metrics = FALSE,
                      batch_size = keras_batch_size, shuffle = T)
      print(history)
      #plot(history, col="black")
      history_df <- as.data.frame(history)
      fwrite(history_df, paste0(temp_dir,"/models/keras",model_id,"/history_df.csv.gz"))

      # pdf(paste0(temp_dir,"/models/keras",model_id,"/plots.pdf"))
      compare_cx <- data.frame(
        train_loss = history$metrics$loss,
        test_loss = history$metrics$val_loss
      ) %>%
        tibble::rownames_to_column() %>%
        mutate(rowname = as.integer(rowname)) %>%
        tidyr::gather(key = "type", value = "value", -rowname)

      plot1 = ggplot(compare_cx, aes(x = rowname, y = value, color = type)) +
        geom_line() +
        xlab("epoch") +
        ylab("loss") +
        theme_bw()

      compare_cx <- data.frame(
        train_accuracy = history$metrics$accuracy,
        test_accuracy = history$metrics$val_accuracy
      ) %>%
        tibble::rownames_to_column() %>%
        mutate(rowname = as.integer(rowname)) %>%
        tidyr::gather(key = "type", value = "value", -rowname)

      plot2 = ggplot(compare_cx, aes(x = rowname, y = value, color = type)) +
        geom_line() +
        xlab("epoch") +
        ylab("loss") +
        theme_bw()

      ggplot2::ggsave(file = paste0(temp_dir,"/models/keras",model_id,"/training.png"), grid.arrange(plot1, plot2, nrow =2, top = "Training of final neural network"))

      # ewaluacja
      dnn_class_model = load_model_hdf5(paste0(temp_dir,"/models/keras",model_id,"/finalmodel.hdf5"))
      y_train_pred <- predict(object = dnn_class_model, x = x_train_scale)
      y_test_pred <- predict(object = dnn_class_model, x = x_test_scale)
      y_valid_pred <- predict(object = dnn_class_model, x = x_valid_scale)


      # wybranie odciecia
      pred = data.frame(`Class` = train$Class, `Pred` = y_train_pred)
      suppressMessages(library(cutpointr))
      cutoff = cutpointr(pred, Pred.2, Class, pos_class = "Cancer", metric = youden)
      print(summary(cutoff))
      ggplot2::ggsave(file = paste0(temp_dir,"/models/keras",model_id,"/cutoff.png"), plot(cutoff))
      wybrany_cutoff = cutoff$optimal_cutpoint
      #wyniki[i, "training_AUC"] = cutoff$AUC
      tempwyniki[1, "training_AUC"] = cutoff$AUC
      #wyniki[i, "cutoff"] = wybrany_cutoff
      tempwyniki[1, "cutoff"] = wybrany_cutoff

      cat(paste0("\n\n---- TRAINING PERFORMANCE ----\n\n"))
      pred$PredClass = ifelse(pred$Pred.2 >= wybrany_cutoff, "Cancer", "Control")
      pred$PredClass = factor(pred$PredClass, levels = c("Control","Cancer"))
      cm_train = caret::confusionMatrix(pred$PredClass, pred$Class, positive = "Cancer")
      print(cm_train)

      t1_roc = pROC::roc(Class ~ as.numeric(Pred.2), data=pred)
      tempwyniki[1, "training_AUC2"] = t1_roc$auc
      tempwyniki[1, "training_AUC_lower95CI"] = as.character(ci(t1_roc))[1]
      tempwyniki[1, "training_AUC_upper95CI"] = as.character(ci(t1_roc))[3]
      saveRDS(t1_roc, paste0(temp_dir,"/models/keras",model_id,"/training_ROC.RDS"))
      #ggplot2::ggsave(file = paste0(temp_dir,"/models/keras",model_id,"/training_ROC.png"), grid.arrange(plot(t1_roc), nrow =1, top = "Training ROC curve"))

      tempwyniki[1, "training_Accuracy"] = cm_train$overall[1]
      tempwyniki[1, "training_Sensitivity"] = cm_train$byClass[1]
      tempwyniki[1, "training_Specificity"] = cm_train$byClass[2]
      tempwyniki[1, "training_PPV"] = cm_train$byClass[3]
      tempwyniki[1, "training_NPV"] = cm_train$byClass[4]
      tempwyniki[1, "training_F1"] = cm_train$byClass[7]
      saveRDS(cm_train, paste0(temp_dir,"/models/keras",model_id,"/cm_train.RDS"))

      cat(paste0("\n\n---- TESTING PERFORMANCE ----\n\n"))
      pred = data.frame(`Class` = test$Class, `Pred` = y_test_pred)
      pred$PredClass = ifelse(pred$Pred.2 >= wybrany_cutoff, "Cancer", "Control")
      pred$PredClass = factor(pred$PredClass, levels = c("Control","Cancer"))
      cm_test = caret::confusionMatrix(pred$PredClass, pred$Class, positive = "Cancer")
      print(cm_test)
      tempwyniki[1, "test_Accuracy"] = cm_test$overall[1]
      tempwyniki[1, "test_Sensitivity"] = cm_test$byClass[1]
      tempwyniki[1, "test_Specificity"] = cm_test$byClass[2]
      tempwyniki[1, "test_PPV"] = cm_test$byClass[3]
      tempwyniki[1, "test_NPV"] = cm_test$byClass[4]
      tempwyniki[1, "test_F1"] = cm_test$byClass[7]
      saveRDS(cm_test, paste0(temp_dir,"/models/keras",model_id,"/cm_test.RDS"))

      cat(paste0("\n\n---- VALIDATION PERFORMANCE ----\n\n"))
      pred = data.frame(`Class` = valid$Class, `Pred` = y_valid_pred)
      pred$PredClass = ifelse(pred$Pred.2 >= wybrany_cutoff, "Cancer", "Control")
      pred$PredClass = factor(pred$PredClass, levels = c("Control","Cancer"))
      cm_valid = caret::confusionMatrix(pred$PredClass, pred$Class, positive = "Cancer")
      print(cm_valid)
      tempwyniki[1, "valid_Accuracy"] = cm_test$overall[1]
      tempwyniki[1, "valid_Sensitivity"] = cm_test$byClass[1]
      tempwyniki[1, "valid_Specificity"] = cm_test$byClass[2]
      tempwyniki[1, "valid_PPV"] = cm_test$byClass[3]
      tempwyniki[1, "valid_NPV"] = cm_test$byClass[4]
      tempwyniki[1, "valid_F1"] = cm_test$byClass[7]
      saveRDS(cm_valid, paste0(temp_dir,"/models/keras",model_id,"/cm_valid.RDS"))

      mix = rbind(train,test,valid)
      mixx = rbind(x_train_scale, x_test_scale, x_valid_scale)
      y_mixx_pred <- predict(object = dnn_class_model, x = mixx)

      mix$Podzial = c(rep("Training",nrow(train)),rep("Test",nrow(test)),rep("Validation",nrow(valid)))
      mix$Pred = y_mixx_pred[,2]
      mix$PredClass = ifelse(mix$Pred >= wybrany_cutoff, "Cancer", "Control")
      fwrite(mix, paste0(temp_dir,"/models/keras",model_id,"/data_predictions.csv.gz"))
      fwrite(cbind(hyperparameters[i,], tempwyniki), paste0(temp_dir,"/models/keras",model_id,"/",model_id,"_wyniki.csv"))

      wagi = get_weights(dnn_class_model)
      saveRDS(wagi, paste0(temp_dir,"/models/keras",model_id,"/finalmodel_weights.RDS"))
      save_model_weights_hdf5(dnn_class_model, paste0(temp_dir,"/models/keras",model_id,"/finalmodel_weights.hdf5"))
      saveRDS(dnn_class_model, paste0(temp_dir,"/models/keras",model_id,"/finalmodel.RDS"))


      # czy jest sens zapisywac?

      cat(paste0("\n\n== ",model_id, ": ", tempwyniki[1, "training_Accuracy"], " / ", tempwyniki[1, "test_Accuracy"], " ==> ", tempwyniki[1, "training_Accuracy"]>save_threshold_trainacc & tempwyniki[1, "test_Accuracy"]>save_threshold_testacc))
      if(tempwyniki[1, "training_Accuracy"]>save_threshold_trainacc & tempwyniki[1, "test_Accuracy"]>save_threshold_testacc) {
        # zapisywanie modelu do właściwego katalogu
        if (save_all_vars) { save(list = ls(all=TRUE), file = paste0(temp_dir,"/models/keras",model_id,"/all.Rdata.gz"), compress = "gzip", compression_level = 9) }
        if(!dir.exists(paste0("models/",codename,"/"))) { dir.create(paste0("models/",codename,"/")) }
        zip(paste0("models/",codename,"/",codename, "_", model_id,".zip"),list.files(paste0(temp_dir,"/models/keras",model_id), full.names = T, recursive = T, include.dirs = T))
        if (!dir.exists(paste0("temp/",codename,"/"))) { dir.create(paste0("temp/",codename,"/")) }
        file.copy(list.files(paste0(temp_dir,"/models/keras",model_id), pattern = "_wyniki.csv$", full.names = T, recursive = T, include.dirs = T),paste0("temp/",codename,"/",model_id,"_deeplearningresults.csv"))
      } }

    sink()
    sink(type="message")
    #dev.off()
    tempwyniki2 = cbind(hyperparameters[i,],tempwyniki)
    tempwyniki2[1,"name"] = paste0(codename,"_", model_id)
    tempwyniki2[1,"worth_saving"] = as.character(tempwyniki[1, "training_Accuracy"]>save_threshold_trainacc & tempwyniki[1, "test_Accuracy"]>save_threshold_testacc)
    end_time <- Sys.time()
    tempwyniki2[1,"training_time"] = as.character(end_time - start_time)
    tempwyniki2
  }

  saveRDS(final, paste0(output_file,".RDS"))
  cat("\nAll done!! Ending..\n")
  if (file.exists(output_file)) {
    tempfi = fread(output_file)
    final = rbind(tempfi, final) }
  fwrite(final, output_file)
  setwd(oldwd)
  #options(warn=0)
  # sprzątanie
  if(clean_temp_files) {
    unlink(paste0(normalizePath(temp_dir), "/", dir(temp_dir)), recursive = TRUE) }
}
