function panels= findpanels_v2(img, xlocation, ylocation,b_width, p_width, p_height,area_limit,im_threshold)
% img: input image
% b_width: minimum panel boundary thickness
% p_width: minimum panel width
% p_height: minimum panel height
if 0
   img=rgb2gray(im);
   b_width=10;
   p_width=10;
   p_height=10;

end
 

ep = [b_width,b_width];
[m,n] = size(img);

% ratio_sub=0.1;
% p_width=round(ratio_sub*m);
% p_height=round(ratio_sub*n);

% figure
% imshow(img,[]);
% figure
% plot(1:length(hp), hp,'.-');
% plot(1:length(vp), vp,'.-');

hp = min(img,[],1);
vp = min(img,[],2);

hl = [];
vl = [];
if p_width < n-1 && p_height < m-1
%    [hl, hw] = findpeaks(hp,'MinPeakDistance',p_width, 'MinPeakHeight',235);%, 'MinPeakProminence', 200);
%    [vl, vw] = findpeaks(vp,'MinPeakDistance',p_height, 'MinPeakHeight',235);%, 'MinPeakProminence', 200);
     [~,hl, hw,~] = findpeaks_one(hp,im_threshold,p_width,50);
     [~, vl, vw,~] = findpeaks_one(vp,im_threshold,p_height,50);
%    [pks1, hl, hw] = findpeaks_one(hp,'MinPeakDistance',p_width, 'MinPeakHeight',235, 'MinPeakProminence', 200);
%    [~, vl, vw,~] =  findpeaks_one(vp,'MinPeakDistance',p_height, 'MinPeakHeight',235, 'MinPeakProminence', 50);
%    [pks,locs,w,p]
end


if ~isempty(hl)
    hw=round(hw)+1;

    hl(hw<ep(2))=[];
    if ~isempty(hl)
%         hl = hl + round(hw/2);
%         dhl = [hl n] - [1 hl];
%         ii = find(dhl<p_width);
%         hl(ii+1)=[];
        hrng{1}=1:hl(1);
%         if length(hl)==1
%             continue;
%         end
%         disp('hah')
        for i=2:length(hl)
            hrng{end+1} = hl(i-1)+1:hl(i);
        end
        hrng{end+1} =  hl(end)+1:n;
    else
        hrng{1} = 1:n;
    end
else
    hrng{1} = 1:n;
end


if ~isempty(vl)
    vl(vw<ep(1)) = [];
    if ~isempty(vl)
%       vl = vl + round(vw/2);
        vrng{1}=1:vl(1);
        for i=2:length(vl)
            vrng{end+1} = vl(i-1)+1:vl(i);
        end
        vrng{end+1} = vl(end)+1:m;
    else
        vrng{1} = 1:m;
    end
else
    vrng{1} = 1:m;
end

global findpeakspoints;
panels = [];

if size(hrng,2) == 1 && size(vrng,2) == 1
    panels{1} = img;
    addflag=1;
    for i=1:size(findpeakspoints,1)
        if sum(findpeakspoints(i,:)==[xlocation,ylocation,n,m])==4
            addflag=0;
        end
    end
    if addflag==1
        findpeakspoints=[findpeakspoints;xlocation,ylocation,n,m];
    end
else
    for i = 1:size(hrng,2)
        for j = 1:size(vrng,2)            
            im_sub=img(vrng{j},hrng{i});%area_limit
            (sum(im_sub(:)<im_threshold));
            if size(im_sub,1)*size(im_sub,2)<area_limit || (sum(im_sub(:)<im_threshold))/length(im_sub(:))<0.01
                continue;
            end
            tpnls= findpanels_v2(im_sub,xlocation+hrng{i}(1), ylocation+vrng{j}(1), b_width, p_width, p_height,area_limit,im_threshold);
            for k = 1:size(tpnls,2)
                panels{end+1} = tpnls{k};
                
            end            
        end
    end
end
end