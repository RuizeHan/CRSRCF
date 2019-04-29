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
Spatial regularization (SR), being an effective tool to alleviate the boundary effects, can significantly improve the accuracy and robustness of correlation filters (CF) based visual object tracking. The core of SR is a spatially variant weight map that is used to regularize the online learned correlation filters by selecting more meaningful samples. However, most existing trackers apply a data-independent SR weight map. In this paper, we show that a content-related spatial regularization (CRSR) can help to further boost both the tracking accuracy and robustness. Specifically, we present to consider both frame saliency and spatial preference to online generate the CRSR weight map and propose a simple yet effective saliency-embedded CF objective function to simultaneously optimize the filters and CRSR weight map in spatialtemporal domain. Extensive experiments validate that our content-related SR outperforms the classical SR, with higher tracking accuracy and almost two times faster speed.
