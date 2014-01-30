% clear all;

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
learning   = 'offline';
comp_type  = '';

result_dir = 'results';

shotpath = fullfile(result_dir,'shots.txt');
shots = read_shots(shotpath);

index      = 1;
d_index    = 1;
count      = 0;
length_all = 0;


for i = 1:length(shots)
    s1 = shots(1, i);
    s2 = shots(2, i);

    % load facedets of this shot
    facedetfname = sprintf('%09d_%09d_facedets.mat', s1, s2);
    if ~exist(fullfile(result_dir, facedetfname), 'file')
        continue;
    end
    load(fullfile(result_dir, facedetfname));

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
                actor_candidate = sift_actor_conf(facedets_M, i);
            case 'siftactor_average'
                actor_candidate = sift_actor_average(facedets_M);
            otherwise
                fprintf('wrong siftactor type.\n')
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
            % eliminate low confidence actors
            if actor_candidate.pconf_avg < -10
                discarded(d_index) = actor_candidate;
                d_index            = d_index + 1;
            else
                actors(index) = actor_candidate;
                index         = index + 1;
            end
        end
    end
    % end of shot
end

diff_types_params = [ 39, 4;
                      55, 4;
                      35, 7;
                      20, 1;
                       0, 0];
diff_types = [ 'min-min';
               'frontal';
               'average';
               'weights';
               'eyenose'];

for diff_type = 2 :  size(diff_types, 1)

    if strcmp(learning, 'offline')
        num_actors = length(actors);
        for i = 1:num_actors
            diff = get_diff_matrix(actors, diff_types(diff_type, 1:7));
        end
    end




    %% assign
    % if cost is too big, all actors are merged into one
    % if cost is too low, there won't be merges at all
    cost = diff_types_params( diff_type, 1);
    [actor_pairs, unmerged_actors, ~] = assignDetectionsToTracks(diff, cost);
    while size(actor_pairs, 1) ~= 0
        % merge assigned actors-pairs
        clear merged_actors;
        num_merges = 0;
        merged = [];
        index = 1;
        for i = 1:size(actor_pairs, 1)
            if ~ismember(actor_pairs(i, 1), merged) && ~ismember(actor_pairs(i, 2), merged)
                a = actors(actor_pairs(i,2));
                b = actors(actor_pairs(i,1));
                merged_actors(num_merges + 1) = a.merge(b);
                merged(index)                 = actor_pairs(i, 1);
                merged(index + 1)             = actor_pairs(i, 2);
                num_merges        = num_merges + 1;
                index             = index + 2;
            end
        end
        fprintf('# of %s merges: %d\n', diff_types(diff_type, 1:7), num_merges);
        % append unmerged actors to merged actors
    %     for i = 1:length(unmerged_actors)
    %         merged_actors(num_merges + i) = actors(unmerged_actors(i));
    %     end
        ind = 1;
        for i = 1:length(actors)
            if ~ismember(i, merged)
                merged_actors(num_merges + ind) = actors(i);
                ind = ind + 1;
            end
        end
        clear actors;
        actors = merged_actors;
        clear avg_f;
        clear avg_p;
        %% compare actors based on total differences: compare each sift
        % with each sift of other actors
    %     for a = 1:size(actors, 2)
    %         [avg_f(:, a), avg_p(:, a)] = actors(a).get_model_average_diff(actors);
    %     end
    %     'blba';

        %% compute model difference again
        if strcmp(learning, 'offline')
            clear diff;
            num_actors = length(actors);
            diff = get_diff_matrix(actors, diff_types(diff_type, 1:7));
            a =1;
        end

        % call hungarian algorithm for assignment again
        cost = cost - cost / diff_types_params( diff_type , 2); % cost of non-assignment
        [actor_pairs, unmerged_actors, ~] = assignDetectionsToTracks(diff, cost);
        actors = merged_actors;
    end
end
fprintf('done')

%% Annotation
dump_dir = 'dump';
prompt = 'Name: ';
for r = 1:size(actors, 2)
    clf;
    actors(r).show_faces(dump_dir);
    % actors(r).name = input(prompt, 's');
    pause(1.4);
end
%%
% figure;
% for r = 1:size(discarded, 2)
%     clf;
%     discarded(r).show_faces();
%     pause(1.1);
% end

%% Output
for x = 1 : length(actors)
    name = actors(x).name;
    time = actors(x).appearance_time;
    if ismember(names, name)
        
    else
        
    end
end

%%
generate_output( actors, dump_dir, 'results' )