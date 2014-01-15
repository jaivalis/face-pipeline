result_dir = 'results';

shotpath = fullfile(result_dir,'shots.txt');
shots = read_shots(shotpath);

index = 1;
threshold = 0.2;

for i = 1:length(shots)
    s1 = shots(1, i);
    s2 = shots(2, i);

    % load facedets of this shot
    load(fullfile(result_dir,sprintf('%09d_%09d_facedets.mat', s1, s2)));

    track = cat(1, facedets.track);
    utrack = unique(track);
    num_tracks = length(utrack);
    
    for m = 1 : num_tracks
        min_diff    = intmax('int32');
        faceActor   = track == utrack(m);
        facedets_M  = facedets(faceActor);
        actor_candidate = svm_actor(facedets_M);
        actors_matched = 0;
        
        % for each actor
        for j = 1:index-1
            actr = actors(j);
            diff = actr.get_model_diff(actor_candidate);
            if diff < threshold
                label = 1;
                actors(j) = actors(j).train(actor_candidate, label);
                actors_matched = actors_matched + 1;
            else
                label = 0;
                actors(j) = actors(j).train(actor_candidate, label);
            end
        end
        
        if actors_matched == 0
            actors(index) = actor_candidate;
            index         = index + 1;
        else
            if actors_matched > 1
               'more than 1 actor matched' 
            end
        end
                
    end
    % end of shot
end

actors(1).show_faces();