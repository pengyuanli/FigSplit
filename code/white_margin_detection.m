% % % display_flag=1
function [figure_num, separationpoints]=white_margin_detection(im0, display_flag)

im0=1-im0;
[height,width]=size(im0);
white_area=(length(find(im0<=0.05)))/numel(im0);

panel_sep_area_size=min(size(im0)/32);%18/2;%15;
min_panel_size_ratio=0.1;

bw=im0>0.04;

bw = imfill(bw,'holes');
h = fspecial('gaussian', 5, 5);
%     bw = imfilter(bw,h,'replicate');
%     figure
%     imshow([bw,bw0])

% bw = bwareaopen(bw,round(numel(im)/200));
n1=round(panel_sep_area_size*white_area);
dilate_size=7;


% im3=imdilate(bw,ones(2,2));
im3=bw;


%     figure
%     imshow([im3,bw])

conn=4;
findgap90=[];
findgap0=[];
%         cc = bwconncomp(im3,conn);
%         rp = regionprops(cc,'BoundingBox','Centroid','Area');
%         hist0degree=[];
%         hist0degree=[];
%
if white_area>0.5
    
    %         if cc.NumObjects>300 && cc.NumObjects<600
    hist0degree=[];
    hist90degree=[];
    for i=1:width
        hist0degree(i)=max(im3(:,i));
    end
    for i=1:height
        hist90degree(i)=max(im3(i,:));
    end
    findgap0=find(hist0degree==1);
    findgap90=find(hist90degree==1);
    if length(findgap0)>2
        for i=1:length(findgap0)-1
            findgap0(i)=findgap0(i+1)-findgap0(i);
            if findgap0(i)<2
                findgap0(i)=10000;
            end
        end
        
        findgap0(length(findgap0))=10000;
        findgap0min=min(findgap0);
    else
        findgap0min=1;
    end
    
    if length(findgap90)>2
        for i=1:length(findgap90)-1
            findgap90(i)=findgap90(i+1)-findgap90(i);
            if findgap90(i)<2
                findgap90(i)=10000;
            end
        end
        
        findgap90(length(findgap90))=10000;
        findgap90min=min(findgap90);
    else
        findgap90min=1;
    end
    
    if findgap0min==10000
        findgap0min=1;
    end
    if findgap90min==10000
        findgap90min=1;
    end
    mingap=floor(max(findgap0min,findgap90min)+1);
    
    if mingap/findgap90min>2 || mingap/findgap0min>2
        mingap=floor(min(findgap0min,findgap90min)+1);
    end
    
    if mingap<5
        mingap=1;
    end
    
    dilate_size=mingap;
    if dilate_size>10000
        dilate_size=1;
    end
    while dilate_size>min(height,width)/50
        dilate_size= floor(dilate_size/2);
    end
    %im3=imdilate(bw,ones(dilate_size,dilate_size));
    im3=imdilate(bw,ones(20,20));
end


cc = bwconncomp(im3,conn);
rp = regionprops(cc,'BoundingBox','Centroid','Area');
%         end

noise=cat(1,rp.Area);
noisenum=sum(noise>5);

if cc.NumObjects>600
    
    findgap90min=max(findgap90(findgap90<100));
    if length(findgap90min)<1
        findgap90min=3;
    end
    findgap0min=max(findgap0(findgap0<100));
    if length(findgap0min)<1
        findgap0min=3;
    end
    
    dilate_size=min(findgap0min,findgap90min);
    while dilate_size>min(height,width)/30
        dilate_size=ceil(dilate_size/2);
    end
    im3=imdilate(bw,ones(dilate_size,dilate_size));
   
    cc = bwconncomp(im3,conn);
    rp = regionprops(cc,'BoundingBox','Centroid','Area');
    %         end
    
    noise=cat(1,rp.Area);
    noisenum=sum(noise>5);
    if cc.NumObjects>600
        rp=[];
        %     dilate_size=10;
        %     im3=imdilate(bw,ones(dilate_size,dilate_size));
        %     cc = bwconncomp(im3,conn);
        %     rp = regionprops(cc,'BoundingBox','Centroid','Area');
    end
end




if isempty(rp)
    % a_matrix=[a_matrix,1];
    figure_num=1;
    separationpoints=[1,1,width,height];
    return; %continue;
    
end

max_area=max(cat(1,rp.Area));
min_panel_size_ratio=0.05;
max_panel_size_ratio_lim=0.5;
%     figure
%     imshow(im,[]);
%     hold on;


t=0;
separationpoints=[];
for j=1:cc.NumObjects
    if rp(j).BoundingBox(3)*rp(j).BoundingBox(4)>height*width/100 %&& max_area*min_panel_size_ratio  %&& rp(j).BoundingBox(3)*rp(j).BoundingBox(4)<(height*width*0.8) && rp(j).Area>min_panel_size_ratio*max_area%&& max_area>max_panel_size_ratio_lim* size(im3,1)*size(im3,2)
        
        t=t+1;
        separationpoints=[separationpoints;rp(j).BoundingBox];
        if display_flag==1
            %           t=t+1;
            rectangle('Position',rp(j).BoundingBox,'EdgeColor','b','LineWidth',5);
        end
        %             pause
    end
end


if size(separationpoints,1)<2
    separationpoints=[1,1,width,height];
end

figure_num=size(separationpoints,1);