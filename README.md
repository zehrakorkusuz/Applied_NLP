# Applied NLP Course Project 2024-2025 - Score Clinical Patient Notes


This repository contains the work done for the Applied NLP course at the University of Trento under the guidance of Professor Jacopo Staiano during the 2024-2025 academic year. The project focuses on the implementation of Natural Language Processing (NLP) techniques, including dataset processing, model training, and performance evaluation using advanced transformer-based models.

The goal of this project is to explore and compare the performance of ModernBERT against various DeBERTa variants. This involves setting up a Conda environment, working with real-world datasets, training models with different configurations, and assessing the models' effectiveness based on specific performance metrics.


**Environment Setup**: Use of Conda to create and manage the project environment.

**Dataset Processing**: Techniques for data preprocessing and management such as pseudolabeling

**Model Training**: Fine-tuning of ModernBERT and DeBERTa models.

**Performance Evaluation**: A comprehensive comparison of model results using different evaluation metrics.

**Hardware**: Kaggle P100 GPUs and Runpod A100 GPUs with VSCode Server Image.
 

## 2. Dataset

The dataset used in this project includes various files required for training and evaluation. The main dataset files are located in the `data/` directory. Ensure that the dataset files are properly placed in the respective directories before running the training scripts.

The dataset consists of several files that are used to train models for identifying clinical features in patient notes. Below are the key files and their descriptions:

## `patient_notes.csv`
- Contains approximately **40,000 patient note history portions**.
- Only a subset of these notes has feature annotations.
- Patient notes from the test set are **not** included in the public version of this file.
- **Key Columns**:
  - `pn_num`: Unique identifier for each patient note.
  - `case_num`: Unique identifier for the clinical case associated with the patient note.
  - `pn_history`: Text detailing the patient encounter, as recorded by the test taker.

## `features.csv`
- Contains the **rubric of features** or **key concepts** for each clinical case.
- **Key Columns**:
  - `feature_num`: Unique identifier for each feature.
  - `case_num`: Unique identifier for each clinical case.
  - `feature_text`: A description of the feature.

## `train.csv`
- Contains feature annotations for **1,000 patient notes** (100 notes per case for 10 different clinical cases).
- **Key Columns**:
  - `id`: Unique identifier for each patient note/feature pair.
  - `pn_num`: Identifier for the annotated patient note.
  - `feature_num`: Identifier for the feature annotated in the note.
  - `case_num`: Identifier for the clinical case to which the patient note belongs.
  - `annotation`: The text(s) within the patient note that indicate the feature. A feature may appear multiple times within a single note.
  - `location`: Character spans in the note indicating where the annotation appears. Multiple spans are separated by a semicolon if needed.


## Evaluation

### Evaluation using Micro-Averaged F1 Score

In this competition, the evaluation metric used is the **micro-averaged F1 score**. Here's a breakdown of how the evaluation works:

### How Spans Are Represented

Each prediction consists of a set of **character spans**, where each span is a pair of indexes that represent a range of characters within the text. For example, a span `i j` corresponds to the characters starting at index `i` and ending at index `j`, inclusive of `i` and exclusive of `j` in Python's slicing notation (`i:j`).

### Scoring Mechanism

For each instance, we have:

- **Ground-truth spans**: The true set of character spans.
- **Predicted spans**: The predicted set of character spans.

We score each character index based on whether it appears in both ground-truth and predicted spans:

- **TP (True Positive)**: A character index that appears in both the ground-truth and predicted spans.
- **FN (False Negative)**: A character index that appears in the ground-truth but not in the predicted spans.
- **FP (False Positive)**: A character index that appears in the predicted spans but not in the ground-truth spans.

### Micro-Averaging

Once we identify the TPs, FNs, and FPs for each instance, we aggregate these counts across all instances. We then compute the micro-averaged F1 score using the following formula:

$$
F1 = \frac{2 \times TP}{2 \times TP + FP + FN}
$$

Where:
- **TP**: Total number of true positives across all instances.
- **FP**: Total number of false positives across all instances.
- **FN**: Total number of false negatives across all instances.

### Example

Suppose we have an instance with the following ground-truth and predicted spans:

| Ground-truth | Prediction    |
|--------------|---------------|
| 0 3; 3 5     | 2 5; 7 9; 2 3 |

From these spans, the corresponding sets of indices are:

| Ground-truth | Prediction    |
|--------------|---------------|
| 0 1 2 3 4    | 2 3 4 7 8     |

We can then compute:

- **TP**: The common indices between the ground-truth and the prediction: `{2, 3, 4}` → Size = 3
- **FN**: Indices in the ground-truth but not in the prediction: `{0, 1}` → Size = 2
- **FP**: Indices in the prediction but not in the ground-truth: `{7, 8}` → Size = 2

Now, the micro-averaged F1 score for this instance can be computed as:

$$
F1 = \frac{2 \times 3}{2 \times 3 + 2 + 2} = \frac{6}{10} = 0.6
$$


