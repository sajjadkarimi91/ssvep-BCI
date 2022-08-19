



%% for all subjects generate & save CCA features

for i = num_subjects

    disp(['extracting CCA features for subject: #',num2str(i)])

    if i<10
        this_name = ['subject0',num2str(i)];
    else
        this_name = ['subject',num2str(i)];
    end
    load([save_dir,'/',this_name,'.mat']);


    %% Generate stimuli frequency
    clear set_targfreqs
    f = target_frequencies;
    [N,T,TR] = size(all_epoched);

    t_epochs = (0:T-1)/srate;
    for fr = 1:length(target_frequencies)
        for harm = 1:2 % Harmonics + Fundamental
            temp(harm*2-1,:) = sin(2*(harm)*pi*f(fr)*t_epochs);
            temp(harm*2,:)   = cos(2*(harm)*pi*f(fr)*t_epochs);
        end
        set_targfreqs{fr} = temp;
    end


    %% CCA extraction
    clear ssvep_features class 
    for tr = 1: size(all_epoched,3)
        for fr = 1:length(target_frequencies)
            [wx, wy, R] = cca(squeeze(all_epoched(:,:,tr)),set_targfreqs{fr});
            ssvep_features(tr,fr) = max(real(diag(R)));
        end
        [~, class(tr,1)] = max(ssvep_features(tr,:));
    end


    if exist([save_dir,'/cca_features'],"dir")==0
        mkdir([save_dir,'/cca_features'])
    end
    save([save_dir,'/cca_features/cca_sub',num2str(i),'.mat'],'ssvep_features');


end
