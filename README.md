# mechanical-ventilation

## Files:
- *0_patient_selection.ipynb* - generates a list of ICU patients that meet certain criteria.
- *1_re_intubation.ipynb* - calculates times between subsequent episodes of ventilation and selects patients that meet certain criteria.
- *2_dataset_prep.ipynb* - applies outcome criteria to patients generated in *1_re_intubation.ipynb* and selects a final set of patients with associated binary classification.
- *3_static_features.ipynb* - queries MIMIC for static features.
- *4_general_features.ipynb* - queries MIMIC for general dynamic features.
- *5_ventilator_features.ipynb* - queries MIMIC for ventilator-specific features.
- *6_time_series_generator.ipynb* - processes raw data generated in *4_general_features.ipynb* and *5_ventilator_features.ipynb* to give hourly time series.
- *7_pre_processing.ipynb* - combines data from *3_static_features.ipynb* and *6_time_series_generator.ipynb*, splits into training, validation and test sets, and performs Z-score normalisation.
- *8_models.ipynb* - training and testing of logistic regression and RNN models, and comparison to clinical indicators.

## Folders:
- *data* - contains db_details.npy (the login details for my local database), as well as being the folder where outputs of the notebooks are stored
- *plots* - folder where all plots generated in these notebooks are stored.
- *queries* - contains PostgreSQL queries used to access data in MIMIC-III.
- *Unused Notebooks* - a collection of notebooks that aren't used for this project but that I don't want to get rid of just yet in case the code turns out to be useful.

## Not included in this repository:
- These notebooks require the MIMIC-III database (https://mimic.physionet.org/) to be locally installed.
- Outputs of these notebooks are stored in *data*, however they haven't been uploaded here because of storage constraints.
- Plots generated in these notebooks are stored in *plots*, however they haven't been uploaded here.