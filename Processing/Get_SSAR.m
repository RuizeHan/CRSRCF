function  reg_window = Get_SSAR(reg_window, params, data)
%**************************************   saliency   ****************S***********************

    srcImg0 = data.seq.im;
    sz_0=size(srcImg0);
    get_scal = params.sal_reg;
    
    %get the saliency detection region
    xs = floor(data.obj.pos(2)) + floor(1:get_scal*data.obj.target_sz(2)) - floor(get_scal*data.obj.target_sz(2)/2);
    ys = floor(data.obj.pos(1)) + floor(1:get_scal*data.obj.target_sz(1)) - floor(get_scal*data.obj.target_sz(1)/2);        
    xs(xs < 1) = 1;
    ys(ys < 1) = 1;
    xs(xs > size(data.seq.im,2)) = size(data.seq.im,2);
    ys(ys > size(data.seq.im,1)) = size(data.seq.im,1);
    
    %crop the saliency detection region from the frame
    srcImg = get_pixels(srcImg0,data.obj.pos,round(get_scal*data.obj.target_sz),get_scal*data.obj.target_sz); 
    
    %resize the subimage if it is too small
    flag_lager=0;
    if min(size(srcImg))<128
        if(data.obj.target_sz(1)<data.obj.target_sz(2))
        srcImg=imresize(srcImg,[128,128*double(get_scal*data.obj.target_sz(2))/double(get_scal*data.obj.target_sz(1))]);
        elseif(data.obj.target_sz(1)>data.obj.target_sz(2))
        srcImg=imresize(srcImg,[128*double(get_scal*data.obj.target_sz(1))/double(get_scal*data.obj.target_sz(2)),128]);
        end
        flag_lager=1;
    end

    img_channels=ndims(srcImg);  
    if img_channels==2
    I =srcImg(:,:);
    I3(:,:,1)=I;
    I3(:,:,2)=I;
    I3(:,:,3)=I;   
    srcImg=I3;
    end
           
    %implement the saliency detection method on the subimage
    saliency_img=get_saliency_SCA(srcImg,200);
    
    if flag_lager ==1
        saliency_img=imresize(saliency_img,floor(get_scal*data.obj.target_sz));
    end
   
    % abandon the saliency outside the target region
    mask_0=zeros(sz_0(1),sz_0(2));        
    mask_0(ys,xs)=double(saliency_img(:,:)); 
    target_slcimg = double(get_pixels(mask_0,data.obj.pos,round(data.obj.target_sz),data.obj.target_sz)); 
    tar_xs = floor(data.obj.pos(2)) + (1:data.obj.target_sz(2)) - floor(data.obj.target_sz(2)/2);
    tar_ys = floor(data.obj.pos(1)) + (1:data.obj.target_sz(1)) - floor(data.obj.target_sz(1)/2);  
    mask_0=zeros(sz_0(1),sz_0(2)); 
    mask_0(tar_ys,tar_xs)=double(target_slcimg(:,:));    
   
    maskpixels = double(get_pixels(mask_0,data.obj.pos,round(data.obj.sz*data.obj.currentScaleFactor),data.obj.sz)); 
    
    % Reverse normalization of the saliency map   
    maskpixels((maskpixels(:)<0))=0;
    mu = params.mu;
    maskpixels= 1./(1 + mu*maskpixels);
    
%   maskpixels((maskpixels(:)<0))=0;
%   maskpixels=(max(maskpixels(:))-maskpixels)/(max(maskpixels(:))-min(maskpixels(:)));
 
%**************************************   saliency   **************E***********************
    
    % resize the saliency and implement on the weight map
    mask_w=imresize(maskpixels,size(reg_window));
    reg_window= reg_window.*double(mask_w); 
     
end