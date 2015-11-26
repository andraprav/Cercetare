function  detectIris()
%detectIris detect iris with Hough transform
%   goes through all pics in folder with test_num number
%   goes through all radius from 20-60 to 350-390
%   computes centers and retains them with metrics associated
%   gets the circle with the max metric (from all radius)
%   prints picture with associated max circle in 'results' folder
test_num = '6';
names_list = dir(['./test' test_num]);
for i = 1:size(names_list,1)
%     orig_file_name = 'C10_S2_I2.tiff';
    orig_file_name = names_list(i).name;
    if (orig_file_name(1) == '.')
        continue;
    end
    I = imread(['./test' test_num '/' orig_file_name]);
    
    %I = imread(orig_file_name);
    
    %I = imadjust(rgb2gray(im2double(I)),[0 0.4], [0 0.8]); detects pupil
    %in light eyes
    
    %I = imadjust(rgb2gray(im2double(I)),[0 0.4], [0.1 0.8]);
    I = imadjust(rgb2gray(im2double(I)),[0 0.6], [0.2 1]);
    %I = adapthisteq(rgb2gray(im2double(I)));
    %I = histeq(rgb2gray(im2double(I)));
    imshow(I);
    Rmin = 20;
    Rmax = 60;
    %I = im2bw( I, .4 );
    
    centers = [];
    radii = [];
    metric = [];
    while (Rmin <= 350)
        %[centers, radii, metric] = imfindcircles(BW, [Rmin Rmax]);
        %stats = [regionprops(BW); regionprops(not(BW))];
        [centersDark, radiiDark, metricDark] = imfindcircles(I, [Rmin Rmax], 'ObjectPolarity','dark','sensitivity', .93, ...
            'EdgeThreshold', .06);
        Rmin = Rmin + 40;
        Rmax = Rmax + 40;
        if (size(centersDark,1) > 0)
            centers = [centers ; centersDark(1,:)];
            radii = [radii ; radiiDark(1,:)];
            metric = [metric ; metricDark(1,:)];
        end
        
    end
    [maxim idx] = max(metric);
    viscircles(centers(idx,:), radii(idx,:),'EdgeColor','r');
    segmented_image=getframe(gca);
    imwrite(segmented_image.cdata, ['./results' '9' '/' orig_file_name(1:(size(orig_file_name,2)-5)) '_segment.png']);
    close all;
end



