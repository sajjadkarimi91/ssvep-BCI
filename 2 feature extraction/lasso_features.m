



%% for all subjects generate & save LASSO features

for i = num_subjects

    disp(['extracting LASSO features for subject: #',num2str(i)])

    if i<10
        this_name = ['subject0',num2str(i)];
    else
        this_name = ['subject',num2str(i)];
    end
    load([save_dir,'/',this_name,'.mat']);
    all_epoched = double(all_epoched);

    %% Generate stimuli frequency
    clear set_targfreqs
    f = target_frequencies;
    [N,T,TR] = size(all_epoched);
    set_targfreqs = [];
    t_epochs = (0:T-1)/srate;
    for fr = 1:length(target_frequencies)
        for harm = 1:2 % Harmonics + Fundamental
            temp(harm*2-1,:) = sin(2*(harm)*pi*f(fr)*t_epochs);
            temp(harm*2,:)   = cos(2*(harm)*pi*f(fr)*t_epochs);
        end
        set_targfreqs = cat(2, set_targfreqs, temp');
    end


    %% lasso frequency extraction

    clear ssvep_features 
    for tr = 1: size(all_epoched,3)
        for ch = 1:size(all_epoched,1)
            y_ch = squeeze(all_epoched(ch,:,tr));
            [B, fit_info] = lasso(set_targfreqs,y_ch, 'CV',10);
            b = B(:,fit_info.IndexMinMSE);
            b = reshape(b,[],2);
            ssvep_features(tr,:) = sum(abs(b),2);
        end
    end


    if exist([save_dir,'/lasso_features'],"dir")==0
        mkdir([save_dir,'/lasso_features'])
    end
    save([save_dir,'/lasso_features/cca_sub',num2str(i),'.mat'],'ssvep_features');


end
