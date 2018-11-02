function results = run_CRSRCF(seq, res_path, bSaveImage, parameters)

% By RuizeHan
% Content-related spatial regularization for visual object tracking, in
% ICME 2018

close all
addpath(genpath('Processing/'));
seq.format = 'otb';
params = SetParams(seq);
[params, data] = PrepareData(params);
time = 0;
for frame = 1:data.seq.num_frames
    data.seq.frame = frame;
    data.seq.im = imread(params.s_frames{data.seq.frame});
    if size(data.seq.im,3) > 1 && data.seq.colorImage == false
        data.seq.im = data.seq.im(:,:,1);
    end

    tic();
    [params, data] = Detection(params, data);
    if rem(frame+params.update-1,params.update) == 0        
        [params, data] = FilterUpdate(params, data);
    end
    time = time + toc;
    Visualization(params.visualization, params.selector, data.seq.frame, data.seq.im, data.obj.pos, data.obj.target_sz);
    
end


fps = numel(params.s_frames) / time;

% disp(['fps: ' num2str(fps)])
results.time.time = time;
results.type = 'rect';
results.res = data.obj.rects; %each row is a rectangle
results.fps = fps;

end