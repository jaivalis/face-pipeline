clear all;

% choose siftactor type
% siftactor_tpye = 'siftactor';
% threshold = 3.1;
% 
siftactor_tpye = 'siftactor_conf';
threshold = 3.6;
% 
% siftactor_tpye = 'siftactor_average';
% threshold = 85;

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
        [diff(:, i), ~] = actors(i).compare_models(actors);
    end
end

% diagonal of diff is the own actor, we don't want to assign those to each
% other
diff(logical(eye(size(diff)))) = 200;




%% assign 
cost = 1.5;
[actor_pairs, unmerged_actors, ~] = assignDetectionsToTracks(diff, cost);
while size(actor_pairs, 1) ~= 0
    % merge assigned actors-pairs
    clear merged_actors;
    num_merges = 0;
    merged = [];
    index = 1;
    for i = 1:length(actor_pairs)
        if ~ismember(actor_pairs(i, 1), merged) && ~ismember(actor_pairs(i, 2), merged)
            a = actors(actor_pairs(i,2));
            b = actors(actor_pairs(i,1));
            merged_actors(index) = a.merge(b);
            merged(index) = actor_pairs(i, 1);
            num_merges = num_merges + 1;
            index = index + 1;
        end
    end
    fprintf('# of merges: %d\n', num_merges);
    % append unmerged actors to merged actors
    for i = 1:length(unmerged_actors)
        merged_actors(num_merges + i) = actors(unmerged_actors(i));
    end
    clear actors;
    actors = merged_actors;
    % compute model difference again
    if strcmp(learning, 'offline')
        clear diff;
        num_actors = length(actors);
        for i = 1:num_actors
            [diff(:, i), ~] = actors(i).compare_models(actors);
        end
    end

    % diagonal of diff is the own actor, we don't want to assign those to each
    % other
    diff(logical(eye(size(diff)))) = 200;
    % call hungarian algorithm for assignment again
    % cost = cost - 0.1; % cost of non-assignment
    [actor_pairs, unmerged_actors, ~] = assignDetectionsToTracks(diff, cost);
    actors = merged_actors;
end
fprintf('done')

%%
for r = 1:size(merged_actors, 2)
    clf;
    merged_actors(r).show_faces();
    pause(1.1);
end

%%
for r = 1:size(actors, 2)
    clf;
    actors(r).show_faces();
    pause(0.6);
end