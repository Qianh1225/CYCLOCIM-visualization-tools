# CYCLOCIM visualization tools
This project is designed to visualize Cyclo Ocean Circulation Inverse Model (CYCLOCIM)'s performance.

### 1. Project Overview<a name="overview"></a>

To provide a tool for scientists to study the biogeochemical cycle and global warming,  we developed a new 4-D variational assimilation system, called CYCLOCIM [[1]](#1).  The model estimates the climatological seasonal cycle of the residual mean ocean circulation by assimilating monthly mean potential temperature, salinity data, CFC-11, CFC-12 and natural radiocarbon measurements.  CYCLOCIM is a pioneer study that combines data, physics and machine learning framework. Here is the workflow of CYCLOCIM.
![flow](flow.jpg =100x100)

The first version is done, and we are working on the second version. In order to evaluate and compare the performance of different version of CYCLOCIM, we make the visualization tools using matlab.

### 2. Project Components<a name="components"></a>

The visualization tools includes two parts:
1. Measure the fitness between modeled data and observation and compare the different model versions:
	(1) Vertical RMSE for Potential temperature, salinity, and CFC-11.
    (2) Joint distribution function for the gridbox volume weighted observed and modeled tracer concentrations.
    (3) Temperature and Salinity difference in the upper ocean
    (4) Longitude-depth section of the modeled and observed potential temperature abnormaly in comparison with the annual mean.
    (5) Masked zonal mean CFCs concentration for CYCLOCIM compared to observation in each decade.
    (6) Masked zonal mean C14/C12/(C14/C14)_atm compared to observation in different ocean basin.
    
2. Display the modeled physics:
    (7) meridional Heat and freshwater transport and surface flux.
    (8) meridional streamfunction in different ocean basin.
    (9) horizontal streamfunction.
    (10) modeled sea surface height (SSH).

### 3. Installation<a name="installation"></a>

 - The code should run with no issues using  matlab.
 - You need to obtain the CYCLOCIM results from the [Primeau Research Group](https://faculty.sites.uci.edu/primeau/).

### 4. File Descriptions<a name="files"></a>

**main.m**
* This is the main script to run all the analysis and make plots for CYCLOCIM's results.
* User can customize the  plots by choose different models to load and compare, and choose the types of plots to produce.

**main_paper.m**
* Customized plots for CYCLOCIM paper. [[1]](#1)

**functions/**
* Contains the functions to calculate  and plot the figures.

**data/**
* Contains complementary observations dataset.

**colorScheme**
*The color schemes used in plotting.  
* It includes cbrewer (colorbrewer schemes for Matlab).[[2]](#2)


### 6. Acknowledgements<a name="licensing">

This project was completed as part of the CYCLOCIM project in [Primeau Research Group](https://faculty.sites.uci.edu/primeau/). The datasets used in this project are documenting in the paper. [[1]](#1)

### References
<a id="1">[1]</a> 
Qian Huang, Francois Primeau, Timothy DeVries, CYCLOCIM: A 4-D variational assimilation system for the climatological mean seasonal cycle of the ocean circulation, Ocean modelling

<a id="2">[2]</a> 
https://www.mathworks.com/matlabcentral/fileexchange/34087-cbrewer-colorbrewer-schemes-for-matlab
