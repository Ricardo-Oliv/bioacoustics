# $ cd /home/pi/Desktop/deploy_classifier/
# $ R --no-save 
# > setwd("/home/pi/Desktop/deploy_classifier/")

# > print("Hello!")
# > print(setwd)
# > Deploy_bats_pi.R
# $ Rscript Deploy_bats_pi.R

# To install packages, type 'R' in command line and then eg:
# install.packages("audio")
# install.packages("randomForest")
# install.packages("bioacoustics")

library(audio)
library(bioacoustics)
library(tools)
library(randomForest)

setwd("/home/pi/Desktop/deploy_classifier/")
wd <- getwd()         # Working directory
wd

# delete a file
unlink("Final_result.txt")
############################################
# Predict on one unknown wav file:
data_dir_test <- file.path(wd, "unknown_bat_audio")
# print(data_dir_test)

#The unknown test file is located in a specific directory:
files_test <- dir(data_dir_test, recursive = TRUE, full.names = TRUE, pattern = "[.]wav$")
# files_test

# Detect and extract audio events from our unknown test file:
TDs <- setNames(
  lapply(
    files_test,
    threshold_detection,
    threshold = 3, 
    min_dur = 1, 
    max_dur = 80, 
    min_TBE = 50, 
    max_TBE = Inf,
    LPF = 120000, 
    HPF = 15000, 
    FFT_size = 256, 
    start_thr = 30, 
    end_thr = 20, 
    SNR_thr = 5, 
    angle_thr = 125, 
    duration_thr = 400, 
    spectro_dir = NULL,
    NWS = 2000, 
    KPE = 0.00001, 
    time_scale = 2, 
    EDG = 0.996
  ),
  basename(file_path_sans_ext(files_test))
)

# Keep only files with data in it
TDs <- TDs[lapply(TDs, function(x) length(x$data)) > 0]

# Keep the extracted feature and merge in a single data frame for further analysis
Event_data_test <- do.call("rbind", c(lapply(TDs, function(x) x$data$event_data), list(stringsAsFactors = FALSE)))
nrow(Event_data_test)

# To look at the predictions 
# print("Is the unknown wav a c_pip?")
test_file <- readRDS('rf_c_pip.rds')
# print(test_file)
# predict(test_file , Event_data_test[,-1], type = "prob")

# print("Is the unknown wav a c_pip?")
# head(predict(test_file , Event_data_test[,-1], type = "prob"))

rf_house_keys_file <- readRDS('rf_house_keys.rds')

rf_rhino_file <- readRDS('rf_rhino.rds')
rf_myotis_file <- readRDS('rf_myotis.rds')
rf_nyctalus_file <- readRDS('rf_nyctalus.rds')

rf_pipi_file <- readRDS('rf_pipi.rds')
rf_plecotus_file <- readRDS('rf_plecotus.rds')
rf_barba_file <- readRDS('rf_barba.rds')

#################################################################################
# Let's consolidate all the output data:

consolidate_results <- function(rf)
{
  matrix_M <- predict(rf , Event_data_test[,-1], type = "prob")
  results <- colMeans(matrix_M)
  return(results)
}

# "Is the unknown wav house_keys?"
HOUSE_KEYS <- consolidate_results(rf_house_keys_file)
# HOUSE_KEYS

RHINO <- consolidate_results(rf_rhino_file)
MYOTIS <- consolidate_results(rf_myotis_file)
NYCTALUS <- consolidate_results(rf_nyctalus_file)

PIPI <- consolidate_results(rf_pipi_file)
PLECOTUS <- consolidate_results(rf_plecotus_file)
BARBA <- consolidate_results(rf_barba_file)

# The matrices are of type "double", object of class "c('matrix', 'double', 'numeric')"

penultimate <- rbind(HOUSE_KEYS, RHINO, MYOTIS, NYCTALUS, PIPI, PLECOTUS, BARBA)

Final_result <- penultimate[order(penultimate[,1], decreasing = FALSE),]
print(Final_result)

#importance(rf_c_pip_file)

write.table(Final_result, file = "Final_result.txt", sep = "\t",
            row.names = TRUE, col.names = NA)

q()



