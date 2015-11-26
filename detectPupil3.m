function  detectIris()
%detectIris detect iris with Hough transform
%   goes through all pics in folder with test_num number
%   goes through all radius from 20-60 to 350-390
%   computes centers and retains them with metrics associated
%   gets the circle with the max metric (from all radius)
%   prints picture with associated max circle in 'results' folder
test_num = '7';
names_list = dir(['./test' test_num]);

for i = 1:size(names_list,1)
    %     orig_file_name = 'C10_S2_I2.tiff';
    
    orig_file_name = names_list(i).name;
    if (orig_file_name(1) == '.' || names_list(i).isdir())
        continue;
    end
    figure('units','normalized','position',[0 0 1 1]);
    I = imread(['./test' test_num '/' orig_file_name]);
    
    %invert
    I = imcomplement(I);
    
    %grayscale
    I = rgb2gray(im2double(I));
    
    %binerize
    I = im2bw(I, .90);
    
    %fill holes
    I = imfill(I,'holes');
    imshow(imread(['./test' test_num '/' orig_file_name])), hold on;
    
    s = regionprops(I, 'Perimeter', 'MajorAxisLength', ...
        'MinorAxisLength', 'EquivDiameter', 'Centroid', 'Area');
    eps = 10;
    eps2 = 150;
    for j=1:length(s)
        centers = s(j).Centroid;
        radius = s(j).EquivDiameter/2;
        if (s(j).Area >= eps2 && (abs(s(j).MajorAxisLength - s(j).MinorAxisLength) <= eps))
            viscircles(centers,radius);
        end
    end
%     segmented_image=getframe(gca);
%     imwrite(segmented_image.cdata, ['./results' '10' '/' orig_file_name(1:(size(orig_file_name,2)-5)) '_pupil.png']);
%     close all;
end



