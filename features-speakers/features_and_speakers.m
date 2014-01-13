function features_and_speakers(result_dir, model_dir, dump_string, s1, s2)

facedetfname    = sprintf('%09d_%09d_facedets.mat', s1, s2);

facedets = load(fullfile(result_dir, facedetfname));
load(fullfile(model_dir, 'mean_face.mat'));

facedets = face_features(facedets.facedets, dump_string);
facedets = face_descriptors(facedets, mean_face, 101, dump_string, model_dir);

% we don't need that in our project
% facedets = mouth_motion(facedets, dump_string);
% facedets = declare_speakers(facedets);

save(fullfile(result_dir, facedetfname));

end