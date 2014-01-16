% choose siftactor type
% siftactor_tpye = 'siftactor';
% threshold = 3.1;
% 
% siftactor_tpye = 'siftactor_conf';
% threshold = 3.6;
% 
siftactor_tpye = 'siftactor_average';
threshold = 85;

% choose learning mode
% learning = 'online';
learning = 'offline';

result_dir = 'results';

shotpath = fullfile(result_dir,'shots.txt');
shots = read_shots(shotpath);

index = 1;
count = 0;
length_all = 0;


for i = 1:length(shots)
    s1 = shots(1, i);
    s2 = shots(2, i);

    % load facedets of this shot
    load(fullfile(result_dir,sprintf('%09d_%09d_facedets.mat', s1, s2)));

    track = cat(1, facedets.track);
    utrack = unique(track);
    num_tracks = length(utrack);
    
    for m = 1 : num_tracks
        min_act     = 0;
        min_diff    = intmax('int32');
        faceActor   = track == utrack(m);
        facedets_M  = facedets(faceActor);
        c = siftactor_tpye;
        switch siftactor_tpye
            case 'siftactor'
                actor_candidate = sift_actor(facedets_M);
            case 'siftactor_conf'
                actor_candidate = sift_actor_conf(facedets_M);
            case 'siftactor_average'
                actor_candidate = sift_actor_average(facedets_M);
            otherwise
                'wrong siftactor type'
        end
        
        % for each actor
        for j = 1:index-1
            actr = actors(j);
            if strcmp(learning, 'online')
                diff = actr.get_model_diff(actor_candidate);
                if diff < threshold
                    if diff < min_diff
                        min_diff = diff;
                        min_act  = j;
                    end
                end
            end
        end
        if min_act ~= 0
            actors(min_act) = actors(min_act).train(actor_candidate);
        else
            actors(index) = actor_candidate;
            index         = index + 1;
        end
    end
    % end of shot
end

if strcmp(learning, 'offline')
    num_actors = length(actors);
    for i = 1:num_actors
        [diff(:, i), act(:, i)] = actors(i).compare_models(actors);
    end
end

% for r = 1:length(actors)
%     clf;
%     actors(r).show_faces();
%     pause(1.1);
% end