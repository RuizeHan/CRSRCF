# CRSRCF
The source code of CRSRCF (Content-Related Spatial Regularization for Visual Object Tracking, in ICME 2018). 

```
@inproceedings{han2018content,
  title={Content-related spatial regularization for visual object tracking},
  author={Han, Ruize and Guo, Qing and Feng, Wei},
  year={2018},
  organization={ICME}
}
```

## Abstract

In this paper, we show that a content-related spatial regularization (CRSR) can help to further boost both the tracking accuracy and robustness.  

Specifically, we present to consider both frame saliency and spatial preference to online generate the CRSR weight map and propose a simple yet effective saliency-embedded CF objective function to simultaneously optimize the filters and CRSR weight map in spatialtemporal domain.  

Extensive experiments validate that our content-related SR outperforms the classical SR, with higher tracking accuracy and almost two times faster speed.

We show the framework of the proposed method as follows:

![Framework](https://github.com/HanRuize/CRSRCF/blob/master/figs/crsr_fig2.png)

## Results

We evaluate the performance of CRSRCF on OTB-2015:  
  
  
![Tracking_results-OTB15](https://github.com/HanRuize/CRSRCF/blob/master/figs/crsr_otb2015.png)


