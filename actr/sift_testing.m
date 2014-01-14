result_dir = 'results';

shotpath = fullfile(result_dir,'shots.txt');
shots = read_shots(shotpath);

index = 1;
count = 0;
length_all = 0;

threshold = 84;
for i = 1:length(shots)
    s1 = shots(1, i);
    s2 = shots(2, i);

    % load facedets of this shot
    load(fullfile(result_dir,sprintf('%09d_%09d_facedets.mat', s1, s2)));

    track = cat(1, facedets.track);
    utrack = unique(track);
    num_tracks = length(utrack);
    actors_identified = [];
    actors_identified_ind = 1;
    
    for m = 1 : num_tracks
        min_act     = 0;
        min_diff    = intmax('int32');
        faceActor   = track == utrack(m);
        facedets_M  = facedets(faceActor);
        actor_candidate = sift_actor(facedets_M);
        
        % for each not identified actor
        for j = 1:index-1
            actr = actors(j);
                if ismember(j, actors_identified);
                    continue;
                end
            diff = actr.get_model_diff(actor_candidate);
            if diff < threshold
                if diff < min_diff
                    min_diff = diff;
                    min_act  = j;
                end
            end
        end
        if min_act ~= 0
            actors(min_act) = actors(min_act).train(actor_candidate);
            actors_identified(actors_identified_ind) = min_act;
            actors_identified_ind = actors_identified_ind + 1;
        else
            actors(index) = actor_candidate;
            index         = index + 1;
            actors_identified(actors_identified_ind) = index;
            actors_identified_ind = actors_identified_ind + 1;
        end
    end
    % end of shot
    clearvars actors_identified;
end

actors(1).show_faces();