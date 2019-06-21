####### INTRODUCTION
# load and convert is a series of functions for import into diiferent work spaces
# @Author: Cooper Stansbury

print(paste0("Source 'load_and_convert_functions.R' Successful: ", Sys.time()))


check_when_save <- function(filepath){
  #' function to see if the object can be saved to specified location
  #' @param filepath: a string input. Should contain the file extension
  
  if (file.exists(filepath)) {
    print(paste("WARNING:'", normalizePath(filepath),
                "'already exists. File not saved. Please check your work."))
    print(paste('Command invoked from:', getwd()))
    stopifnot(!file.exists(filepath)) # throw an error to exit outer function calls
  } else {
    print(paste("File saving to '", normalizePath(filepath), "'", sep=""))
  }
}


check_column_names <- function(df, replace=TRUE) {
  #' function to handle column names the contain special characters
  #' @param df: data frame to check for improperly formatted column names
  #' @param replace: replace = TRUE will return a new data frame with special
  #' characters removed, FALSE will only print out problematic column names
  
  temp_df <- df
  for (column_name in colnames(df)) {
    only_underscores <- !grepl("[^0-9A-Za-z_///' ]", column_name)
    print(paste('column name: ', column_name,
                '--> passed special character test: ', only_underscores))

    if (!only_underscores) {
      print(paste("WARNING:", column_name , "contains problematic characters"))

      if (replace) {
        print(paste("stripping special characters from: ", column_name))
        new_colname <- gsub("[^0-9A-Za-z_///' ]","", column_name)

        # SAS column names cannot begin with numeric character
        if (grepl("[[:digit:]]", substring(new_colname, 1, 1))) {
          new_colname <- paste0("_", new_colname)
        }

        names(temp_df)[names(temp_df) == column_name] <- new_colname
        print(paste("column names changd to: ", new_colname))
        return(temp_df)
      } else{}
    } else{}
  }
}


print_dimensionality <- function(df){
  #' function to print the number of rows and columns for a given data.frame
  #' @param df: the input data.frame
  
  print(paste('Input object n rows:', toString(nrow(df))))
  print(paste('Input object n columns:', toString(ncol(df))))
}


use_first_row_as_col_names <- function(df) {
  #' function that uses the first row of a data frame as column names
  #' returns new data frame
  #' @param df: data.frame
  
  names(df) <- as.character(unlist(df[1,]))
  return(df[-1,])
}


read_multi_character_delim <- function(filepath, delimiter, header=TRUE) {
  #' function to read file delimited with a multi-character separator
  #' @param filepath: string corresponding to the realtive fil path containing the data
  #' @param delimiter: string with the separator
  
  start.time <- Sys.time() # get seconds to benchmark performance
  
  #' @NOTE: open connection 
  file_connection <- file(filepath)
  data <- readLines(file_connection)
  close(file_connection)

  #' @NOTE: split each record
  records <- sapply(data, strsplit, split=delimiter)
  tmp_df <- data.frame(t(sapply(records,c)))
  rownames(tmp_df) <- 1: nrow(tmp_df)
  df <- as.data.frame(tmp_df,stringsAsFactors = FALSE)

  if (header) {
    df <- use_first_row_as_col_names(df)
    print_dimensionality(df)
    end.time <- Sys.time()
    print(paste("Execution time:", end.time - start.time))
    return(df)
  } else {
    print_dimensionality(df)
    end.time <- Sys.time()
    print(paste("Execution time:", end.time - start.time))
    return(df)
  }
}


read_multi_character_delim_fast <- function(filepath, 
                                            delimiter,
                                            maxLength=20000000,
                                            v=TRUE, header=TRUE) {
  #' function to read file delimited with a multi-character separator
  #' @param filepath: string corresponding to the realtive fil path containing the data
  #' @param delimiter: string with the separator
  #' @param maxLength: need to guess at number or rows (which can sometimes be obtained 
  #' using 'wc -l [file]) in order for fread() to sample correctly. Default is set
  #' to over-estimate our largest file.
  #' @param v (verbose): passed to fread()
  #' @param header: boolen that calls use_first_row_as_col_names().
  #' this improves upon the example above by using data.table and fread
  #' See: https://stackoverflow.com/questions/1727772
  
  start.time <- Sys.time()
  library(data.table)
  gc() # clean-up
  tmp_tbl <- fread(filepath,
                   sep=NULL,
                   header=FALSE,
                   verbose=v,
                   nrows=maxLength,
                   na.strings=NULL,
                   fill=TRUE,
                   strip.white=TRUE,
                   blank.lines.skip=TRUE,
                   stringsAsFactors=FALSE)
  
  
  print('1-d table read successful.')
  df <- as.data.frame(setDT(tmp_tbl)[, tstrsplit(tmp_tbl$V1, delimiter)])
  print('delimiter parsing successful.')

  if (header) {
    df <- use_first_row_as_col_names(df)
    print_dimensionality(df)
    end.time <- Sys.time()
    print(paste("Execution time:", end.time - start.time))
    return(df)
    gc()
  } else {
    print_dimensionality(df)
    end.time <- Sys.time()
    print(paste("Execution time:", end.time - start.time))
    return(df)
    gc()
  }
}


