#!/usr/bin/env Rscript

# Capture commandline arguments
Sys.setenv(RSTUDIO_PANDOC= "/Applications/RStudio.app/Contents/MacOS/pandoc")
args = commandArgs(trailingOnly=TRUE)

# Load packages
library(rmarkdown)
library(knitr)
library(readtext)

# Store arguments in variables

base_dir <-  "~/offline_research/git_repos/usc-rdojo.github.io/" # Base directory
input <- args[1]    # Where is the input file located?
input_dir <- getwd()
print(input_dir)

images_path <- strsplit(input, '\\.')[[1]][1]
#images_path <- paste('images/R/', images_path, '/', sep='')

output_file <- tail(strsplit(input, '/')[[1]], 1)
output_file <- strsplit(output_file, '\\.')[[1]][[1]]
output_file <- paste(output_file, '.md', sep='')

# Generate path for images


if (file.exists(paste('images/R/', images_path, '/', sep=''))){
  fd <- paste(input_dir, 'images/R/', images_path, '/', sep='')
  fl <- list.files(paste('images/R/', images_path, '/', sep=''))

  images_path <- paste('images/R/', images_path, '/',sep='')

  for (f in fl){
    file.copy(paste(images_path, f, sep=''), paste('~/offline_research/git_repos/usc-rdojo.github.io/',
                                           images_path, sep=''))
    
    
  }
} else (images_path <- paste('images/R/', images_path, '/',sep=''))




# Create images/R/ sub-directory for presentation
dir.create(file.path(base_dir, images_path), showWarnings = FALSE)

notebook_file <- readtext(input)
yml_header <- readtext(paste(input_dir, '/yml_header.txt',sep=''))
yml_header_splt <- strsplit(yml_header$text, '---')

knitr_opts = paste('\n\n\n```{r, echo=F}\n\nknitr::opts_knit$set(base.dir = \"~/offline_research/git_repos/usc-rdojo.github.io/\", base.url = \"/")\nknitr::opts_chunk$set(fig.path = "', images_path, '")\n\n```', sep='')

notebook_file.text <- strsplit(notebook_file$text, '---')

notebook_file.text[[1]][[2]] = yml_header_splt[[1]][[2]]
notebook_file.text[[1]][3] <- paste(knitr_opts, notebook_file.text[[1]][3], sep='', collapse='\n')

notebook_file$text <- paste(notebook_file.text[[1]], sep='', collapse='---')



fileConn<-file("temp_rdojo_pres.Rmd")
writeLines(notebook_file$text, fileConn)
close(fileConn)


render(input = 'temp_rdojo_pres.Rmd',
       output_file = output_file,
       output_dir = paste(base_dir, '_posts', sep=''),
       output_format = md_document(preserve_yaml = TRUE))

file.remove('temp_rdojo_pres.Rmd')
