



for i = num_subjects_ML
    clc
    i
    if strcmp(type_features,'cca')
        load([save_dir,'/cca_features/sub',num2str(i),'.mat']);
    elseif strcmp(type_features,'lasso')
        load([save_dir,'/lasso_features/sub',num2str(i),'.mat']);
    else
        A = load([save_dir,'/cca_features/sub',num2str(i),'.mat']);
        load([save_dir,'/lasso_features/sub',num2str(i),'.mat']);
        ssvep_features = [ssvep_features,A.ssvep_features];
    end

    ssvep_features = ssvep_features';

    ind_classification = class_labels<=max_class;
    ssvep_features = ssvep_features(:,ind_classification);
    class_labels = class_labels(ind_classification);

    predicted_labels=[];
    true_labels=[];

    %10-fold Cross validation
    CVO = cvpartition(class_labels,'k',10);
    for CrossVal = 1:CVO.NumTestSets

        trIdx = CVO.training(CrossVal);
        teIdx = CVO.test(CrossVal);

        train_features = ssvep_features(:,trIdx);
        test_features  = ssvep_features(:,teIdx);
        train_label = class_labels(trIdx);
        %             TestData = FinalFeatures(k).x(:,teIdx);
        test_label = class_labels(teIdx);

        if strcmp(classfier_type,'nb')
            trained_models = fitcnb(train_features', train_label,'Distribution','kernel');
        else
             template = templateSVM('KernelFunction', 'linear', ...
                'PolynomialOrder', [], 'KernelScale', [], ...
                'BoxConstraint', 0.3, 'Standardize', true);
             trained_models = fitcecoc(train_features', train_label, ...
            'Learners', template, ...
            'Coding', 'onevsone');
        end

        [temp_labels,post_prob] = predict(trained_models, test_features') ;
  
        predicted_labels = [predicted_labels;temp_labels];

        true_labels = [true_labels;test_label(:)];

    end

    [kap,se,H,z,p0,SA,R]=kappa(predicted_labels(:),true_labels(:));
    accuracy(i,1)= sum(diag(H))/sum(H(:));
    conf_matrix(i).H = H./sum(H);


end



figure
plot(accuracy,'o-','linewidth',2)
%xlim([0,max(time_plot)])
ylim([0,1])
grid on
ylabel('ACC')
xlabel('subjects')


disp(['average accuracy: ', num2str(mean(accuracy))])

