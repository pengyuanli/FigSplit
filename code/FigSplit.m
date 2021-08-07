function pointsforseparation=practice(imfilepath)

warning('off','all');
[pathstr,name,ext] = fileparts(imfilepath);
display_flag=0;
        
%%%%%%%%%%% try 
     im_original=imread(imfilepath);
   height=size(im_original,1);
     width=size(im_original,2);
     scalesize=1;
     if height>1000 || width >1000
         scalesize=max((height/800), (width/800));
         im=imresize(im_original, (1/scalesize));
     else
     im=im_original;
    end
        pointsforseparation=[1, 1, size(im,1), size(im,2)];
       
        if ndims(im)==3
            im0=im2double(rgb2gray(im));
        else
            im0=im2double(im);
        end
        
        if  max(im0(:))>200
            im0=im0/255;
        end
        
        im0=imresize(im0,2.0);
        im0=imadjust(im0);
       

% 1) Original CCA

        [t,pointsforseparation]=white_margin_detection(im0, display_flag);

        if size(pointsforseparation,1)<2
            [t,pointsforseparation]=black_margin_detection(im0,display_flag);
        end
        pointsforseparation=evaluation(pointsforseparation,im0);
         pointsforseparation=pointsforseparation/2;
   
         
% 2) Remove the boundary of the image        
if size(pointsforseparation,1)<2
    white_area=(length(find(im0>0.9)))/numel(im0);
    if white_area>0.3
        
        [Gmag,Gdir] = imgradient(im0);
        %%%%%%%   First crop the image
        a=find(max(Gmag, [], 1)>0.05);
        b=find(max(Gmag, [], 2)>0.05);
        im1=im0(b(1)+3:b(length(b))-10,a(1)+3:a(length(a))-10);
        
                
%             im1=im0(10:height-10,10:width-10);
            
            [t,pointsforseparation]=white_margin_detection(im1, display_flag);
            
            if size(pointsforseparation,1)<2
                [t,pointsforseparation]=black_margin_detection(im1,display_flag);
            end
            
            
            for i=1:size(pointsforseparation, 1)
                 pointsforseparation(i,1)=pointsforseparation(i,1)+a(1)+10;
                 pointsforseparation(i,2)=pointsforseparation(i,2)+b(1)+10;
             end
            pointsforseparation=evaluation(pointsforseparation,im1);

            pointsforseparation=pointsforseparation/2;
        end
  end
% 3) Use Susan feature  

        if size(pointsforseparation,1)<2

            white_area=(length(find(im0>0.9)))/numel(im0);
            if white_area>0.3
            
            [Gmag, Gdir] = imgradient(im0);
            
            complexity=entropy(Gmag);
        
            if complexity>=5
                susan_im = susan(im,80);
            else
                susan_im = susan(im,40);
            end
            
            
            susan_im=im2bw(susan_im);
            [height,width]=size(susan_im);
            [Gmag,Gdir] = imgradient(susan_im);
        %%%%%%%   First crop the image
        a=find(max(Gmag, [], 1)>0.05);
        b=find(max(Gmag, [], 2)>0.05);
        im1=susan_im(b(1)+3:b(length(b))-10,a(1)+3:a(length(a))-10);
            im1=1-im1;
            se = strel('line',7,90);% Need to try 7, 5, 3, 9
            se1 = strel('line',7,0);%
            BW2 = imdilate(im1,se);
            BW2 = imdilate(BW2,se1);
            %     BW2=im2bw(BW2);
            BW2=1-BW2;
            
            [t,pointsforseparation]=white_margin_detection(BW2, display_flag);
            
             for i=1:size(pointsforseparation, 1)
                 pointsforseparation(i,1)=pointsforseparation(i,1)+a(1)+10;
                 pointsforseparation(i,2)=pointsforseparation(i,2)+b(1)+10;
             end
            pointsforseparation=evaluation(pointsforseparation,im);
            
%             end
%         end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%find peak method
%         
if size(pointsforseparation,1)<2
    global findpeakspoints;
    findpeakspoints=[];

    t0=get_white_seg_recursion_function(im0);
    
    pointsforseparation=findpeakspoints;
    
    pointsforseparation=evaluation(pointsforseparation,im0);
    

    pointsforseparation=pointsforseparation/2;
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% combine Susan method

if size(pointsforseparation,1)<2

    pointsforseparation=CCAuseSusan1( susan_im);
    pointsforseparation=evaluation(pointsforseparation,im);
 
end
            end
        end

%%%%%%%%%%end

pointsforseparation=pointsforseparation*scalesize;

  mkdir([pathstr, '/', name]);
for i=1:size(pointsforseparation, 1)
    I2 = imcrop(im_original,pointsforseparation(i,:));
    imwrite(I2,[pathstr, '/', name, '/', num2str(i,'%3.3d'),'.jpg']);
end

% end

