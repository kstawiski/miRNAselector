library(miRNAselector)
if(!dir.exists("/miRNAselector/temp")) { dir.create("/miRNAselector/temp") }
ks.load_extension("deeplearning")
library(data.table)
selected_miRNAs = c("hsa.miR.192.5p",
                    "hsa.let.7g.5p",
                    "hsa.let.7a.5p",
                    "hsa.let.7d.5p",
                    "hsa.miR.194.5p",
                    "hsa.miR.98.5p",
                    "hsa.let.7f.5p",
                    "hsa.miR.122.5p",
                    "hsa.miR.340.5p",
                    "hsa.miR.26b.5p",
                    "hsa.miR.17.5p",
                    "hsa.miR.199a.3p.hsa.miR.199b.3p.1",
                    "hsa.miR.28.3p",
                    "hsa.miR.92a.3p")

balanced = F
nazwa_konfiguracji = "GoldStart_wybraneinormalizatory.csv"

hyperparameters_part1 = expand.grid(layer1 = seq(2,25, by = 1), layer2 = c(0), layer3 = c(0),
                              activation_function_layer1 = c("relu","sigmoid","selu"), activation_function_layer2 = c(""), activation_function_layer3 = c(""),
                              dropout_layer1 = c(0, 0.1), dropout_layer2 = c(0), dropout_layer3 = c(0),
                              layer1_regularizer = c(T,F), layer2_regularizer = c(F), layer3_regularizer = c(F),
                              optimizer = c("adam","rmsprop","sgd","adadelta","adagrad"), autoencoder = c(0,7,-7), balanced = balanced, formula = as.character(ks.create_miRNA_formula(selected_miRNAs))[3], scaled = c(F,T),
                              stringsAsFactors = F)
hyperparameters_part2 = expand.grid(layer1 = seq(3,11, by = 2), layer2 = c(seq(3,11, by = 2)), layer3 = c(seq(3,11, by = 2)),
                              activation_function_layer1 = c("relu","sigmoid","selu"), activation_function_layer2 = c("relu","sigmoid"), activation_function_layer3 = c("relu","sigmoid"),
                              dropout_layer1 = c(0, 0.1), dropout_layer2 = c(0), dropout_layer3 = c(0),
                              layer1_regularizer = c(T,F), layer2_regularizer = c(F), layer3_regularizer = c(F),
                              optimizer = c("adam","rmsprop","sgd"), autoencoder = c(0,7,-7), balanced = balanced, formula = as.character(ks.create_miRNA_formula(selected_miRNAs))[3], scaled = c(F,T),
                              stringsAsFactors = F)
hyperparameters = rbind(hyperparameters_part1, hyperparameters_part2)

head(hyperparameters)

ile = nrow(hyperparameters)
ile_w_batchu = 1000
ile_batchy = ceiling(nrow(hyperparameters)/ile_w_batchu)
batch_start = 1
for (i in 1:ile_batchy) {
  batch_end = batch_start + (ile_w_batchu-1)
  if (batch_end > ile) { batch_end = ile }
  cat(paste0("\n\nProcessing batch no ", i , " of ", ile_batchy, " (", batch_start, "-", batch_end, ")"))

  ks.deep_learning(selected_miRNAs = selected_miRNAs, wd = getwd(), save_threshold_trainacc = 0.85, save_threshold_testacc = 0.8, hyperparameters = hyperparameters,
                   SMOTE = balanced, start = batch_start, end = batch_end, output_file = nazwa_konfiguracji, keras_threads = 50)

  batch_start = batch_end + 1
}