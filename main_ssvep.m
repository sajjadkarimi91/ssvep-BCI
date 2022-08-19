close all
clear
clc
addpath(genpath(pwd))

%This code is dependent on eeglab functions, and eeglab must insatll and
%add biosig plugin

dataset_dir = 'D:\PHD codes\DataSets\dataset-ssvep-exoskeleton';
save_dir = [pwd,'/epoched_clean_data'];

num_subjects = 1:12; % participants number
eeg_channels = 1:8; % eeg channel numbers 10/20 system on Oz, O1, O2, POz, PO3, PO4, PO7 and PO8.
max_class = 3; % 

%%  Start load, preprocessing & extracting epochs

eeg_preprocessing;

%% Ready for feature extraction
close all

cca_features;

lasso_features;


%% classification naive-Bayes or SVMs
close all
num_subjects_ML = 1:1;
k_pairs_ML = 3; % it is a member of set k_pairs
max_features = 20;

classfier_type = 'svm'; % nb or svm
poly_order = 4; % 1:4

csp_classifiction_OVR;



