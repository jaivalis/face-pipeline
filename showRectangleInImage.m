imgNum = '014861';
numberOfRects = 5;

img = imread(strcat('dump/',imgNum,'.jpg'));
box = load(strcat('/home/jaivalis/UvA/ProjectAI/face-pipeline-master/results/',imgNum,'.mat'));
box = box.box;

imshow(img);
hold on;

for i = 1: numberOfRects,
    rectangle('Position', [box(i,1) box(i,2) box(i,3)-box(i,1) box(i,4)-box(i,2)]);
end

hold off;