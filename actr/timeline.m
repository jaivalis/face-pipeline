mother = [247,384, 1045, 1070, 471, 596, 188, 216, 658, 985, 1321, 1532, 1121, 1136, 1244, 1313, 37, 100];
fiance = [385, 460, 899, 930, 516, 554, 597, 655, 986, 1044, 1121, 1169, 1238, 1313, 143, 187, 217, 246];
alan =   [151, 187, 217, 246, 385, 400, 899, 930];
charlie = [1, 17, 195, 216, 104, 128, 461, 515, 555, 596, 247, 384, 659, 898, 1071, 1120, 1170, 1237, 931, 985, 1314, 1394, 1395, 1409, 1417, 1507, 1521, 1532];
other = [944, 973];

mother = sort(mother);
fiance = sort(fiance);
alan = sort(alan);
charlie = sort(charlie);

index = 2;
for i = 1 : length(charlie)
    if i == 1
        dataalan(1) = alan(i);
        datafiance(1) = fiance(i);
        dataother(1) = other(i);
        datamother(1) = mother(i);
        datacharlie(1) = charlie(i);
    else
        if i < length(alan)
            dataalan(index) = alan(i+1)-alan(i);
        else
            dataalan(index) = 0;
        end
        
        if i < length(fiance)            
            datafiance(index) = fiance(i+1)-fiance(i);
        else
            datafiance(index) = 0;
        end
        
        if i < length(mother)
            datamother(index) = mother(i+1)-mother(i);
        else
            datamother(index) = 0;
        end
        
        if i < length(other)
            dataother(index) = other(i+1)-other(i);
        else
            dataother(index) = 0;
        end
        
        if i < length(charlie)
            datacharlie(index) = charlie(i+1)-charlie(i);
        else
            datacharlie(index) = 0;
        end
    end
    index = index + 1;
end
size_charlie = size(charlie, 2);
dataalan = cat(2, dataalan, zeros(1, size(dataalan,2) - size_charlie));
datamother = cat(2, datamother, zeros(1, size(datamother,2) - size_charlie));
datafiance = cat(2, datafiance, zeros(1, size(datafiance,2) - size_charlie));
dataother = cat(2, dataother, zeros(1, size(dataother,2) - size_charlie));

datacharlie(2:30) = datacharlie(1:29);
datacharlie(1) = 0;

h = barh(cat(1,dataalan,datamother,datafiance,dataother,datacharlie), 'stack');
for i = 1:2:length(datacharlie)
    set(h(i), 'facecolor', 'none', 'EdgeColor', 'none');
end
set(gca, 'YTickLabel', {'Alan','Mother','Fiancé','Other','Charlie'} ); % change the y axis tick to your name of the process
axis ij; % Put the first row at top