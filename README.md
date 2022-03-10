# Mechanical Ventilation

The purpose of this work was to build a model to predict extubation failure. Extubation failure happens when a patient is re-intubated less than 72 hours after extubation (depending on definition), and is associated with higher morbidity and mortality. The intent was to use time series data from the 24 hours preceding extubation to predict the patient outcome.

The data being used here is taken from the MIMIC-III database, an open source, anonymised database containing patient data collected in the ICU.

Below is an overview of what is contained in each notebook:
- **0_patient_selection.ipynb** - explained in the notebook.
- **1_re_intubation.ipynb** - explained in the notebook.
- **2_dataset_prep.ipynb** - defines weaning success and failure, and selects patients who meet those criteria only.
- **3_static_features.ipynb** - queries MIMIC-III for static features.
- **4_general_features.ipynb** - queries MIMIC-III for general dynamic features.
- **5_ventilator_features.ipynb** - queries MIMIC-III for ventilator-specific features.
- **6_time_series_generator.ipynb** - converts the raw data into 24-interval time series.
- **7_pre_processing.ipynb** - prepares the data for model training and testing, including data split and standardisation.
- **8_models.ipynb** - implements different models to predict extubation failure.