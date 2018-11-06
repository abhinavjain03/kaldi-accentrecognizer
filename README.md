# Accent Embeddings - Accent Classifier
This repo is a part of
1. [Accent Embeddings - HMM & Baseline](https://github.com/abhinavjain03/kaldi-accents "AE - HMM & Baseline")
2. Current
3. [Accent Embeddings - Multitask](https://github.com/abhinavjain03/kaldi-accentsmultitask "AE - MTL") 

and form the complete work mentioned in the paper submitted in Interspeech 2018. [Paper](https://www.isca-speech.org/archive/Interspeech_2018/abstracts/1864.html "IS1864").

Pre-Requisites - 
1. You have worked with the Kaldi toolkit and are quite familiar with it, meaning you are familiar with training a DNN Acoustic Model and know the requirements.
2. We use Mozilla CommonVoice Dataset for all the experiments. A detailed split can be found at - 
[Accents Unearthed](https://sites.google.com/view/accentsunearthed-dhvani/ "AccentsUnearthed")

## What we are doing?
We train a DNN with a bottleneck layer with MFCCs as input and accent class as the target. The network contains a bottleneck layer. The bottleneck layer is expected to learn a feature representation of the accents. We extract these bottleneck features to be further used by [Accent Embeddings - HMM & Baseline](https://github.com/abhinavjain03/kaldi-accents "AE - HMM & Baseline") & [Accent Embeddings - Multitask](https://github.com/abhinavjain03/kaldi-accentsmultitask "AE - MTL").
This is the script [my_run.sh](./my_run.sh).

## Data Prep
1. We are using Train7 for training the network.

**Note :** In the scripts, Train7 - cv_train_nz

## Steps
1. **MFCCS** - The script creates both standard and hires MFCCS of train data provided the correct path.
2. **alignments (accent alignments)** - The script first creates triphone state alignments for the training data (This is done just to get the number of frames but there is an easy way to do it also). Then use the text format of the alignments to create accent alignments which contains accent class for every frame of each utterance. This is done using [temp.cc](./temp.cc) which takes a file containing a table with utterance id and its corresponding accent class as input. 
3. Once all these are done, xconfig and training is standard.


This repo along with [Accent Embeddings - HMM & Baseline](https://github.com/abhinavjain03/kaldi-accents "AE - HMM & Baseline") & [Accent Embeddings - Multitask](https://github.com/abhinavjain03/kaldi-accentsmultitask "AE - MTL") form the complete work mentioned in the [Paper](https://www.isca-speech.org/archive/Interspeech_2018/abstracts/1864.html "IS1864").
