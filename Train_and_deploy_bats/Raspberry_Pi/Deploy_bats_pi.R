# $ cd /home/pi/Desktop/deploy_classifier/ && Rscript Deploy_bats_pi.R
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

# print(function(x) length(x$data))
# print("Above.")
# Keep the extracted feature and merge in a single data frame for further analysis
Event_data_test <- do.call("rbind", c(lapply(TDs, function(x) x$data$event_data), list(stringsAsFactors = FALSE)))

nrow(Event_data_test)
num_audio_events <- nrow(Event_data_test)

# To look at the predictions 
# print("Is the unknown wav a c_pip?")
test_file <- readRDS('rf_c_pip.rds')
# print(test_file)
# predict(test_file , Event_data_test[,-1], type = "prob")

# print("Is the unknown wav a c_pip?")
# head(predict(test_file , Event_data_test[,-1], type = "prob"))

rf_c_pip_file <- readRDS('rf_c_pip.rds')
rf_s_pip_file <- readRDS('rf_s_pip.rds')
rf_nattereri_file <- readRDS('rf_nattereri.rds')
rf_noctula_file <- readRDS('rf_noctula.rds')
rf_plecotus_file <- readRDS('rf_plecotus.rds')
rf_rhino_hippo_file <- readRDS('rf_rhino_hippo.rds')
rf_house_keys_file <- readRDS('rf_house_keys.rds')

#######################################################################################
# Let's consolidate the data a bit:
# Create a matrix of prediction results for Class_01, (Nattereri = True)
matrix_01 <- predict(rf_nattereri_file , Event_data_test[,-1], type = "prob")
# matrix_01
# print("Is the unknown wav a nattereri?")
# colMeans(matrix_01)

matrix_02 <- predict(rf_c_pip_file , Event_data_test[,-1], type = "prob")
# matrix_02
# print("Is the unknown wav a c_pip?")
# colMeans(matrix_02)

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

# "Is the unknown wav a c_pip?"
C_PIP <- consolidate_results(rf_c_pip_file)
# C_PIP
# "Is the unknown wav a s_pip?"
S_PIP <- consolidate_results(rf_s_pip_file)
# S_PIP
# "Is the unknown wav a nattereri?"
NATTERERI <- consolidate_results(rf_nattereri_file)
# NATTERERI
# "Is the unknown wav a noctula?"
NOCTULA <- consolidate_results(rf_noctula_file)
# NOCTULA
# "Is the unknown wav a plecotus?"
PLECOTUS <- consolidate_results(rf_plecotus_file)
# PLECOTUS

# "Is the unknown wav a rhino_hippo?"
RHINO_HIPPO <- consolidate_results(rf_rhino_hippo_file)
# RHINO_HIPPO

# The matrices are of type "double", object of class "c('matrix', 'double', 'numeric')"

penultimate <- rbind(C_PIP, S_PIP, NATTERERI, NOCTULA, PLECOTUS, RHINO_HIPPO, HOUSE_KEYS)

Final_result <- penultimate[order(penultimate[,1], decreasing = FALSE),]
# print(Final_result)
# print(num_audio_events)

# print("This, below, gives nice new set of row labels:")
dfnew4 <- cbind(rownames(Final_result), data.frame(Final_result, row.names=NULL))
# dfnew4

# Then we can get variables such as batName:
print("This is RHINO_HIPPO:")
currBatName <- dfnew4[c(1),c(1)]
currBatName

t <- Sys.time()
num_species = 1                                                            # This get overwritten if csv file is found.


if(file.exists("From_R_01.csv")) 
{
    print("This should import previous data:")
    prevData <- read.csv("From_R_01.csv", header=TRUE)
    # str(prevData)
    print(prevData)
    
    print("This is  RHINO_HIPPO:")
    prevBatName <- prevData[c(1),c(1)]
    print(prevBatName)
    
    print("IS this the num_species value?")
    num_species <- prevData[c(1),c(4)]
    print(num_species)

    print("This gives the newest time in previous data:")
    newValue <- prevData[c(1),c(3)]
    print(newValue)
}

print("This should give RHINO_HIPPO  7  time  num_species:")
dfnew6 <- cbind(data.frame(currBatName), num_audio_events, t, num_species)
dfnew6

print("And change the column names:")
colnames(dfnew6) <- c("bat_name","frequency", "time", "num_species")
dfnew6


print("This will add the new row to the old ones if we want to:")
if(file.exists("From_R_01.csv")) 
{
    if( prevBatName == currBatName)      # Both are RHINO_HIPPO.
    {
        print("Yes it was!")
    }
    # TODO: Put an else command with next 3 lines in it:
    print("Now add the rows to old ones:")
    df7 <- rbind(dfnew6, prevData)
    df7
} else { df7 <- dfnew6 }


print("END")

#importance(rf_c_pip_file)

write.table(Final_result, file = "Final_result.txt", sep = "\t", row.names = TRUE, col.names = NA)
write.table(df7, file = "From_R_01.csv", sep = ",", row.names = FALSE, col.names = TRUE)
q()




