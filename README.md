# run_analysis.R

### Synopsis
This R script get two datasets (training and testing data) from Samsung Galaxy acceletrometer data and performs some transformations.

The final outcome is one tidy dataset containing averages of all measurements grouped by **subject** and **activity** (walking, sitting, laying, walking upstairs and downstairs). The final output is a file called **averages.txt** that will be written in the same directory as the main script.


### Requeriments

* the folder containing the dataset must be named as **UCI HAR Dataset** and placed in the same directory as **run_analysis.R**
* packages **reshape**, **dplyr** and **sqldf** must be installed in your R setup


### How it works

Once the script is run it gets both the **test** and **train** dataset separetely and then joins them in one only dataset. There's function **get_domain_dataset()** that get each dataset. This function joins activity, subject and apply correct names for each column.

Finally it generate the final dataset containing the averages of each measure by **subject** and **activity**.