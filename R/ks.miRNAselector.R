#' ks.miRNAselector
#'
#' Main function of the package. The aim of this function is to perform feature selection using multiple methods and to create formulas for benchmarking.
#' It loads the data from working directory. The output is mainly created in files in working directory. Log and temporary files are placed in created `temp` subfolder.
#' This package offers about 60 feature selection methods. Which methods will be check by this function is defined by `m` parameter.
#' Pearls about the methods:
#'
#' - Sig = miRNAs with p-value <0.05 after BH correction (DE using t-test)
#' - Fcsig = sig + absolute log2FC filter (included if abs. log2FC>1)
#' - Cfs = Correlation-based Feature Selection for Machine Learning (more: https://www.cs.waikato.ac.nz/~mhall/thesis.pdf)
#' - Classloop = Classification using different classification algorithms (classifiers) with the embedded feature selection and using the different schemes for the performance validation (more: https://rdrr.io/cran/Biocomb/man/classifier.loop.html)
#' - Fcfs = CFS algorithm with forward search (https://rdrr.io/cran/Biocomb/man/select.forward.Corr.html)
#' - MDL methods = minimal description length (MDL) discretization algorithm with different a method of feature ranking or feature selection (AUC, SU, CorrSF) (more: https://rdrr.io/cran/Biocomb/man/select.process.html)
#' - bounceR = genetic algorithm with componentwise boosting (more: https://www.statworx.com/ch/blog/automated-feature-selection-using-bouncer/)
#' - RandomForestRFE = recursive feature elimination using random forest with resampling to assess the performance. (more: https://topepo.github.io/caret/recursive-feature-elimination.html#resampling-and-external-validation)
#' - GeneticAlgorithmRF (more: https://topepo.github.io/caret/feature-selection-using-genetic-algorithms.html)
#' - SimulatedAnnealing =  makes small random changes (i.e. perturbations) to an initial candidate solution (more: https://topepo.github.io/caret/feature-selection-using-simulated-annealing.html)
#' - Boruta (more: https://www.jstatsoft.org/article/view/v036i11/v36i11.pdf)
#' - spFSR = simultaneous perturbation stochastic approximation (SPSA-FSR) (more: https://arxiv.org/abs/1804.05589)
#' - varSelRF = using the out-of-bag error as minimization criterion, carry out variable elimination from random forest, by successively eliminating the least important variables (with importance as returned from random forest). (more: https://www.ncbi.nlm.nih.gov/pubmed/16398926)
#' - WxNet = a neural network-based feature selection algorithm for transcriptomic data (more: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6642261/)
#' - Step = backward stepwise method of feature selection based on logistic regression (GLM, family = binomial) using AIC criteria (stepAIC) and functions from My.stepwise package (https://cran.r-project.org/web/packages/My.stepwise/index.html)
#'
#' For more detailed defitions please see the tutorial vignette.
#'
#' @param wd Working directory with data (`mixed_train.csv`, `mixed_test.csv` and `mixed_validation.csv` as created by `ks.prepare_split` have to be present).
#' @param m Methods of feature selection to be performed. This has to be a vector of integers with minimum of 1 and maximum of 70. For the definition of numbers please see the vignette.
#' @param max_iteration Maximum number of iterations in selected methods. Setting this too high may results in very long comupting time.
#' @param code_path A folder where the python external scripts are placed (especially for WxNet method). By default the additional code is provided in the package.
#' @param register_parallel Where to use parallel processing to speed up computing time. Seting it to FALSE may aid in debuging.
#' @param clx This parameter may be used for passing the already register computing cluster (created and registered with `doParallel` tools). This may lower the computing time by saving the time to register new cluster.
#' @param stamp A character vector or timestamp used for marking the output files.
#' @param prefer_no_features Maximum number of miRNAs that can be selected by the tools if the method allows for that.
#' @param conda_path Patch to "conda" bindary used for executing python scripts.
#' @param debug Gives additional debug information (saves .rdata after feature selection is completed, prints formulas to log)
#' @param timeout_sec Timeout after the method is terminated if not finished. It may be useful to keep the long methods limited, not to wait ethernity for the results.
#'
#' @return The list of selected formulas. Note that, due to purpose of this package `ks.merge_formulas` may be a better option to get the output of processes run by this function.
#' @examples
#' # NOT RUN: (to speed up check, but this is a valid example for your real time projects)
#' # suppressMessages(library(foreach))
#' # suppressMessages(library(doParallel))
#' # suppressMessages(library(parallel))
#' # m = 1:56 # which methods to check?
#' # cl <- makeCluster(5) # 5 threds by default
#' # doSNOW::registerDoSNOW(cl)
#' # iterations = length(m)
#' # pb <- txtProgressBar(max = iterations, style = 3)
#' # progress <- function(n) setTxtProgressBar(pb, n)
#' # opts <- list(progress = progress)
#' # foreach(i = m, .verbose = TRUE, .options.snow = opts) %dopar%
#' # {
#' # suppressMessages(library(miRNAselector))
#' # setwd("~/public/Projekty/KS/miRNAselector/vignettes") # change it you to your working directory
#' # ks.miRNAselector(m = i, max_iterations = 1, stamp = "tutorial", debug = T) # we set debug to get more output
#' # }
#' # stopCluster(cl)
#'
#' @import remotes parallel plotly rJava mice BiocManager MatchIt curl reticulate kableExtra plyr dplyr edgeR epiDisplay rsq MASS Biocomb caret dplyr pROC ggplot2 DMwR doParallel Boruta spFSR varSelRF stringr psych C50 randomForest foreach data.table ROSE deepnet gridExtra stargazer gplots My.stepwise snow doSNOW sva Biobase calibrate ggrepel networkD3 VennDiagram RSNNS kernlab car PairedData profileR classInt kernlab xgboost keras tidyverse cutpointr tibble tidyr rpart party mgcv GDCRNATools rJava cutpointr imputeMissings visdat naniar stringr R.utils TCGAbiolinks GDCRNATools kableExtra VIM mice MatchIt XML rmarkdown xtable ComplexHeatmap circlize magick cluster tidyselect ellipsis
#'
#' @export
ks.miRNAselector = function(wd = getwd(), m = c(1:70),
                            max_iterations = 10, code_path = system.file("extdata", "", package = "miRNAselector"),
                            register_parallel = T, clx = NULL, stamp = as.numeric(Sys.time()),
                            prefer_no_features = 11, conda_path = "/home/konrad/anaconda3/bin/conda", debug = F,
                            timeout_sec = 172800) {

  oldwd = getwd()
  setwd(wd)
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
  suppressMessages(library(R.utils))


  if(!dir.exists("temp")) { dir.create("temp") }

  run_id = stamp
  formulas = list()
  times = list()

  zz <- file(paste0("temp/",stamp,paste0(m, collapse = "+"),"featureselection.log"), open = "wt")
  sink(zz)
  #sink(zz, type = "message")
  #pdf(paste0("temp/",stamp,paste0(m, collapse = "+"),"featureselection.pdf"))



  wynik_finalny = withTimeout({
  dane = ks.load_datamix(); train = dane[[1]]; test = dane[[2]]; valid = dane[[3]]; train_smoted = dane[[4]]; trainx = dane[[5]]; trainx_smoted = dane[[6]]

  # n = 1
  n= 1
  if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Staring method n = ", n, ". Processing...")); ks.log(logfile = "temp/featureselection.log");
    start_time <- Sys.time()

    formulas[["all"]] = ks.create_miRNA_formula(colnames(trainx))

    end_time <- Sys.time()
    saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS"))
    saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
    if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  ks.log(logfile = "temp/featureselection.log",  message_to_log = "Standard DE...")
  wyniki = ks.miRNA_differential_expression(trainx, train$Class)
  istotne = filter(wyniki, `p-value BH` <= 0.05) %>% arrange(`p-value BH`)
  istotne_top = wyniki %>% arrange(`p-value BH`) %>% head(prefer_no_features)
  istotne_topBonf = wyniki %>% arrange(`p-value Bonferroni`) %>% head(prefer_no_features)
  istotne_topHolm = wyniki %>% arrange(`p-value Holm`) %>% head(prefer_no_features)
  istotne_topFC = wyniki %>% arrange(desc(abs(`log2FC`))) %>% head(prefer_no_features)

  train_sig = dplyr::select(train, as.character(istotne$miR), Class)
  trainx_sig = dplyr::select(train, as.character(istotne$miR))

  ks.log(logfile = "temp/featureselection.log",  message_to_log = "Preparing for SMOTE...")
  #train_sig_smoted = DMwR::SMOTE(Class ~ ., data = train_sig, perc.over = 10000,perc.under=100, k=10)
  train_sig_smoted = dplyr::select(train_smoted, as.character(istotne$miR), Class)
  train_sig_smoted$Class = factor(train_sig_smoted$Class, levels = c("Control","Cancer"))
  trainx_sig_smoted = dplyr::select(train_sig_smoted, starts_with("hsa"))

  wyniki_smoted = ks.miRNA_differential_expression(trainx_smoted, train_smoted$Class)
  istotne_smoted = filter(wyniki_smoted, `p-value BH` <= 0.05) %>% arrange(`p-value BH`)
  istotne_top_smoted = wyniki_smoted %>% arrange(`p-value BH`) %>% head(prefer_no_features)
  istotne_topBonf_smoted = wyniki_smoted %>% arrange(`p-value Bonferroni`) %>% head(prefer_no_features)
  istotne_topHolm_smoted = wyniki_smoted %>% arrange(`p-value Holm`) %>% head(prefer_no_features)
  istotne_topFC_smoted = wyniki_smoted %>% arrange(desc(abs(`log2FC`))) %>% head(prefer_no_features)

  # Caret prep
  if (register_parallel) {
    ks.log(logfile = "temp/featureselection.log",  message_to_log = "Getting subcluster ready...")
    if(is.null(clx)) {
      suppressMessages(library(doParallel))
      cl <- makeCluster(detectCores() - 1)
      registerDoSNOW(cl)
      on.exit(stopCluster(cl)) }
    else { registerDoParallel(clx)
    on.exit(stopCluster(clx)) }
  }

  # 0. All and sig
  ks.log(logfile = "temp/featureselection.log",  message_to_log = "Cluster prepared. Moving to method matching...")

  # n = 2
  n = n + 1
  if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting.."));
    ks.log(logfile = "temp/featureselection.log",  message_to_log = "Starting SIG")
    start_time <- Sys.time()

    formulas[["sig"]] = ks.create_miRNA_formula(as.character(istotne$miR))
    formulas[["sigtop"]] = ks.create_miRNA_formula(as.character(istotne_top$miR))
    formulas[["sigtopBonf"]] = ks.create_miRNA_formula(as.character(istotne_topBonf$miR))
    formulas[["sigtopHolm"]] = ks.create_miRNA_formula(as.character(istotne_topHolm$miR))
    formulas[["topFC"]] = ks.create_miRNA_formula(as.character(istotne_topFC$miR))
    formulas[["sigSMOTE"]] = ks.create_miRNA_formula(as.character(istotne_smoted$miR))
    formulas[["sigtopSMOTE"]] = ks.create_miRNA_formula(as.character(istotne_top_smoted$miR))
    formulas[["sigtopBonfSMOTE"]] = ks.create_miRNA_formula(as.character(istotne_topBonf_smoted$miR))
    formulas[["sigtopHolmSMOTE"]] = ks.create_miRNA_formula(as.character(istotne_topHolm_smoted$miR))
    formulas[["topFCSMOTE"]] = ks.create_miRNA_formula(as.character(istotne_topFC_smoted$miR))


    end_time <- Sys.time()
    saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS"))
    saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
    if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 3
  # 1. Fold-change and sig. filter
  n = n + 1
  if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting.."));
    start_time <- Sys.time()

    ks.log(logfile = "temp/featureselection.log",  message_to_log = "Starting FC and SIG")
    fcsig = as.character(istotne$miR[abs(istotne$log2FC)>1])
    formulas[["fcsig"]] = ks.create_miRNA_formula(fcsig)

    fcsig = as.character(istotne_smoted$miR[abs(istotne_smoted$log2FC)>1])
    formulas[["fcsigSMOTE"]] = ks.create_miRNA_formula(fcsig)

    end_time <- Sys.time()
    saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS"))
    saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))

    if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 4
  # 2. CFS
  n = n + 1
  if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting.."));
    start_time <- Sys.time()
    ks.log(logfile = "temp/featureselection.log",  message_to_log = "Starting CFS")
    cfs = select.cfs(train)
    formulas[["cfs"]] = ks.create_miRNA_formula(as.character(cfs$Biomarker))

    cfs = select.cfs(train_smoted)
    formulas[["cfsSMOTE"]] = ks.create_miRNA_formula(as.character(cfs$Biomarker))

    cfs = select.cfs(train_sig)
    formulas[["cfs_sig"]] = ks.create_miRNA_formula(as.character(cfs$Biomarker))

    cfs = select.cfs(train_sig_smoted)
    formulas[["cfsSMOTE_sig"]] = ks.create_miRNA_formula(as.character(cfs$Biomarker))
    end_time <- Sys.time()
    saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS"))
    saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
    if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 5
  # 3. classifier.loop
  n = n + 1
  if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting.."));
    start_time <- Sys.time()
    ks.log(logfile = "temp/featureselection.log",  message_to_log = "Starting classifier loop")
    classloop = classifier.loop(train, feature.selection = "auc", method.cross="fold-crossval", classifiers=c("svm","lda","rf","nsc"), no.feat=prefer_no_features)
    f_classloop = rownames(classloop$no.selected)[classloop$no.selected[,1]>0]
    formulas[["classloop"]] = ks.create_miRNA_formula(f_classloop)
    end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
    if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 6
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  classloop = classifier.loop(train_smoted, feature.selection = "auc", method.cross="fold-crossval", classifiers=c("svm","lda","rf","nsc"), no.feat=prefer_no_features)
  f_classloop = rownames(classloop$no.selected)[classloop$no.selected[,1]>0]
  formulas[["classloopSMOTE"]] = ks.create_miRNA_formula(f_classloop)
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 7
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  classloop = classifier.loop(train_sig, feature.selection = "auc", method.cross="fold-crossval", classifiers=c("svm","lda","rf","nsc"), no.feat=prefer_no_features)
  f_classloop = rownames(classloop$no.selected)[classloop$no.selected[,1]>0]
  formulas[["classloop_sig"]] = ks.create_miRNA_formula(f_classloop)
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 8
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  classloop = classifier.loop(train_sig, feature.selection = "auc", method.cross="fold-crossval", classifiers=c("svm","lda","rf","nsc"), no.feat=prefer_no_features)
  f_classloop = rownames(classloop$no.selected)[classloop$no.selected[,1]>0]
  formulas[["classloopSMOTE_sig"]] = ks.create_miRNA_formula(f_classloop)

  end_time <- Sys.time()
  saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS"))
  saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 9
  # 4. select.forward.Corr
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  ks.log(logfile = "temp/featureselection.log",  message_to_log = "Starting select.forward.Corr")
  fcfs = select.forward.Corr(train, disc.method="MDL")
  formulas[["fcfs"]] = ks.create_miRNA_formula(fcfs)
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 10
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  fcfs = select.forward.Corr(train_smoted, disc.method="MDL")
  formulas[["fcfsSMOTE"]] = ks.create_miRNA_formula(fcfs)
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 11
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  fcfs = select.forward.Corr(train_sig, disc.method="MDL")
  formulas[["fcfs_sig"]] = ks.create_miRNA_formula(fcfs)
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 12
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  fcfs = select.forward.Corr(train_sig_smoted, disc.method="MDL")
  formulas[["fcfsSMOTE_sig"]] = ks.create_miRNA_formula(fcfs)
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 13
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  # 5. select.forward.wrapper
  fwrap = select.forward.wrapper(train)
  formulas[["fwrap"]] = ks.create_miRNA_formula(fwrap)
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 14
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  fwrap = select.forward.wrapper(train_smoted)
  formulas[["fwrapSMOTE"]] = ks.create_miRNA_formula(fwrap)
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 15
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  fwrap = select.forward.wrapper(train_sig)
  formulas[["fwrap_sig"]] = ks.create_miRNA_formula(fwrap)
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 16
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  fwrap = select.forward.wrapper(train_sig_smoted)
  formulas[["fwrapSMOTE_sig"]] = ks.create_miRNA_formula(fwrap)
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }
  # 6, 7, 8.
  #select.process(dattable,method="InformationGain",disc.method="MDL",
  #               threshold=0.2,threshold.consis=0.05,attrs.nominal=numeric(),
  #               max.no.features=10)
  # n = 17
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  ks.log(logfile = "temp/featureselection.log",  message_to_log = "Starting MDL")
  formulas[["AUC_MDL"]] = ks.create_miRNA_formula(colnames(train)[select.process(train, method="auc", disc.method = "MDL", max.no.features = prefer_no_features)])
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 18
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  formulas[["SU_MDL"]] = ks.create_miRNA_formula(colnames(train)[select.process(train, method="symmetrical.uncertainty", disc.method = "MDL", max.no.features = prefer_no_features)])
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 19
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  formulas[["CorrSF_MDL"]] = ks.create_miRNA_formula(colnames(train)[select.process(train, method="CorrSF", disc.method = "MDL", max.no.features = prefer_no_features)])
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 20
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();

  formulas[["AUC_MDLSMOTE"]] = ks.create_miRNA_formula(colnames(train_smoted)[select.process(train_smoted, method="auc", disc.method = "MDL", max.no.features = prefer_no_features)])
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 21
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();


  formulas[["SU_MDLSMOTE"]] = ks.create_miRNA_formula(colnames(train_smoted)[select.process(train_smoted, method="symmetrical.uncertainty", disc.method = "MDL", max.no.features = prefer_no_features)])
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 22
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  formulas[["CorrSF_MDLSMOTE"]] = ks.create_miRNA_formula(colnames(train_smoted)[select.process(train_smoted, method="CorrSF", disc.method = "MDL", max.no.features = prefer_no_features)])
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 23
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  formulas[["AUC_MDL_sig"]] = ks.create_miRNA_formula(colnames(train_sig)[select.process(train_sig, method="auc", disc.method = "MDL", max.no.features = prefer_no_features)])
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 24
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  formulas[["SU_MDL_sig"]] = ks.create_miRNA_formula(colnames(train_sig)[select.process(train_sig, method="symmetrical.uncertainty", disc.method = "MDL", max.no.features = prefer_no_features)])

  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 25
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  formulas[["CorrSF_MDL_sig"]] = ks.create_miRNA_formula(colnames(train_sig)[select.process(train_sig, method="CorrSF", disc.method = "MDL", max.no.features = prefer_no_features)])
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 26
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  formulas[["AUC_MDLSMOTE_sig"]] = ks.create_miRNA_formula(colnames(train_sig_smoted)[select.process(train_sig_smoted, method="auc", disc.method = "MDL", max.no.features = prefer_no_features)])
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 27
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  formulas[["SU_MDLSMOTE_sig"]] = ks.create_miRNA_formula(colnames(train_sig_smoted)[select.process(train_sig_smoted, method="symmetrical.uncertainty", disc.method = "MDL", max.no.features = prefer_no_features)])
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 28
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  formulas[["CorrSF_MDLSMOTE_sig"]] = ks.create_miRNA_formula(colnames(train_sig_smoted)[select.process(train_sig_smoted, method="CorrSF", disc.method = "MDL", max.no.features = prefer_no_features)])
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 29
  # 9. bounceR - genetic
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  ks.log(logfile = "temp/featureselection.log",  message_to_log = "Starting bounceR..")
  suppressMessages(library(bounceR))
  mrmr <- bounceR::featureSelection(data = train,
                                    target = "Class",
                                    max_time = "15 mins",
                                    selection = selectionControl(n_rounds = NULL,
                                                                 n_mods = NULL,
                                                                 p = prefer_no_features,
                                                                 penalty = 0.5,
                                                                 reward = 0.2),
                                    bootstrap = "regular",
                                    early_stopping = "aic",
                                    boosting = boostingControl(mstop = 100, nu = 0.1),
                                    cores = parallel::detectCores()-1)
  formulas[["bounceR-full"]] = mrmr@opt_formula
  formulas[["bounceR-stability"]] = ks.create_miRNA_formula(as.character(mrmr@stability[1:prefer_no_features,] %>% pull('feature')))
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 30
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  suppressMessages(library(bounceR))
  mrmr <- bounceR::featureSelection(data = train_smoted,
                           target = "Class",
                           max_time = "15 mins",
                           selection = selectionControl(n_rounds = NULL,
                                                        n_mods = NULL,
                                                        p = prefer_no_features,
                                                        penalty = 0.5,
                                                        reward = 0.2),
                           bootstrap = "regular",
                           early_stopping = "aic",
                           boosting = boostingControl(mstop = 100, nu = 0.1),
                           cores = parallel::detectCores()-1)
  formulas[["bounceR-full_SMOTE"]] = mrmr@opt_formula
  formulas[["bounceR-stability_SMOTE"]] = ks.create_miRNA_formula(as.character(mrmr@stability[1:prefer_no_features,] %>% pull('feature')))
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 31
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  suppressMessages(library(bounceR))
  mrmr <- bounceR::featureSelection(data = train_sig,
                           target = "Class",
                           max_time = "15 mins",
                           selection = selectionControl(n_rounds = NULL,
                                                        n_mods = NULL,
                                                        p = prefer_no_features,
                                                        penalty = 0.5,
                                                        reward = 0.2),
                           bootstrap = "regular",
                           early_stopping = "aic",
                           boosting = boostingControl(mstop = 100, nu = 0.1),
                           cores = parallel::detectCores()-1)
  formulas[["bounceR-full_SIG"]] = mrmr@opt_formula
  formulas[["bounceR-stability_SMOTE"]] = ks.create_miRNA_formula(as.character(mrmr@stability[1:prefer_no_features,] %>% pull('feature')))
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 32
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  suppressMessages(library(bounceR))
  mrmr <- bounceR::featureSelection(data = train_sig_smoted,
                           target = "Class",
                           max_time = "15 mins",
                           selection = selectionControl(n_rounds = NULL,
                                                        n_mods = NULL,
                                                        p = prefer_no_features,
                                                        penalty = 0.5,
                                                        reward = 0.2),
                           bootstrap = "regular",
                           early_stopping = "aic",
                           boosting = boostingControl(mstop = 100, nu = 0.1),
                           cores = parallel::detectCores()-1)
  formulas[["bounceR-full_SIGSMOTE"]] = mrmr@opt_formula
  formulas[["bounceR-stability_SIGSMOTE"]] = ks.create_miRNA_formula(as.character(mrmr@stability[1:prefer_no_features,] %>% pull('feature')))
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 33
  # 10. RFE RandomForest
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  ks.log(logfile = "temp/featureselection.log",  message_to_log = "Starting RFE RF")
  ctrl <- rfeControl(functions =rfFuncs,
                     method = "cv", number = 10,
                     saveDetails = TRUE,
                     allowParallel = TRUE,
                     returnResamp = "all",
                     verbose = T)

  rfProfile <- rfe(trainx, train$Class,
                   sizes = 3:11,
                   rfeControl = ctrl)
  plot(rfProfile, type=c("g", "o"))
  formulas[["RandomForestRFE"]] = ks.create_miRNA_formula(predictors(rfProfile))
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 34
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  rfProfile <- rfe(trainx_smoted, train_smoted$Class,
                   sizes = 3:11,
                   rfeControl = ctrl)
  plot(rfProfile, type=c("g", "o"))
  formulas[["RandomForestRFESMOTE"]] = ks.create_miRNA_formula(predictors(rfProfile))
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 35
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  rfProfile <- rfe(trainx_sig, train_sig$Class,
                   sizes = 3:11,
                   rfeControl = ctrl)
  plot(rfProfile, type=c("g", "o"))
  formulas[["RandomForestRFE_sig"]] = ks.create_miRNA_formula(predictors(rfProfile))
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 36
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  rfProfile <- rfe(trainx_sig_smoted, train_sig_smoted$Class,
                   sizes = 3:11,
                   rfeControl = ctrl)
  plot(rfProfile, type=c("g", "o"))
  formulas[["RandomForestRFESMOTE_sig"]] = ks.create_miRNA_formula(predictors(rfProfile))
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }


  # n = 37
  # 11. Genetic
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  ks.log(logfile = "temp/featureselection.log",  message_to_log = "Starting Genetic")
  ga_ctrl <- gafsControl(functions = rfGA, method = "repeatedcv", number=10, repeats=5, allowParallel=T)
  rf_ga <- gafs(x = trainx, y = train$Class,
                iters = max_iterations,
                gafsControl = ga_ctrl)
  plot(rf_ga) + theme_bw()
  print(rf_ga)
  formulas[["GeneticAlgorithmRF"]] = ks.create_miRNA_formula(rf_ga$ga$final)
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 38
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  ga_ctrl <- gafsControl(functions = rfGA, method = "repeatedcv", number=10, repeats=5, allowParallel=T)
  rf_ga <- gafs(x = trainx_smoted, y = train_smoted$Class,
                iters = max_iterations,
                gafsControl = ga_ctrl)
  plot(rf_ga) + theme_bw()
  print(rf_ga)
  formulas[["GeneticAlgorithmRFSMOTE"]] = ks.create_miRNA_formula(rf_ga$ga$final)
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 39
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  ga_ctrl <- gafsControl(functions = rfGA, method = "repeatedcv", number=10, repeats=5, allowParallel=T)
  rf_ga <- gafs(x = trainx_sig, y = train_sig$Class,
                iters = max_iterations,
                gafsControl = ga_ctrl)
  plot(rf_ga) + theme_bw()
  print(rf_ga)
  formulas[["GeneticAlgorithmRF_sig"]] = ks.create_miRNA_formula(rf_ga$ga$final)
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 40
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  ga_ctrl <- gafsControl(functions = rfGA, method = "repeatedcv", number=10, repeats=5, allowParallel=T)
  rf_ga <- gafs(x = trainx_sig_smoted, y = train_sig_smoted$Class,
                iters = max_iterations,
                gafsControl = ga_ctrl)
  plot(rf_ga) + theme_bw()
  print(rf_ga)
  formulas[["GeneticAlgorithmRFSMOTE_sig"]] = ks.create_miRNA_formula(rf_ga$ga$final)
  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 41
  # 12. SimulatedAnealing
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  ks.log(logfile = "temp/featureselection.log",  message_to_log = "Starting SimulatedAnealing")
  sa_ctrl <- safsControl(functions = rfSA,
                         method = "repeatedcv",
                         number=5, repeats=10, allowParallel=T,
                         improve = 50)

  rf_sa <- safs(x = trainx, y = train$Class,
                iters = max_iterations,
                safsControl = sa_ctrl)
  print(rf_sa)
  plot(rf_sa) + theme_bw()
  formulas[["SimulatedAnnealingRF"]] = ks.create_miRNA_formula(rf_sa$sa$final)



  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 42
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  rf_sa <- safs(x = trainx_smoted, y = train_smoted$Class,
                iters = max_iterations,
                safsControl = sa_ctrl)
  print(rf_sa)
  plot(rf_sa) + theme_bw()
  formulas[["SimulatedAnnealingRFSMOTE"]] = ks.create_miRNA_formula(rf_sa$sa$final)

  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 43
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  rf_sa <- safs(x = trainx_sig, y = train_sig$Class,
                iters = max_iterations,
                safsControl = sa_ctrl)
  print(rf_sa)
  plot(rf_sa) + theme_bw()
  formulas[["SimulatedAnnealingRF_sig"]] = ks.create_miRNA_formula(rf_sa$sa$final)

  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 44
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  rf_sa <- safs(x = trainx_sig_smoted, y = train_sig_smoted$Class,
                iters = max_iterations,
                safsControl = sa_ctrl)
  print(rf_sa)
  plot(rf_sa) + theme_bw()
  formulas[["SimulatedAnnealingRFSMOTE_sig"]] = ks.create_miRNA_formula(rf_sa$sa$final)

  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }


  # n = 45
  # 14. Boruta (https://www.jstatsoft.org/article/view/v036i11)
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  suppressMessages(library(Boruta))
  ks.log(logfile = "temp/featureselection.log",  message_to_log = "Starting Boruta")
  bor = Boruta(trainx, train$Class)
  formulas[["Boruta"]] = ks.create_miRNA_formula(names(bor$finalDecision)[as.character(bor$finalDecision) == "Confirmed"])

  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 46
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  bor = Boruta(trainx_smoted, train_smoted$Class)
  formulas[["BorutaSMOTE"]] = ks.create_miRNA_formula(names(bor$finalDecision)[as.character(bor$finalDecision) == "Confirmed"])

  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 47
  # 15. spFSR - feature selection and ranking by simultaneous perturbation stochastic approximation
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  ks.log(logfile = "temp/featureselection.log",  message_to_log = "Starting spFSR")
  suppressMessages(library(spFSR))
  knnWrapper    <- makeLearner("classif.knn", k = 5)
  classifTask   <- makeClassifTask(data = train, target = "Class")
  perf.measure  <- acc
  spsaMod <- spFeatureSelection(
    task = classifTask,
    wrapper = knnWrapper,
    measure = perf.measure ,
    num.features.selected = prefer_no_features,
    iters.max = max_iterations,
    num.cores = detectCores() - 1)
  formulas[["spFSR"]] = ks.create_miRNA_formula(spsaMod$features)

  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 48
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  classifTask   <- makeClassifTask(data = train_smoted, target = "Class")
  perf.measure  <- acc
  spsaMod <- spFeatureSelection(
    task = classifTask,
    wrapper = knnWrapper,
    measure = perf.measure ,
    num.features.selected = prefer_no_features,
    iters.max = max_iterations,
    num.cores = detectCores() - 1)
  formulas[["spFSRSMOTE"]] = ks.create_miRNA_formula(spsaMod$features)

  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 49
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  # varSelRF
  ks.log(logfile = "temp/featureselection.log",  message_to_log = "Starting varSelRF")
  suppressMessages(library(varSelRF))
  var.sel <- varSelRF(trainx, train$Class, ntree = 500, ntreeIterat = max_iterations, vars.drop.frac = 0.05, whole.range = T, keep.forest = T)
  formulas[["varSelRF"]] = ks.create_miRNA_formula(var.sel$selected.vars)

  var.sel <- varSelRF(trainx_smoted, train_smoted$Class, ntree = 500, ntreeIterat = max_iterations, vars.drop.frac = 0.05, whole.range = T, keep.forest = T)
  formulas[["varSelRFSMOTE"]] = ks.create_miRNA_formula(var.sel$selected.vars)

  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 50
  n = n + 1; if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting..")); start_time <- Sys.time();
  # 13. WxNet (https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6642261/)
  ks.log(logfile = "temp/featureselection.log",  message_to_log = "Starting WxNet")
  suppressMessages(library(plyr))
  suppressMessages(library(dplyr))
  suppressMessages(library(reticulate))
  suppressMessages(library(tidyverse))
  suppressMessages(library(data.table))
  suppressMessages(library(DMwR))



  # Set the path to the Python executale file
  #use_python("/anaconda3/bin/python", required = T)


  conda_list()
  use_condaenv("tensorflow", required = T)
  py_config()

  dane = ks.load_datamix(replace_smote = F); train = dane[[1]]; test = dane[[2]]; valid = dane[[3]]; train_smoted = dane[[4]]; trainx = dane[[5]]; trainx_smoted = dane[[6]]

  #train_org = train
  #train = SMOTE(Class ~ ., data = train_org, perc.over = 10000,perc.under=100)

  # Przygotowanie
  trainx = dplyr::select(train, starts_with("hsa"))
  testx = dplyr::select(test, starts_with("hsa"))
  trainx = t(trainx)
  testx = t(testx)
  ids = paste0("train",1:ncol(trainx))
  ids2 = paste0("test",1:ncol(testx))
  colnames(trainx) = gsub("-", "", ids)
  colnames(testx) = gsub("-", "", ids2)

  traindata = cbind(data.frame(fnames = rownames(trainx), trainx))
  fwrite(traindata, paste0(code_path, "wx/DearWXpub/src/train-data.csv"), row.names = F, quote = F)
  testdata = cbind(data.frame(fnames = rownames(testx), testx))
  fwrite(testdata, paste0(code_path, "wx/DearWXpub/src/test-data.csv"), row.names = F, quote = F)

  trainanno = data.frame(id = colnames(trainx), label = train$Class)
  fwrite(trainanno, paste0(code_path, "wx/DearWXpub/src/train-anno.csv"), row.names = F, quote = F)
  testanno = data.frame(id = colnames(testx), label = test$Class)
  fwrite(testanno, paste0(code_path, "wx/DearWXpub/src/test-anno.csv"), row.names = F, quote = F)


  # Wywolanie WX

  out <- tryCatch(
    {
      setwd(paste0(code_path,"wx/DearWXpub/src/"))
      system(paste0(conda_path," activate tensorflow"))
      py_run_file("wx_konsta.py", local = T)

      np <- import("numpy")
      w = np$load("wyniki.npy",allow_pickle=T)
      formulas[["Wx"]] = ks.create_miRNA_formula(w)
    },
    error=function(cond) {
      message("ERROR:")
      message(cond)
      # Choose a return value in case of error
    },
    warning=function(cond) {
      message("WARNING:")
      message(cond)
    },
    finally={
      setwd(wd)
    }
  )





  # Wx with SMOTE
  dane = ks.load_datamix(replace_smote = T); train = dane[[1]]; test = dane[[2]]; valid = dane[[3]]; train_smoted = dane[[4]]; trainx = dane[[5]]; trainx_smoted = dane[[6]]

  # Przygotowanie
  trainx = dplyr::select(train, starts_with("hsa"))
  testx = dplyr::select(test, starts_with("hsa"))
  trainx = t(trainx)
  testx = t(testx)
  ids = paste0("train",1:ncol(trainx))
  ids2 = paste0("test",1:ncol(testx))
  colnames(trainx) = gsub("-", "", ids)
  colnames(testx) = gsub("-", "", ids2)

  traindata = cbind(data.frame(fnames = rownames(trainx), trainx))
  fwrite(traindata, paste0(code_path, "wx/DearWXpub/src/train-data.csv"), row.names = F, quote = F)
  testdata = cbind(data.frame(fnames = rownames(testx), testx))
  fwrite(testdata, paste0(code_path, "wx/DearWXpub/src/test-data.csv"), row.names = F, quote = F)

  trainanno = data.frame(id = colnames(trainx), label = train$Class)
  fwrite(trainanno, paste0(code_path, "wx/DearWXpub/src/train-anno.csv"), row.names = F, quote = F)
  testanno = data.frame(id = colnames(testx), label = test$Class)
  fwrite(testanno, paste0(code_path, "wx/DearWXpub/src/test-anno.csv"), row.names = F, quote = F)


  # Wywolanie WX
  # setwd(paste0(code_path,"wx/DearWXpub/src/"))
  # py_run_file("wx_konsta.py", local = T)
  #
  # np <- import("numpy")
  # w = np$load("wyniki.npy",allow_pickle=T)
  # print(w)
  # setwd(wd)
  # formulas[["WxSMOTE"]] = ks.create_miRNA_formula(w)
  out <- tryCatch(
    {
      setwd(paste0(code_path,"wx/DearWXpub/src/"))
      py_run_file("wx_konsta.py", local = T)

      np <- import("numpy")
      w = np$load("wyniki.npy",allow_pickle=T)
      formulas[["WxSMOTE"]] = ks.create_miRNA_formula(w)
    },
    error=function(cond) {
      message("ERROR:")
      message(cond)
      # Choose a return value in case of error
    },
    warning=function(cond) {
      message("WARNING:")
      message(cond)
    },
    finally={
      setwd(wd)
    }
  )

  dane = ks.load_datamix(replace_smote = F); train = dane[[1]]; test = dane[[2]]; valid = dane[[3]]; train_smoted = dane[[4]]; trainx = dane[[5]]; trainx_smoted = dane[[6]]

  # Przygotowanie
  trainx = dplyr::select(train, starts_with("hsa"))
  testx = dplyr::select(test, starts_with("hsa"))
  trainx = t(trainx)
  testx = t(testx)
  ids = paste0("train",1:ncol(trainx))
  ids2 = paste0("test",1:ncol(testx))
  colnames(trainx) = gsub("-", "", ids)
  colnames(testx) = gsub("-", "", ids2)

  traindata = cbind(data.frame(fnames = rownames(trainx), trainx))
  fwrite(traindata, paste0(code_path, "wx/DearWXpub/src/train-data.csv"), row.names = F, quote = F)
  testdata = cbind(data.frame(fnames = rownames(testx), testx))
  fwrite(testdata, paste0(code_path, "wx/DearWXpub/src/test-data.csv"), row.names = F, quote = F)

  trainanno = data.frame(id = colnames(trainx), label = train$Class)
  fwrite(trainanno, paste0(code_path, "wx/DearWXpub/src/train-anno.csv"), row.names = F, quote = F)
  testanno = data.frame(id = colnames(testx), label = test$Class)
  fwrite(testanno, paste0(code_path, "wx/DearWXpub/src/test-anno.csv"), row.names = F, quote = F)


  # Wywolanie WX
  # setwd(paste0(code_path,"wx/DearWXpub/src/"))
  # py_run_file("wx_konsta_z.py", local = T)
  #
  # np <- import("numpy")
  # w = np$load("wyniki.npy",allow_pickle=T)
  # print(w)
  # setwd(wd)
  # formulas[["Wx_Zscore"]] = ks.create_miRNA_formula(w)
  out <- tryCatch(
    {
      setwd(paste0(code_path,"wx/DearWXpub/src/"))
      py_run_file("wx_konsta_z.py", local = T)

      np <- import("numpy")
      w = np$load("wyniki.npy",allow_pickle=T)
      formulas[["Wx_Zscore"]] = ks.create_miRNA_formula(w)
    },
    error=function(cond) {
      message("ERROR:")
      message(cond)
      # Choose a return value in case of error
    },
    warning=function(cond) {
      message("WARNING:")
      message(cond)
    },
    finally={
      setwd(wd)
    }
  )

  dane = ks.load_datamix(replace_smote = T); train = dane[[1]]; test = dane[[2]]; valid = dane[[3]]; train_smoted = dane[[4]]; trainx = dane[[5]]; trainx_smoted = dane[[6]]

  # Przygotowanie
  trainx = dplyr::select(train, starts_with("hsa"))
  testx = dplyr::select(test, starts_with("hsa"))
  trainx = t(trainx)
  testx = t(testx)
  ids = paste0("train",1:ncol(trainx))
  ids2 = paste0("test",1:ncol(testx))
  colnames(trainx) = gsub("-", "", ids)
  colnames(testx) = gsub("-", "", ids2)

  traindata = cbind(data.frame(fnames = rownames(trainx), trainx))
  fwrite(traindata, paste0(code_path, "wx/DearWXpub/src/train-data.csv"), row.names = F, quote = F)
  testdata = cbind(data.frame(fnames = rownames(testx), testx))
  fwrite(testdata, paste0(code_path, "wx/DearWXpub/src/test-data.csv"), row.names = F, quote = F)

  trainanno = data.frame(id = colnames(trainx), label = train$Class)
  fwrite(trainanno, paste0(code_path, "wx/DearWXpub/src/train-anno.csv"), row.names = F, quote = F)
  testanno = data.frame(id = colnames(testx), label = test$Class)
  fwrite(testanno, paste0(code_path, "wx/DearWXpub/src/test-anno.csv"), row.names = F, quote = F)


  # Wywolanie WX
  # setwd(paste0(code_path,"wx/DearWXpub/src/"))
  # py_run_file("wx_konsta_z.py", local = T)
  #
  # np <- import("numpy")
  # w = np$load("wyniki.npy",allow_pickle=T)
  # print(w)
  # setwd(wd)
  # formulas[["Wx_ZscoreSMOTE"]] = ks.create_miRNA_formula(w)
  out <- tryCatch(
    {
      setwd(paste0(code_path,"wx/DearWXpub/src/"))
      py_run_file("wx_konsta_z.py", local = T)

      np <- import("numpy")
      w = np$load("wyniki.npy",allow_pickle=T)
      formulas[["Wx_ZscoreSMOTE"]] = ks.create_miRNA_formula(w)
    },
    error=function(cond) {
      message("ERROR:")
      message(cond)
      # Choose a return value in case of error
    },
    warning=function(cond) {
      message("WARNING:")
      message(cond)
    },
    finally={
      setwd(wd)
    }
  )


  end_time <- Sys.time(); saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS")); saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
  if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 51
  # My.stepwise
  n = n + 1
  if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting.."));
    ks.log(logfile = "temp/featureselection.log",  message_to_log = "Starting My.stepwise")
    start_time <- Sys.time()

    dane = ks.load_datamix(replace_smote = F); train = dane[[1]]; test = dane[[2]]; valid = dane[[3]]; train_smoted = dane[[4]]; trainx = dane[[5]]; trainx_smoted = dane[[6]]

    suppressMessages(library(My.stepwise))
    temp = capture.output(My.stepwise.glm(Y = "Class", colnames(trainx), data = train, sle = 0.05, sls = 0.05, myfamily = "binomial"))
    # temp2 = temp[length(temp)-1]
    # temp3 = temp[length(temp)-3]
    # temp4 = temp[length(temp)-5]
    temp5 = paste(temp[(length(temp)-12):length(temp)], collapse = " ")
    wybrane = FALSE
    for(i in 1:length(colnames(trainx)))
    {
      temp6 = colnames(trainx)[i]
      wybrane[i] = grepl(temp6, temp5)
    }
    formulas[["Mystepwise_glm_binomial"]] = ks.create_miRNA_formula(colnames(trainx)[wybrane])

    wyniki = ks.miRNA_differential_expression(trainx, train$Class)
    istotne = filter(wyniki, `p-value BH` <= 0.05) %>% arrange(`p-value BH`)

    temp = capture.output(My.stepwise.glm(Y = "Class", as.character(istotne$miR), data = train, sle = 0.05, sls = 0.05, myfamily = "binomial"))
    # temp2 = temp[length(temp)-1]
    # temp3 = temp[length(temp)-3]
    # temp4 = temp[length(temp)-5]
    temp5 = paste(temp[(length(temp)-12):length(temp)], collapse = " ")
    wybrane = FALSE
    for(i in 1:length(colnames(trainx)))
    {
      temp6 = colnames(trainx)[i]
      wybrane[i] = grepl(temp6, temp5)
    }
    formulas[["Mystepwise_sig_glm_binomial"]] = ks.create_miRNA_formula(colnames(trainx)[wybrane])

    end_time <- Sys.time()
    saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS"))
    saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
    if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 52
  n = n + 1
  if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting.."));
    ks.log(logfile = "temp/featureselection.log",  message_to_log = "Starting My.stepwise SMOTE")
    start_time <- Sys.time()

    dane = ks.load_datamix(replace_smote = F); train = dane[[1]]; test = dane[[2]]; valid = dane[[3]]; train_smoted = dane[[4]]; trainx = dane[[5]]; trainx_smoted = dane[[6]]

    suppressMessages(library(My.stepwise))
    temp = capture.output(My.stepwise.glm(Y = "Class", colnames(trainx_smoted), data = train_smoted, sle = 0.05, sls = 0.05, myfamily = "binomial"))
    # temp2 = temp[length(temp)-1]
    # temp3 = temp[length(temp)-3]
    # temp4 = temp[length(temp)-5]
    temp5 = paste(temp[(length(temp)-12):length(temp)], collapse = " ")
    wybrane = FALSE
    for(i in 1:length(colnames(trainx_smoted)))
    {
      temp6 = colnames(trainx_smoted)[i]
      wybrane[i] = grepl(temp6, temp5)
    }
    formulas[["Mystepwise_glm_binomialSMOTE"]] = ks.create_miRNA_formula(colnames(trainx_smoted)[wybrane])

    wyniki = ks.miRNA_differential_expression(trainx, train$Class)
    istotne = filter(wyniki, `p-value BH` <= 0.05) %>% arrange(`p-value BH`)

    temp = capture.output(My.stepwise.glm(Y = "Class", as.character(istotne$miR), data = train_smoted, sle = 0.05, sls = 0.05, myfamily = "binomial"))
    # temp2 = temp[length(temp)-1]
    # temp3 = temp[length(temp)-3]
    # temp4 = temp[length(temp)-5]
    temp5 = paste(temp[(length(temp)-12):length(temp)], collapse = " ")
    wybrane = FALSE
    for(i in 1:length(colnames(trainx_smoted)))
    {
      temp6 = colnames(trainx_smoted)[i]
      wybrane[i] = grepl(temp6, temp5)
    }
    formulas[["Mystepwise_sig_glm_binomialSMOTE"]] = ks.create_miRNA_formula(colnames(trainx_smoted)[wybrane])

    end_time <- Sys.time()
    saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS"))
    saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
    if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 53
  n = n + 1
  if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting.."));
    ks.log(logfile = "temp/featureselection.log",  message_to_log = "Starting stepAIC")
    start_time <- Sys.time()

    dane = ks.load_datamix(replace_smote = F); train = dane[[1]]; test = dane[[2]]; valid = dane[[3]]; train_smoted = dane[[4]]; trainx = dane[[5]]; trainx_smoted = dane[[6]]

    temp = glm(Class ~ ., data = train, family = "binomial")
    temp2 = stepAIC(temp)

    formulas[["stepAIC"]] = temp2$formula

    wyniki = ks.miRNA_differential_expression(trainx, train$Class)
    istotne = filter(wyniki, `p-value BH` <= 0.05) %>% arrange(`p-value BH`)

    train.sig = dplyr::select(train, as.character(istotne$miR), Class)

    temp = glm(Class ~ ., data = train.sig, family = "binomial")
    temp2 = stepAIC(temp)

    formulas[["stepAICsig"]] = temp2$formula

    end_time <- Sys.time()
    saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS"))
    saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
    if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 54
  n = n + 1
  if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting.."));
    ks.log(logfile = "temp/featureselection.log",  message_to_log = "Starting stepAIC SMOTE")
    start_time <- Sys.time()

    dane = ks.load_datamix(replace_smote = F); train = dane[[1]]; test = dane[[2]]; valid = dane[[3]]; train_smoted = dane[[4]]; trainx = dane[[5]]; trainx_smoted = dane[[6]]

    temp = glm(Class ~ ., data = train_smoted, family = "binomial")
    temp2 = stepAIC(temp)

    formulas[["stepAIC_SMOTE"]] = temp2$formula

    wyniki = ks.miRNA_differential_expression(trainx, train$Class)
    istotne = filter(wyniki, `p-value BH` <= 0.05) %>% arrange(`p-value BH`)

    train.sig = dplyr::select(train_smoted, as.character(istotne$miR), Class)

    temp = glm(Class ~ ., data = train.sig, family = "binomial")
    temp2 = stepAIC(temp)

    formulas[["stepAICsig_SMOTE"]] = temp2$formula

    end_time <- Sys.time()
    saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS"))
    saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
    if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 55
  n = n + 1
  if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting.."));
    ks.log(logfile = "temp/featureselection.log",  message_to_log = "Starting MK method (iterated RFE)")
    start_time <- Sys.time()

    dane = ks.load_datamix(replace_smote = F); train = dane[[1]]; test = dane[[2]]; valid = dane[[3]]; train_smoted = dane[[4]]; trainx = dane[[5]]; trainx_smoted = dane[[6]]

    selectedMirsCV <- mk.iteratedRFE(trainSet = train, useCV = T, classLab = 'Class', checkNFeatures = prefer_no_features)$topFeaturesPerN[[prefer_no_features]]
    selectedMirsTest <- mk.iteratedRFE(trainSet = train, testSet = test, classLab = 'Class', checkNFeatures = prefer_no_features)$topFeaturesPerN[[prefer_no_features]]

    formulas[["iteratedRFECV"]] = ks.create_miRNA_formula(selectedMirsCV$topFeaturesPerN[[prefer_no_features]])
    formulas[["iteratedRFETest"]] = ks.create_miRNA_formula(selectedMirsTest$topFeaturesPerN[[prefer_no_features]])

    end_time <- Sys.time()
    saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS"))
    saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
    if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # n = 56
  n = n + 1
  if (n %in% m) { ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Matched method ", n, " with those requested.. Starting.."));
    ks.log(logfile = "temp/featureselection.log",  message_to_log = "Starting MK method (iterated RFE) with SMOTE")
    start_time <- Sys.time()

    dane = ks.load_datamix(replace_smote = F); train = dane[[1]]; test = dane[[2]]; valid = dane[[3]]; train_smoted = dane[[4]]; trainx = dane[[5]]; trainx_smoted = dane[[6]]

    selectedMirsCV <- mk.iteratedRFE(trainSet = train_smoted, useCV = T, classLab = 'Class', checkNFeatures = prefer_no_features)$topFeaturesPerN[[prefer_no_features]]
    selectedMirsTest <- mk.iteratedRFE(trainSet = train_smoted, testSet = test, classLab = 'Class', checkNFeatures = prefer_no_features)$topFeaturesPerN[[prefer_no_features]]

    formulas[["iteratedRFECV"]] = ks.create_miRNA_formula(selectedMirsCV$topFeaturesPerN[[prefer_no_features]])
    formulas[["iteratedRFETest"]] = ks.create_miRNA_formula(selectedMirsTest$topFeaturesPerN[[prefer_no_features]])

    end_time <- Sys.time()
    saveRDS(end_time - start_time, paste0("temp/time",n,"-",run_id,".RDS"))
    saveRDS(formulas, paste0("temp/formulas",run_id,"-",n,".RDS"))
    if(debug) { save(list = ls(), file = paste0("temp/all",n,"-",run_id,".rdata")); print(formulas) }
  }

  # End
  ks.log(logfile = "temp/featureselection.log",  message_to_log = paste0("Ending task. Selected: \n", formulas))
  stopCluster(cl)
  saveRDS(formulas, paste0("temp/featureselection_formulas",stamp,".RDS"))
  #saveRDS(formulas, paste0("featureselection_formulas.RDS"))
  #nazwa = paste0("temp/featureselection_data",stamp,".rda")
  #save(list = ls(), file = nazwa)
  #dev.off()
  print(formulas)
  setwd(oldwd)
  formulas}, timeout = timeout_sec, onTimeout = "silent")
  if (is.null(wynik_finalny)) {
    ks.log(logfile = "temp/featureselection.log",  message_to_log = "STOPED BECAUSE OF TIMEOUT REACHED!!")
    warnings()
    save(list = ls(), file = paste0("temp/timeoutdebug_",stamp,"-",m,".rdata"))
  }
  sink()
  #dev.off()
return(wynik_finalny)
}
