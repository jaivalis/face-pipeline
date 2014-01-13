result_dir = 'results';

shotpath = fullfile(result_dir,'shots.txt');
shots = read_shots(shotpath);

index = 1;
count = 0;

threshold = 84;
for i = 1:length(shots)
    s1 = shots(1, i);
    s2 = shots(2, i);

    % load facedets of this shot
    load(fullfile(result_dir,sprintf('%09d_%09d_facedets.mat', s1, s2)));

    track = cat(1, facedets.track);
    utrack = unique(track);
    num_tracks = length(utrack);
    
    for m = 1 : num_tracks
        faceActor   = track == m;
        facedets_M  = facedets(faceActor);
        actor_candidate = sift_actor(facedets_M);
        for j = 1:index-1
            actr = actors(j);
            diff = actr.get_model_diff(actor_candidate);
            if diff < threshold
                actr.train(actor_candidate);
                count = count + 1;
            end
        end
        if count == 0
            actors(index) = actor_candidate;
            index = index + 1;
        end
    end
end