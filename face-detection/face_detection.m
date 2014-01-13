function face_detection(result_dir, model_dir, dump_string, s1, s2)

facemodel = load(fullfile(model_dir, 'face_p146_small.mat'));
det_string = fullfile(result_dir, '%09d.mat');

f   = s1:s2;

for i = 1:length(f)
    fprintf('Working on frame %09d\n', f(i));
    detect_face(f(i), dump_string, det_string, facemodel);
end

end