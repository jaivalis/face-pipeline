
vl_feat_path = '/home/jaivalis/libraries/matlab/vlfeat-0.9.14/toolbox/vl_setup';

dump_dir = 'dump';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('face-detection');
addpath('tracking');
addpath('features-speakers');
addpath('compute-kernels');

run(vl_feat_path);

dump_string = fullfile(dump_dir, '%09d.jpg');
model_dir   = 'models';
result_dir  = 'results';

if ~exist(result_dir, 'dir')
    mkdir(result_dir);
end

s1  = 000000001;
s2  = 000001532;

% face_detection(result_dir, model_dir, dump_string, s1, s2);
% fprintf('face_detection complete\n');
% 
% detect_shots(result_dir, dump_string, s1, s2);
% fprintf('detect_shots complete\n');
% 
track_in_shots(result_dir, -0.6, dump_string);
fprintf('track_in_shots complete\n');

tracks_to_facedets(result_dir, model_dir, dump_string, s1, s2);
fprintf('tracks_to_facedets complete\n');

features_and_speakers(result_dir, model_dir, dump_string);
fprintf('features_and_speakers complete\n');

% probably the confusion matrix?
% facedets_kernel(result_dir);
% fprintf('facedets_kernel complete\n');

count_acting_time(result_dir);
fprintf('count_acting_time complete\n');

