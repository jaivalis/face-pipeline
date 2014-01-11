function tracks_to_facedets_in_shots( result_dir, model_dir, dump_string )
%TRACKS_TO_FACEDETS_IN_SHOTS Summary of this function goes here
%   Detailed explanation goes here

shotpath = fullfile(result_dir, 'shots.txt');
shots   = read_shots(shotpath);

for i = 1:size(shots, 2)
    s1 = shots(1, i);
    s2 = shots(2, i);

    tracks_to_facedets(result_dir, model_dir, dump_string, s1, s2);
end

