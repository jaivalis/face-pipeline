function diff = get_diff_matrix( all_models, diff_type )
	diff = zeros(length(all_models), length(all_models));
	
	for i = 1:length(all_models)
		for j = 1:length(all_models)
            if i == j % penalize comparisson with self
                diff(i, j) = 200;
                continue;
            end
			if diff( j, i ) ~= 0
				diff( i, j ) = diff( j, i );
            else
                a = all_models(i);
                b = all_models(j);
                if strcmp(diff_type, 'min-min');
                    diff( i, j ) = all_models(i).get_min_min_diff( all_models(j) );
                elseif strcmp(diff_type, 'average');
                    diff( i, j ) = all_models(i).get_average_diff( all_models(j) );
                elseif strcmp(diff_type, 'frontal');
                    diff( i, j ) = all_models(i).get_average_diff( all_models(j) );
                elseif strcmp(diff_type, 'eyenose');
                    diff( i, j ) = all_models(i).get_eyes_nose_diff( all_models(j) );
                end
			end
		end
	end
end