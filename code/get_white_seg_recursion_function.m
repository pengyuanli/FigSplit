
function num0=get_white_seg_recursion_function(im)


w_im=size(im,1);
h_im=size(im,2);
area_im=w_im*h_im;

if max(im(:))<10
   im=255*im;
end

b_width=5;
p_width=50;
p_height=50;
%img=img(30:end-30,1:end-30);
% tic
area_limit=area_im*0.08;
im_threshold=0.5*max(im(:));
global findpeakspoints;

panels = findpanels_v2(im, 0, 0, b_width, p_width, p_height,area_limit,im_threshold);

num0=length(panels);

% for pp=1:num0
%     figure
%     imshow(panels{pp},[]);
% end

if num0==2
    [w1,h1]=size(panels{1});
    [w2,h2]=size(panels{2});
    
    area1=prod(size(panels{1}));
    area2=prod(size(panels{2}));
   if(max([area1,area2])/min([area1,area2]))>3
      num0=1;
      findpeakspoints=[1,1,h_im,w_im];
   end
%    if max([w1/w2,w2/w1])>0.8 & max([h1/h2,h2/h1])>0.8
%       num0=2;
%    end
   
end