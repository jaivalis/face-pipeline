function [ begin_frame, end_frame, id ] = get_longest_track( result_dir  )
%GET_LONGEST_TRACK Summary of this function goes here
%   
shotpath = fullfile(result_dir,'shots.txt');
shots = read_shots(shotpath);

max_        = 0;
begin_frame = 0;
end_frame   = 0;
id          = 0;
scene_end   = 0;

for i = 1:size(shots, 2)
    s1 = shots(1, i);
    s2 = shots(2, i);
    
    % load facedets of this shot
    load(fullfile(result_dir,sprintf('%09d_%09d_facedets.mat', s1, s2)));

    for k = 1:length(facedets)

        if facedets(k).frame == s1
            scene_begin = k;
        end
        if facedets(k).frame == s2
            scene_end   = k;
        end

        track = cat(1, facedets(scene_begin:scene_end).track);
        utrack = unique(track);
        num_actors = length(utrack);

        for j = 1:num_actors
            faceActor   = track == j;
            facedets_J  = facedets(faceActor);
            length_J    = length(facedets_J);
            
            if length_J > max_
                max_        = length_J;
                id          = j;
                begin_frame = s1;
                end_frame   = s2;
            end
        end
    end
end

end