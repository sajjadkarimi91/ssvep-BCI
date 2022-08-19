%This code is dependent on eeglab functions, and eeglab must insatll and
%add biosig plugin

times_var = 5;
outlier_percentage = 0.025;

mkdir(save_dir);


for i = num_subjects
    %% EEGLAB functions
    if i<10
        data_path = [dataset_dir,'/subject0',num2str(i),'/'];
        this_name = ['subject0',num2str(i)];
    else
        data_path = [dataset_dir,'/subject',num2str(i),'/'];
        this_name = ['subject',num2str(i)];
    end

    all_record_names = dir([data_path,'*.gdf']);
    all_epoched = [];
    class_labels =[];

    for k=1:size(all_record_names,1)

        EEG = pop_biosig([data_path,all_record_names(k).name]);
        % eegplot(EEG.data, 'srate', EEG.srate);
        clc
        EEG_data = EEG.data;
        srate = EEG.srate;
        fc1 = 11;
        fc2 = 45;
        [~ , EEG_data] = sjk_outlier_clip( EEG_data , outlier_percentage , times_var );

        EEG_data = EEG_data - mean(EEG_data,2);
        EEG_data = sjk_eeg_filter(EEG_data,srate ,fc1,fc2);
        EEG.data = EEG_data;
        %EEG = pop_resample( EEG, 128);

        srate = EEG.srate;

        % [Pxx,F] = pwelch(EEG.data(1,:),'psd',512);
        % plot(64*(0:length(Pxx)-1)/length(Pxx),Pxx)
        % eegplot(EEG.data, 'srate', EEG.srate);
        %% epoches extractions

        %Label_00: 33024, 0x00008100
        % Label_01: 33025, 0x00008101
        % Label_02: 33026, 0x00008102
        % Label_03: 33027, 0x00008103
        %Label_00 is for resting class, Label_01 is for 13Hz stimulation, Label_02 is for 21Hz stimulation and Label_03 is for 17Hz stimulation.

        target_frequencies = [12.989 21.051 17.017 ];

        eeg_temp = pop_epoch( EEG , { '33025'  }, [ -0.5   5.5], 'epochinfo', 'yes');
        all_epoched = cat(3,all_epoched, eeg_temp.data);
        class_labels = [class_labels;ones(size(eeg_temp.data,3),1)];

        eeg_temp = pop_epoch( EEG , { '33026'  }, [ -0.5   5.5], 'epochinfo', 'yes');
        all_epoched = cat(3,all_epoched, eeg_temp.data);
        class_labels = [class_labels;2*ones(size(eeg_temp.data,3),1)];

        eeg_temp = pop_epoch( EEG , { '33027'  }, [ -0.5   5.5], 'epochinfo', 'yes');
        all_epoched = cat(3,all_epoched, eeg_temp.data);
        class_labels = [class_labels;3*ones(size(eeg_temp.data,3),1)];

        eeg_temp = pop_epoch( EEG , { '33024'  }, [ -0.5   5.5], 'epochinfo', 'yes');
        all_epoched = cat(3,all_epoched, eeg_temp.data);
        class_labels = [class_labels;4*ones(size(eeg_temp.data,3),1)];


    end

    save([save_dir,'/',this_name,'.mat'],'class_labels','all_epoched','srate','target_frequencies');

end

