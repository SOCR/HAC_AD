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


check_column_names <- function(df, replace=TRUE) {
  # 'function to handle column names the contain special characters
  # '@df: data frame to check for improperly formatted column names
  # '@replace: replace = TRUE will return a new data frame with special
  # characters removed, FALSE will only print out problematic column names
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


use_first_row_as_col_names <- function(df) {
  # 'function that uses the first row of a data frame as column names
  # 'returns new data frame
  # '@df: data.frame
  names(df) <- as.character(unlist(df[1,]))
  return(df[-1,])
}


read_multi_character_delim <- function(filepath, delimiter, header=TRUE) {
  # 'function to read file delimited with a multi-character separator
  # '@filepath: string corresponding to the realtive fil path containing the data
  # '@delimiter: string with the separator
  file_connection <- file(filepath)
  data <- readLines(file_connection)
  close(file_connection)

  records <- sapply(data, strsplit, split=delimiter)
  tmp_df <- data.frame(t(sapply(records,c)))
  rownames(tmp_df) <- 1: nrow(tmp_df)
  df <- as.data.frame(tmp_df,stringsAsFactors = FALSE)

  if (header) {
    df <- use_first_row_as_col_names(df)
    return(df)
  } else {
    return(df)
  }
}


read_multi_character_delim_fast <- function(filepath, 
                                            delimiter,
                                            maxLength=20000000,
                                            v=TRUE, header=TRUE) {
  
  # 'function to read file delimited with a multi-character separator
  # '@filepath: string corresponding to the realtive fil path containing the data
  # '@delimiter: string with the separator
  # '@maxLength: need to guess at number or rows (which can sometimes be obtained 
  #  using 'wc -l [file]) in order for fread() to sample correctly. Default is set
  #  to over-estimate our largest file.
  # '@v:verbose: passed to fread()
  # '@header: boolen that calls use_first_row_as_col_names().
  # this improves upon the example above by using data.table and fread
  # See: https://stackoverflow.com/questions/1727772
  
  library(data.table)
  gc() # careful with memory
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
    return(df)
    gc()
  } else {
    return(df)
    gc()
  }
}


read_notes_custom_delim <- function(filepath, 
                                    delimiter,
                                    maxLength=20000000,
                                    skip=FALSE,
                                    v=TRUE, header=TRUE) {
  
  # 'function to read the NOTES file delimited with a multi-character separator
  # '@filepath: string corresponding to the realtive fil path containing the data
  # '@delimiter: string with the separator
  # '@maxLength: need to guess at number or rows (which can sometimes be obtained 
  #  using 'wc -l [file]) in order for fread() to sample correctly. Default is set
  #  to over-estimate our largest file.
  # '@v:verbose: passed to fread()
  # '@header: boolen that calls use_first_row_as_col_names().
  # this improves upon the example above by using data.table and fread
  # See: https://stackoverflow.com/questions/1727772
  
  library(data.table)
  library(readr)
  gc() # careful with memory
  
  # can't use fread because comment.char() note implemented:
  # https://github.com/Rdatatable/data.table/issues/856
  # source file contains many clank lines
  
  
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
    return(df)
    gc()
  } else {
    return(df)
    gc()
  }
}


read_csv_from_path <- function(filepath,
                               header=TRUE,
                               maxLength=2000000) {
  # 'function to read a csv file from a relative filepath and return a new data.frame
  # '@filepath string corresponding to the relative filepath
  # '@maxLength: need to guess at number or rows (which can sometimes be obtained 
  #  using 'wc -l [file]) in order for fread() to sample correctly. Default is set
  #  to over-estimate our largest file.
  # '@header: boolen passed to read.table
  
  library(data.table)
  data <-  read.table(file=filepath,
                header=header,
                nrows = maxLength)
  print(paste('Input object n rows:', toString(nrow(data))))
  print(paste('Input object n columns:', toString(nrow(data))))
  return(data)
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
