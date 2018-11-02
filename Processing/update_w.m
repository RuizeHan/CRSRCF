function [params,data,filter]=update_w(params,data,filter)

    lamda2 = params.lamda2;
    lamda1 = params.lamda1;
    dfs_matrix = data.setup.dfs_matrix;
    feature_dim = data.setup.feature_dim;  
    im = data.seq.im;
    sz_0=size(im);  
    get_scal = params.sal_reg;
  
    %get the saliency detection region
    xs = floor(data.obj.pos(2)) + (1:get_scal*data.obj.target_sz(2)) - floor(get_scal*data.obj.target_sz(2)/2);
    ys = floor(data.obj.pos(1)) + (1:get_scal*data.obj.target_sz(1)) - floor(get_scal*data.obj.target_sz(1)/2);
    xs(xs < 1) = 1;
    ys(ys < 1) = 1;
    xs(xs > size(im,2)) = size(im,2);
    ys(ys > size(im,1)) = size(im,1);
    
    %crop the saliency detection region from the frame
    srcImg = get_pixels(im,data.obj.pos,round(get_scal*data.obj.target_sz),get_scal*data.obj.target_sz); 
    
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
        clear I3;
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
    tar_xs(tar_xs < 1) = 1;
    tar_ys(tar_ys < 1) = 1;
    tar_xs(tar_xs > size(im,2)) = size(im,2);
    tar_ys(tar_ys > size(im,1)) = size(im,1);
   
    mask_0=zeros(sz_0(1),sz_0(2));     
    mask_0(tar_ys,tar_xs)=double(target_slcimg(:,:));    
    maskpixels = double(get_pixels2(mask_0,data.obj.pos,round(data.obj.sz*data.obj.currentScaleFactor),data.obj.sz)); 
   
    
    W0=filter.reg_window_SR;
    
    %get the saliency guidance map
    saliency=imresize(maskpixels,size(filter.reg_window_SR)); 
    saliency_2=saliency.^2;
    
    %get the filter guidance map
    filter_d=real(ifft2(filter.hf));  
    filter_d2=filter_d.^2;
    filter_sum=sum(filter_d2,3); 
    filter_norm=normalizing(filter_sum,0,1); % filter_norm+ lamda1 * saliency_2
    
    % update the weight map using saliency guidance map and filter guidance map
    NewW = lamda2 * W0./(lamda2 + (filter_norm + lamda1 * saliency_2));    
    reg_window = NewW;    
    reg_window((reg_window(:)<0.07))=0.07;

    % compute the DFT and enforce sparsity
    reg_window_dft = fft2(reg_window) / prod(data.obj.use_sz);
    reg_window_dft_sep = cat(3, real(reg_window_dft), imag(reg_window_dft));
    reg_window_dft_sep(abs(reg_window_dft_sep) < params.reg_sparsity_threshold * max(abs(reg_window_dft_sep(:)))) = 0;
    reg_window_dft = reg_window_dft_sep(:,:,1) + 1i*reg_window_dft_sep(:,:,2);
    
    % do the inverse transform, correct window minimum
    reg_window_sparse = real(ifft2(reg_window_dft));
    reg_window_dft(1,1) = reg_window_dft(1,1) - data.obj.support_sz * min(reg_window_sparse(:)) + params.reg_window_min;
    
    % construct the regularizsation matrix
    regW = cconvmtx2(reg_window_dft);
    
    regW_dfs = real(dfs_matrix * regW * dfs_matrix');
    
    WW_block = regW_dfs' * regW_dfs;
    
    % If the filter size is small enough, remove small values in WW_block.
    % It takes too long time otherwise.
    if data.obj.support_sz <= 120^2
        WW_block(0<abs(WW_block) & abs(WW_block)<0.00001) = 0;
    end

    % create block diagonal regularization matrix
    WW = eval(['blkdiag(WW_block' repmat(',WW_block', 1, feature_dim-1) ');']);

    % upper and lower triangular parts of the regularization matrix
    filter.WW_U = triu(WW, 1); 
    
end