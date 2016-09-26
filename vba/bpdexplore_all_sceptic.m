%Wrapper for processing all explore clock subjects with out SCEPTIC model


%Set up main data directory
data_dirs = glob('bpdsubjects\*');

%Set up variables
nbasis = 16;
multinomial = 1;
multisession = 0;
fixed_params_across_runs = 1;
fit_propspread = 0;
n_steps = 50;

u_aversion = 1; % allow for uncertainty aversion in UV_sum
saveresults = 0; %don't save to prevent script from freezing on Thorndike

graphics = 0; %If we want to plot or not

%Which models to use
%modelnames = {'fixed' 'fixed_uv' 'fixed_decay' 'kalman_softmax' 'kalman_processnoise' 'kalman_uv_sum' 'kalman_sigmavolatility' 'kalman_logistic'};
modelnames = {'fixed_decay'};

for m=1:length(modelnames)
    model = char(modelnames(m));
    for i = 1:length(data_dirs)
        subj_dir = data_dirs{i};

        id = str2double(subj_dir(isstrprop(subj_dir,'digit')));
        
        
        %If subject is not processed yet
        foldername = ['bpdsubjects/' mat2str(id)];
        file_path = sprintf('bpdsubjects/%d/fMRIEmoClock_%d_1_tc_tcExport.csv',id,id);
        if ~exist(file_path, 'file')
            fprintf('\nSubject not processed...\n')
            %Convert the .mat file to a .csv
            ClockToCSV(sprintf('bpdsubjects/%d/fMRIEmoClock_%d_1_tc.mat',id,id))
        end
        
        subj_file = glob([subj_dir '\*.csv']);
        subj_file = subj_file{:};
        [posterior,out] = explore_clock_sceptic_vba(subj_file,id,model,nbasis, multinomial, multisession, fixed_params_across_runs, fit_propspread,n_steps,u_aversion,saveresults,graphics);
        L(m,i) = out.F;
        bpdmakeClockRegressor(id,out)
    end
end