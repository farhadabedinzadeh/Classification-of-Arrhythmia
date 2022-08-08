# Classify Time Series Using Deep Learning

This repository has information about how the deep convolutional neural network (CNN) can be used to classify human electrocardiogram (ECG) data.
The data used in this repository are publicly available from [PhysioNet](https://physionet.org/).
In this source, you use ECG data gathered from three groups of individuals: those with cardiac arrhythmia (ARR), congestive heart failure (CHF), and normal sinus rhythms (NSR). You utilize a total of 162 ECG recordings from three PhysioNet databases: [the MIT-BIH Arrhythmia Database](https://www.physionet.org/content/mitdb/1.0.0/), [the MIT-BIH Normal Sinus Rhythm Database](https://www.physionet.org/content/nsrdb/1.0.0/), and the T[he BIDMC Congestive Heart Failure Database](https://www.physionet.org/content/chfdb/1.0.0/). In particular, 96 recordings of individuals with arrhythmia, 30 recordings of individuals with congestive heart failure, and 36 recordings of those with normal sinus rhythms. The objective is to train a classifier to differentiate among ARR, CHF, and NSR.
****GoogleNet****, a deep CNN, was first created to categorize photos into 1000 different categories. In order to classify ECG signals using images from the CWT of the time series data, we reuse the CNN's network design.

# Cardiac Arrhythmias
![gitplot1](https://user-images.githubusercontent.com/96732467/183500719-383342f5-38e3-4ad5-bbfe-e0b96e9785fb.png)
![gitplot2](https://user-images.githubusercontent.com/96732467/183500766-3800a86c-230d-47fa-b498-97bb101f7ba2.png)
![gitplot3](https://user-images.githubusercontent.com/96732467/183500794-7afa7fcb-a5ad-4e9e-8da2-e7324eb541d8.png)

# Training Plot

![training](https://user-images.githubusercontent.com/96732467/183500948-011f1de4-7cee-4db9-857f-c9b3c4906bda.png)
