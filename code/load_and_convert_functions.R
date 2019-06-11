####### INTRODUCTION
# load and convert is a series of functions for import into diiferent work spaces
# @Author: Cooper Stansbury


check_when_save <- function(filepath){
  # 'function to see if the object can be saved to specified location
  # '@filepath: a string input. Should contain the file extension
  if (file.exists(filepath)) {
    print(paste("WARNING:'", normalizePath(filepath),
                "'already exists. File not saved. Please check your work."))
    print(paste('Command invoked from:', getwd()))
    stopifnot(!file.exists(filepath)) # throw an error to exit outer function calls
  } else {
    print(paste("File saving to '", normalizePath(filepath), "'", sep=""))
  }
}


read_csv_from_path <- function(filepath) {
  # 'function to read a csv file from a relative filepath and return a new data.frame
  # '@filepath string corresponding to the relative filepath
  if(!file.exists(filepath)) {
    print('ERROR: filepath does not exist.')
    print('Please make sure you are inputting a valid filepath realtive to: ')
    print(paste('read_xlsx_from_path invoked from:', getwd()))
  } else {
    data <- read.csv(filepath, header=TRUE)
    print(paste('Input object n rows:', toString(nrow(data))))
    print(paste('Input object n columns:', toString(nrow(data))))
    return(data)
  }
}


read_xlsx_from_path <- function(filepath) {
  # 'function to read an xlsx file from a relative filepath and return a new data.frame
  # '@filepath string corresponding to the relative filepath
  if(!file.exists(filepath)) {
    print('ERROR: filepath does not exist.')
    print('Please make sure you are inputting a valid filepath realtive to: ')
    print(paste('read_xlsx_from_path invoked from:', getwd()))
  } else {
      tryCatch( {library(readxl)},
        error=function(error_message) {
            message("Required package missing: 'readxl'.")
            message("Try installing the package and rerunning the command.")
            message("R system details:")
            message(error_message)
            return(NA)
        }
      )
      data <- as.data.frame(read_excel(filepath))
      print(paste('Input object n rows:', toString(nrow(data))))
      print(paste('Input object n columns:', toString(ncol(data))))
      return(data)
  }
}


save_rData <- function(rObject, dir, filename) {
  # 'function to save an RData object
  # '@rObject: object to save
  # '@dir: directory, including slash
  # '@filename: a name for the file, will be automatically appeneded with current date
  today_date = format(Sys.time(), "%m%d%Y")
  save_path = paste(dir, today_date, "-", filename , sep="")
  check_when_save(save_path)
  save(rObject, file = save_path, precheck=TRUE)
}


save_csv <- function(rObject, dir, filename) {
  # 'function to save a csv file
  # '@rObject: object to save
  # '@dir: directory, including slash
  # '@filename: a name for the file, will be automatically appeneded with current date
  today_date = format(Sys.time(), "%m%d%Y")
  save_path = paste(dir, today_date, "-", filename , sep="")
  check_when_save(save_path)
  write.csv(rObject,
            file=save_path,
            quote = TRUE,
            row.names =FALSE)
}


save_SAS_data <- function(rObject, dir, filename) {
  # 'function to save data as a SAS object
  # '@rObject: object to save
  # '@dir: directory, including slash
  # '@filename: a name for the file, will be automatically appeneded with current data
  tryCatch( {library(rio)},
            error=function(error_message) {
              message("Required package missing: 'rio'.")
              message("Try installing the package and rerunning the command.")
              message("R system details:")
              message(error_message)
              return(NA)
            }
  ) # end tryCatch

  today_date = format(Sys.time(), "%m%d%Y")
  save_path = paste(dir, today_date, filename , sep="")
  check_when_save(save_path)
  export(rObject, save_path)
}