read_notes_custom_delim <- function(filepath, 
                                    delimiter,
                                    maxLength=20000000,
                                    skip=FALSE,
                                    v=TRUE, header=TRUE) {
  #' function to read the NOTES file delimited with a multi-character separator
  #' @param filepath: string corresponding to the realtive fil path containing the data
  #' @param delimiter: string with the separator
  #' @param maxLength: need to guess at number or rows (which can sometimes be obtained 
  #' using 'wc -l (file)) in order for fread() to sample correctly. Default is set
  #' to over-estimate our largest file.
  #' @param v (verbose): passed to fread()
  #' @param header: boolen that calls use_first_row_as_col_names().
  #' this improves upon the example above by using data.table and fread
  #' See: https://stackoverflow.com/questions/1727772
  
  start.time <- Sys.time()
  library(data.table)
  library(readr)
  gc() # clean-up
  
  #' @NOTE: can't use fread because comment.char() note implemented:
  #' https://github.com/Rdatatable/data.table/issues/856
  #' source file contains many blank lines
  
  
  tmp_tbl <- as.data.table(read_table(filepath,
                        n_max = maxLength,
                        col_names = FALSE,
                        skip_empty_rows=skip,
                        progress=TRUE))
  
  gc() # careful with memory
  print('1-d table read successful.')
  print(paste('n raw records read: ', nrow(tmp_tbl)))
  df <- as.data.frame(setDT(tmp_tbl)[, tstrsplit(tmp_tbl$X1, delimiter)])
  print('delimiter parsing successful.')
  print(paste('n parsed records: ', nrow(df)))
  
  if (header) {
    df <- use_first_row_as_col_names(df)
    print_dimensionality(df)
    end.time <- Sys.time()
    print(paste("Execution time:", end.time - start.time))
    return(df)
    gc()
  } else {
    print_dimensionality(df)
    end.time <- Sys.time()
    print(paste("Execution time:", end.time - start.time))
    return(df)
    gc()
  }
}


get_first_n_splits <- function(string, pattern, n) {
  #' function to split a st ring on the first n occurences of a given input
  #' @param string: the string value split (expected to be passed via 'apply')
  #' @param pattern: the string value to split on
  #' @param n: the number of occurences of the the 'pattern' to split before stopping
  
  return(unlist(strsplit(string, pattern))[1:n])
}



read_labs <- function(filepath) {
  #' function to read the labs.dsv into a new data.frame
  #' this function is intended ONLY for the labs file
  #' @param filepath string corresponding to the relative filepath
  
  start.time <- Sys.time()
  library(readr)
  library(data.table)
  gc()
  tmp_tbl <- read_table(filepath,
                        col_names = FALSE,
                        progress=TRUE)
  #' @NOTE: these parameters are hard-coded specifically for this file
  tmp_tbl_2 <- as.data.frame(t(sapply(tmp_tbl$X1, get_first_n_splits, pattern=",", n=20)))
  rownames(tmp_tbl_2) <- NULL
  df <- use_first_row_as_col_names(tmp_tbl_2)
  print_dimensionality(df)
  end.time <- Sys.time()
  print(paste("Execution time:", end.time - start.time))
  return(df)
}


read_xlsx_from_path <- function(filepath) {
  #' function to read an xlsx file from a relative filepath and return a new data.frame
  #' @param filepath string corresponding to the relative filepath
  
  start.time <- Sys.time()
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
      df <- as.data.frame(read_excel(filepath))
      print_dimensionality(df)
      end.time <- Sys.time()
      print(paste("Execution time:", end.time - start.time))
      return(df)
  }
}


save_rData <- function(rObject, dir, filename) {
  #' function to save an RData object
  #' @param rObject: object to save
  #' @param dir: directory, including slash
  #' @param filename: a name for the file, will be automatically appeneded with current date
  
  today_date = format(Sys.time(), "%m%d%Y")
  save_path = paste(dir, today_date, "-", filename , sep="")
  check_when_save(save_path)
  save(rObject, file = save_path, precheck=TRUE)
}


save_csv <- function(rObject, dir, filename) {
  #' function to save a csv file
  #' @param rObject: object to save
  #' @param dir: directory, including slash
  #' @param filename: a name for the file, will be automatically appeneded with current date
  
  today_date = format(Sys.time(), "%m%d%Y")
  save_path = paste(dir, today_date, "-", filename , sep="")
  check_when_save(save_path)
  write.csv(rObject,
            file=save_path,
            quote = TRUE,
            row.names =FALSE)
}
