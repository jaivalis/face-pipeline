function count_acting_time(result_dir)

load(fullfile(result_dir, 'facedets.mat'));

track = cat(1, facedets.track);
utrack = unique(track);
actors = length(utrack);

actTime = hist(track, actors);
figure;
bar(actTime);

% TODO: plot actor per frame


end