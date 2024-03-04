%% General information for each dataset:
% Specify the path to EyeHex-toolbox/data folder
DATA_FOLDER = 'C:\Users\bvhutr\OneDrive - TUNI.fi\backup\from France\EyeHex_toolbox\EyeHex_toolbox\EyeHex-toolbox-DATA\EyeHex-toolbox-main\data_Brightfield_hik01';
% Size of x,y,z pixel resolution in micron:
dxy = 100/200;
dz = 8;
%% Load csv files:
file_list = dir(fullfile(DATA_FOLDER,'output_csv/*.csv'));
file_valid = zeros(1,numel(file_list));
ommatidia_count = zeros(1,numel(file_list));
for i=1:numel(file_list)
    [~,img_name,] = fileparts(file_list(i).name);
    % Check if image is analyzed
    if exist(fullfile(DATA_FOLDER,'raw',[img_name '.tif']),'file')
        % Open the csv file with readable (5 columns format)
        csv_to_mat = dlmread(fullfile(DATA_FOLDER,'output_csv',[img_name '.csv']),'\t',1,0);
        if size(csv_to_mat,2)==5
            file_valid(i)=1;
            ommatidia_count(i)=size(csv_to_mat,1);
        end
    end
end
file_list = file_list(file_valid>0);
ommatidia_count = ommatidia_count(file_valid>0);
%% Display summary results:
clc
disp('ANALYSYS RESULTS');
display(['Number of compound eye analyzed: ' num2str(numel(ommatidia_count))]);
for i=1:numel(ommatidia_count)
    [~,img_name,] = fileparts(file_list(i).name);
    disp(['    Eye #' num2str(i) ' (' num2str(ommatidia_count(i)) ' omtd): ' img_name '.tif']);
end
display(['Mean of ommatidia number per eye: ' num2str(mean(ommatidia_count))]);
display(['Standard deviation of ommatidia number per eye: ' num2str(sqrt(var(ommatidia_count)))]);

%% Analyze the specific eye:
imgidx = input('Enter the index of the eye you want to analyze further (Applicable only to multi-focused images): ');
[~,img_name,] = fileparts(file_list(imgidx).name);
analyze_per_eye(img_name,DATA_FOLDER,dxy,dz);