So, the **micro-averaged F1 score** is calculated by aggregating the TPs, FNs, and FPs across all instances and applying the F1 formula. The final score provides a comprehensive measure of how well the predictions align with the ground-truth spans.


## 4. Model Performance

Below is a table summarizing the performance of various models trained in this project. Because of GPU constraints some models are trained only 1-fold:

| Model Name        | Fold | Epoch | Accuracy | Notes                        |
|------------------|------|-------|----------|------------------------------|
| DeBERTa-v3-baseline | 5    | 3     | 86%    | train.csv |
| DeBERTa-v3-large | 5    | 3     | 88%    | train.csv|
| DeBERTa-v3-large-with-pseudo | 1    | 97%     | 91.8%    | train.csv +pseudo.csv |
| ModernBERT-base | 1    | 4     | 80%    | train.csv |
| ModernBERT-base-with-pseudo | 1  | 4       | 95%     | 91.6%    | train.csv + pseudo.csv |


- DeBERTA-v3-large initially trained with train.csv; then used to generate pseudolabels and the model weights loaded and finetuned with the pseudolabels - which caused data leakage and >90% CV score. 

- ModernBERT trained with combination of pseudolabels generated with deberta-v3-large model inferences, and had less leakage compared to previous approach. 

- While in the competition ensemble model, and pseudolabels usage might be favorable to increase the accuracy; in the industrial cases baseline models might be sufficient. 



    #### Pseudolabels & Data Leakage

    "Specifically, if there are a lot of leaks, the cv will be 0.9 or higher. This is likely to occur if there is text in the pseudo-label that is similar to the validation text. Therefore, to avoid this, the pseudo-label should not be calculated using the average of the predictions, and should be used as is without the average."[^1]


So, in order to overcome the leakage, scoring and use of pseudolabels can be both advantageous as well as leading to leakage. 

## Conclusion

ModernBERT compared with the deberta-v3-large and deberta-v3-base model, provides a competitive score as well as faster training times and 16x token window size. It allows scaling models to real-world cases where patient notes, lab test etc. can have longer context size as well requiring faster evaluation time and retrieval. 


## Project Env Setup

Because the models are trained on runpod GPUs, it required using one storage ~30 GB and various GPUs based on availability. setup_env.sh file is used to provide instant access to training environment after connection to the instance. As a template, VSCode Docker Image is utilized.  

## 1. Environment Setup

To set up the environment, run the `setup_env.sh` script. This script will download and install Miniconda, create a new Conda environment, install the required dependencies, and set up an IPython kernel for Jupyter support.

### Steps to Run `setup_env.sh`
1. Open a terminal.
2. Navigate to the project directory.
3. Run the following command:

   ```sh  
   bash setup_env.sh  
   ```

This will set up the Conda environment named `modern-bert` and install all necessary dependencies.


## 2. Folder Structure

The project directory follows this structure:

 ## Project Directory Structure

 Contains the environment requirements; model folders with weights and tokenizers, also including fast-tokenizer for deberta-v3-large model

Data folder contains the dataset provided by the competition

    *P.S. Pseudolabels.csv is generated by the model initially trained (deberta-v3-large 5-fold) and the notebook can be found in the notebooks folder. See notebooks/generate_pseudolabels_with_deberta-v3-large.ipynb

    **Later notebooks such as modern-bert with and without pseudolabels, and training deberta-v3-large with pseudolabels trained using papermill on Runpod server. Notebooks with outputs can be found under the notebooks-papermill-outputs folder.

```
project_root/
│── .env
│── .gitignore
│── =4.48.0
│── conda-requirements.txt
│── data/
│   ├── train.csv
│   ├── feature/
│   ├── test.csv
│   ├── pseudolabels.csv *
│── deberta-tokenizer/
│   ├── ...
│── deberta-v2-3-fast-tokenizer/
│── deberta-v3-large/
│── deberta-v3-large-5-folds-public/
│── deberta-v3-large-5-folds-public.zip
│── deberta-v3-large-finetuned-with-pseudolabels/
│── deberta-with-pseudo.ipynb
│── kaggle.json
│── miniconda/
│── miniconda.sh
│── Miniconda3-latest-Linux-x86_64.sh
│── Miniconda3-latest-Linux-x86_64.sh3/
│── modern-bert/
│── modern-bert-train-pseudo.ipynb
│── nohup.out
│── notebooks/
│── notebooks-papermill-outputs/ **
│── README.md
│── requirements.txt
```


## References

1. https://www.kaggle.com/competitions/nbme-score-clinical-patient-notes/discussion/323156
2. https://www.kaggle.com/code/yasufuminakama/nbme-deberta-base-baseline-train
3. https://huggingface.co/microsoft/deberta-v3-base
4. https://huggingface.co/blog/modernbert
5. https://www.kaggle.com/code/neos960518/ensembling-deberta-models-bronze-medal-top-8



