ForestTools <img src="man/figures/logo.png" align="right" width ="200"/>
======================================================================================================
![license](https://img.shields.io/badge/Licence-GPL--3-blue.svg) 
[![](https://www.r-pkg.org/badges/version/ForestTools)](https://www.r-pkg.org/pkg/ForestTools)
[![R-CMD-check](https://github.com/andrew-plowright/ForestTools/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/andrew-plowright/ForestTools/actions/workflows/R-CMD-check.yaml)
[![](https://cranlogs.r-pkg.org/badges/ForestTools)](https://CRAN.R-project.org/package=ForestTools)

The ForestTools R package offers functions to analyze remote sensing forest data. Please consult the [NEWS.md](NEWS.md) file for updates.

To get started, consult the [canopy analysis tutorial](https://CRAN.R-project.org/package=ForestTools/vignettes/treetop_analysis.html). For a quick guide on generating spatial statistics from ForestTools outputs, consult the [spatial statistics tutorial](https://github.com/andrew-plowright/ForestTools/blob/b737d1af3e557d2b60760a51720eb7ef61174775/guides/spatial_statistics.md)

To cite the package use `citation("ForestTools")` from within R.

```
Andrew Plowright (2023). ForestTools: Tools for Analyzing Remote Sensing Forest Data. R package version 1.0.0,
https://github.com/andrew-plowright/ForestTools.
```


# Features

### Detect and segment trees

Individual trees can be detected and delineated using a combination of the
**variable window filter**  (`vwf`) and **marker-controlled watershed segmentation**
(`mcws`) algorithms, both of which are applied to a rasterized **canopy height model (CHM)**.
CHMs are typically derived from aerial LiDAR or photogrammetric point clouds.

![image info](./man/figures/treetops_segments.png)


### Compute textural metrics

**Grey-level co-occurrence matrices** (GLCMs) and their associated statistics can be computed for individual trees using a single-band
image and a segment raster (which can be produced using `mcws`). These metrics can be used to characterize and classify trees.


# References

This library implements techniques developed in the following studies:

* **Variable window filter**: [Seeing the trees in the forest](https://www.ingentaconnect.com/content/asprs/pers/2004/00000070/00000005/art00003) by Popescu, S. C., & Wynne, R. H. (2004)
* **Marker-controlled watershed segmentation**: [Morphological segmentation](https://www.sciencedirect.com/science/article/pii/104732039090014M) by Meyer, F., & Beucher, S. (1990)
* **Grey-level co-occurrence matrices**: [Robust radiomics feature quantification using semiautomatic volumetric segmentation](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0102107) by Parmar, C., Velazquez, E.R., Leijenaar, R., Jermoumi, M., Carvalho, S., Mak, R.H., Mitra, S., Shankar, B.U., Kikinis, R., Haibe-Kains, B. and Lambin, P. (2014)


# Research

The following is a non-exhaustive list of research papers that use the ForestTools library. Several of these studies discuss topics such as algorithm parameterization, and may be informative for users of this library.

### 2023

* [A novel post-fire method to estimate individual tree crown scorch height and volume using simple RPAS-derived data](https://fireecology.springeropen.com/articles/10.1186/s42408-023-00174-7) by Arkin, J., Coops, N. C., Daniels, L. D., & Plowright, A. (2023)

* [Modelling internal tree attributes for breeding applications in Douglas-fir progeny trials using RPAS-ALS](https://www.sciencedirect.com/science/article/pii/S2666017222000347) by du Toit, F., Coops, N. C., Ratcliffe, B., El-Kassaby, Y. A., & Lucieer, A. (2023)

* [Mountain Tree Species Mapping Using Sentinel-2, PlanetScope, and Airborne HySpex Hyperspectral Imagery](https://www.mdpi.com/2072-4292/15/3/844) by Kluczek, M., Zagajewski, B., & Zwijacz-Kozica, T. (2023)

* [Use of Drone RGB Imagery to Quantify Indicator Variables of Tropical-Forest-Ecosystem Degradation and Restoration](https://www.mdpi.com/1999-4907/14/3/586) by Lee, K., Elliott, S., & Tiansawat, P. (2023)

### 2022

* [Individual Tree Identification in ULS Point Clouds Using a Crown Width Mixed-Effects Model Based on NFI Data](https://www.mdpi.com/2072-4292/14/4/926) by Kubišta, J., & Surový, P. (2022)

* [Utilizing Single Photon Laser Scanning Data for Estimating Individual Tree Attributes](https://helda.helsinki.fi/bitstream/handle/10138/344212/isprs_annals_V_2_2022_431_2022.pdf?sequence=1) by Simula, J., Holopainen, M., & Imangholiloo, M. (2022)

* [UAV-LiDAR and RGB Imagery Reveal Large Intraspecific Variation in Tree-Level Morphometric Traits across Different Pine Species Evaluated in Common Gardens](https://www.mdpi.com/2072-4292/14/22/5904) by Lombardi, E., Rodríguez-Puerta, F., Santini, F., Chambel, M. R., Climent, J., Resco de Dios, V., & Voltas, J. (2022)

* [Cross-Comparison of Individual Tree Detection Methods Using Low and High Pulse Density Airborne Laser Scanning Data](https://www.mdpi.com/2072-4292/14/14/3480) by Sparks, A. M., Corrao, M. V., & Smith, A. M. (2022)

* [Slow development of woodland vegetation and bird communities during 33 years of passive rewilding in open farmland](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0277545) by Broughton, R. K., Bullock, J. M., George, C., Gerard, F., Maziarz, M., Payne, W. E., Scholefield, P. A., Wade, D., & Pywell, R. F. (2022)

* [Application of unmanned aerial system structure from motion point cloud detected tree heights and stem diameters to model missing stem diameters](https://www.sciencedirect.com/science/article/pii/S2215016122001108) by Swayze, N. C., & Tinkham, W. T. (2022)

* [Limited increases in savanna carbon stocks over decades of fire suppression](https://www.nature.com/articles/s41586-022-04438-1) by Zhou, Y., Singh, J., Butnor, J. R., Coetsee, C., Boucher, P. B., Case, M. F., Hockridge, E. G., Davies, A. B., & Staver, A. C. (2022)

* [Automated Inventory of Broadleaf Tree Plantations with UAS Imagery](https://www.mdpi.com/2072-4292/14/8/1931) by Chandrasekaran, A., Shao, G., Fei, S., Miller, Z., & Hupy, J. (2022)

* [Use of Unoccupied Aerial Systems to Characterize Woody Vegetation across Silvopastoral Systems in Ecuador](https://www.mdpi.com/2072-4292/14/14/3386) by Iñamagua-Uyaguari, J. P., Green, D. R., Fitton, N., Sangoluisa, P., Torres, J., & Smith, P. (2022)

* [Democratizing macroecology: Integrating unoccupied aerial systems with the National Ecological Observatory Network](https://esajournals.onlinelibrary.wiley.com/doi/full/10.1002/ecs2.4206) by Koontz, M. J., Scholl, V. M., Spiers, A. I., Cattau, M. E., Adler, J., McGlinchy, J., Goulden, T., Melbourne, B. A., & Balch, J. K. (2022).

* [An Integrated Method for Estimating Forest-Canopy Closure Based on UAV LiDAR Data](https://www.mdpi.com/2072-4292/14/17/4317) by Gao, T., Gao, Z., Sun, B., Qin, P., Li, Y., & Yan, Z. (2022)

* [Detection of standing retention trees in boreal forests with airborne laser scanning point clouds and multispectral imagery](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.13995) by Hardenbol, A. A., Korhonen, L., Kukkonen, M., & Maltamo, M. (2022)

* [Optimizing aerial imagery collection and processing parameters for drone-based individual tree mapping in structurally complex conifer forests](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.13860) by Young, D. J., Koontz, M. J., & Weeks, J. (2022)

* [Assessing Structural Complexity of Individual Scots Pine Trees by Comparing Terrestrial Laser Scanning and Photogrammetric Point Clouds](https://www.mdpi.com/1999-4907/13/8/1305) by Tienaho, N., Yrttimaa, T., Kankare, V., Vastaranta, M., Luoma, V., Honkavaara, E., ... & Saarinen, N. (2022)

* [SiDroForest: a comprehensive forest inventory of Siberian boreal forest investigations including drone-based point clouds, individually labeled trees, synthetically generated tree crowns, and Sentinel-2 labeled image patches](https://essd.copernicus.org/articles/14/4967/2022/) by van Geffen, F., Heim, B., Brieger, F., Geng, R., Shevtsova, I. A., Schulte, L., ... & Kruse, S. (2022)

* [Individual urban trees detection based on point clouds derived from UAV-RGB imagery and local maxima algorithm, a case study of Fateh Garden, Iran](https://link.springer.com/article/10.1007/s10668-022-02820-7) by Azizi, Z., & Miraki, M. (2022)

* [Effect of varied unmanned aerial vehicle laser scanning pulse density on accurately quantifying forest structure](https://www.tandfonline.com/doi/abs/10.1080/01431161.2021.2023229) by Sumnall, M. J., Albaugh, T. J., Carter, D. R., Cook, R. L., Hession, W. C., Campoe, O. C., ... & Thomas, V. A. (2022)

* [Correcting the Results of CHM-Based Individual Tree Detection Algorithms to Improve Their Accuracy and Reliability](https://www.mdpi.com/2072-4292/14/8/1822) by Lisiewicz, M., Kamińska, A., Kraszewski, B., & Stereńczak, K. (2022)

* [Combining aerial photos and LiDAR data to detect canopy cover change in urban forests](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0273487) by Coupland, K., Hamilton, D., & Griess, V. C. (2022)


* [Effects of Flight and Smoothing Parameters on the Detection of Taxus and Olive Trees with UAV-Borne Imagery](https://www.mdpi.com/2504-446X/6/8/197) by Ottoy, S., Tziolas, N., Van Meerbeek, K., Aravidis, I., Tilkin, S., Sismanis, M., Stavrakoudis, D., Gitas, I. Z., Zalidis, G. & De Vocht, A. (2022)


* [Modeling the Missing DBHs: Influence of Model Form on UAV DBH Characterization](https://www.mdpi.com/1999-4907/13/12/2077) by Tinkham, W. T., Swayze, N. C., Hoffman, C. M., Lad, L. E., & Battaglia, M. A. (2022)

* [Mapping Tree Canopy in Urban Environments Using Point Clouds from Airborne Laser Scanning and Street Level Imagery](https://www.mdpi.com/1424-8220/22/9/3269) by Rodríguez-Puerta, F., Barrera, C., García, B., Pérez-Rodríguez, F., & García-Pedrero, A. M. (2022)

* [Extraction of individual trees based on Canopy Height Model to monitor the state of the forest](https://www.sciencedirect.com/science/article/pii/S2666719322000644) by Douss, R., & Farah, I. R. (2022)

* [Aprisco Field Station: the spatial structure of a new experimental site focused on agroecology](https://academic.oup.com/jpe/article/15/6/1118/6576147) by O’Brien, M. J., Carbonell, E. P., & Schöb, C. (2022)

* [UAV-Based Characterization of Tree-Attributes and Multispectral Indices in an Uneven-Aged Mixed Conifer-Broadleaf Forest](https://www.mdpi.com/2072-4292/14/12/2775) by Vivar-Vivar, E. D., Pompa-García, M., Martínez-Rivas, J. A., & Mora-Tembre, L. A. (2022)

### 2021

* [Detectability of the Critically Endangered Araucaria angustifolia Tree Using Worldview-2 Images, Google Earth Engine and UAV-LiDAR](https://www.mdpi.com/2073-445X/10/12/1316) by Saad, F., Biswas, S., Huang, Q., Corte, A. P. D., Coraiola, M., Macey, S., Marcos Bergmann, M., & Leimgruber, P. (2021)

* [Fine scale mapping of fractional tree canopy cover to support river basin management](https://onlinelibrary.wiley.com/doi/abs/10.1002/hyp.14156) by Gao, S., Castellazzi, P., Vervoort, R. W., & Doody, T. M. (2021)

* [Above Ground Biomass Estimation of Syzygium aromaticum using structure from motion (SfM) derived from Unmanned Aerial Vehicle in Paninggahan Agroforest Area, West Sumatra](http://jbioua.fmipa.unand.ac.id/index.php/jbioua/article/view/338) by Harapan, T. S., Husna, A., Febriamansyah, T. A., Mutashim, M., Saputra, A., Taufiq, A., & Mukhtar, E. (2021)

* [Influence of flight parameters on UAS-based monitoring of tree height, diameter, and density](https://www.sciencedirect.com/science/article/abs/pii/S0034425721002601) by Swayze, N. C., Tinkham, W. T., Vogeler, J. C., & Hudak, A. T. (2021)


* [Detection of aspen in conifer-dominated boreal forests with seasonal multispectral drone image point clouds](https://www.silvafennica.fi/article/10515/author/20257) by Hardenbol, A. A., Kuzmin, A., Korhonen, L., Korpelainen, P., Kumpula, T., Maltamo, M., & Kouki, J. (2021)

* [Correcting tree count bias for objects segmented from lidar point clouds](https://www.proquest.com/openview/4c03d80d21aa8d71509deaae79259b9f/1?pq-origsite=gscholar&cbl=2030384) by Strub, M. R., & Osborne, N. (2021)

* [Comparison of Accuracy between Analysis Tree Detection in UAV Aerial Image Analysis and Quadrat Method for Estimating the Number of Trees to be Removed in the Environmental Impact Assessment](https://koreascience.kr/article/JAKO202118752917743.page) by Park, M. (2021)

* [Arboricoltura di precisione: un nuovo approccio alla gestione del rischio caduta alberi basato sulla Geomatica](https://mediageo.it/ojs/index.php/GEOmedia/article/view/1810) by De Petris, S., Sarvia, F., & Borgogno-Mondino, E. (2021)

* [Canopy Extraction and Height Estimation of Trees in a Shelter Forest Based on Fusion of an Airborne Multispectral Image and Photogrammetric Point Cloud](https://www.hindawi.com/journals/js/2021/5519629/) by Wang, X., Zhao, Q., Han, F., Zhang, J., & Jiang, P. (2021)

* [Uav-based lidar scanning for individual tree detection and height measurement in young forest permanent trials](https://www.mdpi.com/2072-4292/14/1/170) by Rodríguez-Puerta, F., Gómez-García, E., Martín-García, S., Pérez-Rodríguez, F., & Prada, E. (2021)

* [UAV-derived forest degradation assessments for planning and monitoring forest ecosystem restoration: towards a forest degradation index](https://www.cifor.org/knowledge/publication/8199/) by Lee, K. (2021)

* [Potential for Individual Tree Monitoring in Ponderosa Pine-Dominated Forests Using Unmanned Aerial System Structure from Motion Point Clouds](https://cdnsciencepub.com/doi/abs/10.1139/cjfr-2020-0433) by Creasy, M. B., Tinkham, W. T., Hoffman, C. M., & Vogeler, J. C. (2021)

* [Assessment of Above-Ground Carbon Storage by Urban Trees Using LiDAR Data: The Case of a University Campus](https://www.mdpi.com/1999-4907/12/1/62) by Gülçin, D., & van den Bosch, C. C. K. (2021)

* [Influence of Agisoft Metashape Parameters on UAS Structure from Motion Individual Tree Detection from Canopy Height Models](https://www.mdpi.com/1999-4907/12/2/250) by Tinkham, W. T., & Swayze, N. C. (2021)

* [Ground-Penetrating Radar as phenotyping tool for characterizing intraspecific variability in root traits of a widespread conifer](https://link.springer.com/article/10.1007/s11104-021-05135-0) by Lombardi, E., Ferrio, J. P., Rodríguez-Robles, U., de Dios, V. R., & Voltas, J. (2021)

* [Bridging the genotype–phenotype gap for a Mediterranean pine by semi‐automatic crown identification and multispectral imagery](https://nph.onlinelibrary.wiley.com/doi/abs/10.1111/nph.16862) by Santini, F., Kefauver, S. C., Araus, J. L., Resco de Dios, V., Martín García, S., Grivet, D., & Voltas, J. (2021)

* [Tracking the rates and mechanisms of canopy damage and recovery following Hurricane Maria using multitemporal lidar data](https://www.biorxiv.org/content/10.1101/2021.03.26.436869v1.abstract) by Leitold, V., Morton, D. C., Martinuzzi, S., Paynter, I., Uriarte, M., Keller, M., Keller, M., Ferraz, A., Cook, B. D., Corp, L. A., & González, G. (2021)

* [Cross-scale interaction of host tree size and climatic water deficit governs bark beetle-induced tree mortality](https://www.nature.com/articles/s41467-020-20455-y) by Koontz, M. J., Latimer, A. M., Mortenson, L. A., Fettig, C. J., & North, M. P. (2021)

### 2020

* [The wildlife‐livestock interface on extensive free‐ranging pig farms in central Spain during the “montanera” period](https://onlinelibrary.wiley.com/doi/abs/10.1111/tbed.13854) by Triguero‐Ocaña, R., Laguna, E., Jiménez‐Ruiz, S., Fernández‐López, J., García‐Bocanegra, I., Barasona, J. Á., ... & Acevedo, P. (2020)

* [Supporting Assessment of Forest Burned Areas by Aerial Photogrammetry: The Susa Valley (NW Italy) Fires of Autumn 2017](https://link.springer.com/chapter/10.1007/978-3-030-58811-3_59) by De Petris, S., Momo, E. J., & Borgogno-Mondino, E. (2020)

* [Applying unmanned aerial vehicles (UAVs) to map shrubland structural attributes in northern Patagonia, Argentina](https://cdnsciencepub.com/doi/abs/10.1139/cjfr-2019-0440@cjfrjuvs-uav.issue1) by Gonzalez Musso, R. F., Oddi, F. J., Goldenberg, M. G., & Garibaldi, L. A. (2020)

* [Automated Canopy Delineation and Size Metrics Extraction for Strawberry Dry Weight Modeling Using Raster Analysis of High-Resolution Imagery](https://www.mdpi.com/2072-4292/12/21/3632) by Abd-Elrahman, A., Guan, Z., Dalid, C., Whitaker, V., Britt, K., Wilkinson, B., & Gonzalez, A. (2020)

* [Northern Bobwhite Non‐Breeding Habitat Selection in a Longleaf Pine Woodland](https://wildlife.onlinelibrary.wiley.com/doi/abs/10.1002/jwmg.21925) by Kroeger, A. J., DePerno, C. S., Harper, C. A., Rosche, S. B., & Moorman, C. E. (2020)

* [Evaluation of Features Derived from High-Resolution Multispectral Imagery and LiDAR Data for Object-Based Support Vector Machine Classification of Tree Species](https://www.tandfonline.com/doi/abs/10.1080/07038992.2020.1809363) by Roffey, M., & Wang, J. (2020)

* [Mapping Species at an Individual-Tree Scale in a Temperate Forest, Using Sentinel-2 Images, Airborne Laser Scanning Data, and Random Forest Classification](https://www.mdpi.com/2072-4292/12/22/3710) by Plakman, V., Janssen, T., Brouwer, N., & Veraverbeke, S. (2020)

### 2019

* [High-resolution multisensor remote sensing to support date palm farm management](https://www.mdpi.com/2077-0472/9/2/26) by Mulley, M., Kooistra, L., & Bierens, L. (2019)

* [Quantifying canopy tree loss and gap recovery in tropical forests under low-intensity logging using VHR satellite imagery and airborne LiDAR](https://www.mdpi.com/2072-4292/11/7/817) by Dalagnol, R., Phillips, O. L., Gloor, E., Galvão, L. S., Wagner, F. H., Locks, C. J., & Aragão, L. E. (2019)

* [Forest inventory sensitivity to UAS-based image processing algorithms](https://afrjournal.org/index.php/afr/article/download/1282/818) by Maturbongs, B., Wing, M. G., Strimbu, B., & Burnett, J. (2019)

* [Remote sensing pipeline for tree segmentation and classification in a mixed softwood and hardwood system](https://peerj.com/articles/5837/) by McMahon, C. A. (2019)

* [Tree height in tropical forest as measured by different ground, proximal, and remote sensing instruments, and impacts on above ground biomass estimates](https://www.sciencedirect.com/science/article/abs/pii/S0303243419300844) by Laurin, G. V., Ding, J., Disney, M., Bartholomeus, H., Herold, M., Papale, D., & Valentini, R. (2019)

* [Advances in the Derivation of Northeast Siberian Forest Metrics Using High-Resolution UAV-Based Photogrammetric Point Clouds](https://www.mdpi.com/2072-4292/11/12/1447) by Brieger, F., Herzschuh, U., Pestryakova, L. A., Bookhagen, B., Zakharov, E. S., & Kruse, S. (2019)

* [Multi-scale Assessment of Northern Bobwhite and White-tailed Deer Habitat Selection in Longleaf Pine Woodlands](https://repository.lib.ncsu.edu/bitstream/handle/1840.20/37046/etd.pdf?sequence=1) by Kroeger, A. J. (2019)

### 2018

* [Bayesian and classical machine learning methods: a comparison for tree species classification with LiDAR waveform signatures](https://www.mdpi.com/2072-4292/10/1/39) by Zhou, T., Popescu, S. C., Lawing, A. M., Eriksson, M., Strimbu, B. M., & Bürkner, P. C. (2018)

### 2017

* [Underproductive agriculture aids connectivity in tropical forests](https://www.sciencedirect.com/science/article/abs/pii/S0378112717308101) by Evans, L. J., Goossens, B., & Asner, G. P. (2017)
