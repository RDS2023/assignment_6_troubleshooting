# # # # # # # # # # # # # # # #
# # # # # Assignment 8 # # # # 
# # # # # # # # # # # # # # # # 
# # # # FIX MY CODE! :) # # # #
# # # # # # # # # # # # # # # #

# The following code is meant to do some exploration of the dragons data,
# specifically looking at diet composition. However, it has a lot of problems. 
# You're going to encounter several errors as you try to run it. Troubleshoot 
# the errors and fix the code so that it runs smoothly. Also add comments to 
# explain what was wrong and why the code returned a given error message, 
# warning, or unexpected output. Go as in depth as you can with your 
# explanations (not just saying, for example, "there is a comma missing", but 
# explaining, "because a comma is missing, we are not indexing rows when trying 
# to subset this data frame").

# Load DBI package
library(DBI)

# Establish database connection
dragons_db <- dbConnect(RSQLite::SQLite(), 
                        "../../Course Material/Data/dragons/dragons.db")

# Import diet table
diet <- dbGetQuery(dragons_db, "SELECT * FROM diet;")

# Get columns 2 through 4 plus 6
samples <- diet[2, 3, 4, 6] 

# What different types of items are in the diet samples?
unique(item) 

# Which ones of these are herbivores?
herbivores <- c(Domestic cow, Domestic goat, Mule deer, Mountain goat, Moose) 

# Filter only rows for which item is a herbivore
herb <- samples[samples$item %in% herbivores] 

# Add a column for domestic or not
herb$domestic <- ifelse(grepl("Domestic", herb$item), "1", "0") 

# Transform column into logical
herb$domestic <- as.logical(herb$domestic)

# How many domestic? 
sum(herb$domestic)

# How many not domestic?
nrow(herb - sum(herb$domestic)) 

# Find IDs of dragons that eat non-domestic animals
dnd <- unique(herb[herb$domestic = FALSE, ]$dragon_id) 

# How many of them are there?
lenght(dnd) 

# For each dragon that also eats non-domestic animals, calculate percent of 
# domestic animals over total number of items in diet
percent_domestic <- c()

for (i in 1:length(dnd)) {
  n_domestic <- nrow(herb[herb$dragon_id == dnd & 
                            herb$domestic == TRUE, ])
  n_total <- nrow(diet[diet$dragon_id == dnd,])
  percent_domestic[i] <- n_domestic/n_total * 100
} 

# For those that eat > 75% domestic animals, get body size
morphometrics <- dbGetQuery(dragons_db, "SELECT * FROM morphometrics;")

body_size <- c()

for (i in 1:length(dnd)) {
  if (percent_domestic[i] > 75) {
    body_size[i] <- morphometrics[
      morphometrics$dragon_id == dnd[i], 
      ]$total_body_length_cm
  } else {body_size[i] <- NA}
}
