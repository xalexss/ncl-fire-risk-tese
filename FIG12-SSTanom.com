#!/bin/csh


echo "============================================="
echo "        "
echo "Processando ano ==> 2001a16"
echo "        "
echo "============================================="


cat>studentBR.ncl<<EOF
;***************************************************************
;Returns an estimate of the statistical significance and, optionally, the t-values.
;Use NCL's named dimensions to reorder in time.
;Calculate the temporal means and variances using the dim_avg 
;and dim_variance functions.
;Specify a critical significance level to test the lag-one 
;auto-correlation coefficient and determine the (temporal) number
; of equivalent sample sizes in each grid point using equiv_sample_size.
;Estimate a single global mean equivalent sample size using wgt_areaave (optional).
;Specify a critical significance level for the ttest and test if the means are different at each grid point.
;***************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
                            
begin

;##################################################################
;##############  READING Precipitation files...  ##################
;##################################################################


;colors = (/"midnightblue","mediumblue","blue2","cyan3","cyan2","lightskyblue1",\
;           "lightblue1","lightcyan","white","bisque","lightsalmon1","lightsalmon1",\
;           "coral1","coral3","red1","firebrick4"/)

;colors = (/"firebrick4","red3","red1","coral3","coral2","coral1",\
;              "coral","lightsalmon2","lightsalmon1","bisque","floralwhite",\
;              "white","lightcyan","lightblue1","lightskyblue1","cyan2",\
;              "cyan3","dodgerblue2","dodgerblue3","blue2","mediumblue",\
;              "midnightblue"/)

;colors = (/"firebrick4","red3","red1","coral3","coral2","coral1","coral",\
;           "lightsalmon2","lightsalmon1","bisque","floralwhite",\
;           "white","lightcyan","lightblue1","lightskyblue1","cyan2","cyan3",\
;           "cyan4","dodgerblue2","dodgerblue3",\
;           "blue2","midnightblue"/)

colors = (/"midnightblue","blue2","dodgerblue3","dodgerblue2","cyan4","cyan3","cyan2","lightskyblue1",\
           "lightblue1","lightcyan","white","floralwhite","bisque","lightsalmon1",\
           "lightsalmon2","coral","coral1","coral2","coral3","red1","red3",\
           "firebrick4"/)

escala = (/-2,-1.8, -1.6, -1.4, -1.2, -1, -0.8, -0.6, -0.4, -0.2, 0, 0.005, 0.2, 0.4, 0.6, 0.8, 1.2, 1.4, 1.6, 1.8, 2/) ;set levels


; ========================= PLOT 1 ==============================
  
;  wkstype= "ps"
  wkstype= "png"
  plot = new (1,graphic)
;  wks   = gsn_open_wks (wkstype,"TEST-t-NDJF-PREC")   ; open workstation 
;  wks   = gsn_open_wks (wkstype,"TEST-t-MAMJ-PREC")   ; open workstation 
  wks   = gsn_open_wks (wkstype,"zFIG12-TEST-t-SST")   ; open workstation 
;  gsn_define_colormap(wks,"BlueWhiteOrangeRed")
;  gsn_define_colormap(wks,"BlWhRe")
  gsn_define_colormap(wks,"colors")


  var_min5  =  -2.2                        ;-- minimum value to be displayed
  var_max5  =  2.2                        ;-- maximum value to be displayed
  var_inc5  =  0.1                        ;-- increment

; **********************************************************************
; Global Projection
; *****************************************************************
  lon_min  = 90                        ;-- minimum longitude
  lon_max  = 450.0                        ;-- maximum longitude
  lat_min  =  -40.0                        ;-- minimum latitude
  lat_max  =  15.0                        ;-- maximum latitude

;************************************************
; create plot
;************************************************

;plots = new(10,graphic)
plots = new(3,graphic)

;*************************************************

;************************************************
; Read the file
;************************************************
            
  fils011 = ("/media/z400/BACKUP-dOUt-ALEX/PC-SERVIDOR/XFire-Metod/ERAIxCPC/ENSO-ONI/SST/zzERAI-SSTmean-1998a2018-360-celsius.nc")

;  fils011 = ("/media/z400/BACKUP-dOUt-ALEX/PC-SERVIDOR/XFire-Metod/ERAIxCPC/ENSO-ONI/SST/zxERAI-SSTmean-1998a2018-a360-celsiu.nc")

;***********************************************
  f011    = addfile(fils011, "r") 
  x011    = f011->sst
  tsm    = f011->sst(0,:,:)

          printVarSummary( x011 ) 
;          printMinMax( tsm, True )

;#############################################################
;###############  FIGURE CONFIGS...  #########################
;#############################################################

  var_min87  =  0                        ;-- minimum value to be displayed
  var_max87  =  30                        ;-- maximum value to be displayed
  var_inc87  =  2.5                        ;-- increment

  res87 = True                                 ; plot mods desired

  res87@mpMinLonF =  lon_min    ;-- sub-region minimum longitude
  res87@mpMaxLonF =  lon_max    ;-- sub-region maximum longitude
  res87@mpMinLatF =  lat_min    ;-- sub-region minimum latitude
  res87@mpMaxLatF =  lat_max    ;-- sub-region maximum latitude
;  res87@cnFillPalette        = colors      ; set color map
  res87@mpDataSetName = "Earth..4"
  res87@mpOutlineBoundarySets = "National"
  res87@pmTickMarkDisplayMode = "Always"
  res87@mpGeophysicalLineColor = "Black"

  res87@gsnDraw              = False           ; Do not draw plot
  res87@gsnFrame             = False           ; Do not advance frome

  res87@gsnLeftString     = "a) SST (ERAI)"
  res87@gsnCenterString     = "Climatology (1998 to 2018)"
;  res87@gsnRightString    = "NiNa (3 years)                   Anomaly [95% signif.]~C~ ~C~ ~C~" 
  res87@gsnRightString    = "        ~C~ ~C~ ~C~" 
  res87@gsnCenterStringFontHeightF = 0.016
  res87@gsnRightStringFontHeightF = 0.016
  res87@gsnLeftStringFontHeightF = 0.016

  res87@mpFillOn             = True        ; turn off map fill
  res87@mpCenterLonF         = 270
  res87@cnFillOn             = True         ; turn on color fill
  res87@cnLinesOn            = False        ; True is default
  res87@cnLineLabelsOn       = False        ; True is default
;  res87@lbLabelBarOn         = True       ; turn off individual lb's
;  res87@lbBoxMinorExtentF   = 0.17            ; decrease the height of the labelbar
;  res87@lbLabelFontHeightF = .01 

  res87@lbLabelBarOn = True
  res87@lbLabelFontHeightF = .01 
  res87@lbBoxMinorExtentF   = 0.1            ; decrease the height of the labelbar
  res87@lbBottomMarginF  = - 1.5  ; bar distance

  res87@cnLevelSelectionMode   = "ManualLevels"     ;-- set manual contour levels
  res87@cnMinLevelValF         =  var_min87           ;-- set min contour level
  res87@cnMaxLevelValF         =  var_max87           ;-- set max contour level
  res87@cnLevelSpacingF        =  var_inc87           ;-- set increment
;  res87@lbLabelBarOn = False

res87@cnFillPalette          = "WhiteBlueGreenYellowRed"

;  res87@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
;  res87@cnLevels             = escala       ;set levels

  plots(0) = gsn_csm_contour_map(wks,tsm,res87)
 
;************************************************
; Read the file
;************************************************
            
;  fils04 = ("/media/z400/BACKUP-dOUt-ALEX/PC-SERVIDOR/XFire-Metod/ERAIxCPC/ENSO-ONI/SST/zzERAI-SSTmean-2011.nc")

  fils04 = ("/media/z400/BACKUP-dOUt-ALEX/PC-SERVIDOR/XFire-Metod/ERAIxCPC/ENSO-ONI/SST/zzERAI-SSTmean-2011anom.nc")


  f04    = addfile(fils04, "r")  
;  x04    = f04->sst(0,:,:)
  x04    = f04->sstanom(:,:)

  difAve03 = x04  ; (ERAI - CPC)
;  copy_VarCoords (difAve03, x04) 

  printVarSummary(difAve03)
  printMinMax( difAve03, True ) 

;#############################################################
;###############  FIGURE CONFIGS...  #########################
;#############################################################

  res3 = True                                 ; plot mods desired

  res3@mpMinLonF =  lon_min    ;-- sub-region minimum longitude
  res3@mpMaxLonF =  lon_max    ;-- sub-region maximum longitude
  res3@mpMinLatF =  lat_min    ;-- sub-region minimum latitude
  res3@mpMaxLatF =  lat_max    ;-- sub-region maximum latitude
  res3@cnFillPalette        = colors      ; set color map
  res3@mpDataSetName = "Earth..4"
  res3@mpOutlineBoundarySets = "National"
  res3@pmTickMarkDisplayMode = "Always"
  res3@mpGeophysicalLineColor = "Black"

  res3@gsnDraw              = False           ; Do not draw plot
  res3@gsnFrame             = False           ; Do not advance frome

  res3@gsnLeftString     = "b) SST (ERAI)"
  res3@gsnCenterString    = "Anomaly (2011)" 
;  res3@gsnRightString    = "Anomaly (2011)                   Clim. [1998 to 2018]" 
;  res3@gsnRightStringFontHeightF = 0.016
  res3@gsnLeftStringFontHeightF = 0.016
  res3@gsnCenterStringFontHeightF = 0.016

  res3@mpFillOn             = True        ; turn off map fill
  res3@mpCenterLonF         = 270

  res3@cnFillOn             = True         ; turn on color fill
  res3@cnLinesOn            = False        ; True is default
  res3@cnLineLabelsOn       = False        ; True is default
;  res3@lbLabelBarOn         = True       ; turn off individual lb's
;  res3@lbBoxMinorExtentF   = 0.17            ; decrease the height of the labelbar
;  res3@lbLabelFontHeightF = .01 

  res3@lbLabelBarOn = True
  res3@lbLabelFontHeightF = .01 
  res3@lbBoxMinorExtentF   = 0.1            ; decrease the height of the labelbar
  res3@lbBottomMarginF  = - 1.5  ; bar distance

  res3@cnLevelSelectionMode   = "ManualLevels"     ;-- set manual contour levels
  res3@cnMinLevelValF         =  var_min5           ;-- set min contour level
  res3@cnMaxLevelValF         =  var_max5           ;-- set max contour level
  res3@cnLevelSpacingF        =  var_inc5           ;-- set increment
;  res3@lbLabelBarOn = False

  res3@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res3@cnLevels = escala       ;set levels

  plots(1) = gsn_csm_contour_map(wks,difAve03(:,:), res3)

;************************************************
; Read the file
;************************************************
            
;  fils10 = ("/media/z400/BACKUP-dOUt-ALEX/PC-SERVIDOR/XFire-Metod/ERAIxCPC/ENSO-ONI/SST/zzERAI-SSTmean-2015.nc")

  fils10 = ("/media/z400/BACKUP-dOUt-ALEX/PC-SERVIDOR/XFire-Metod/ERAIxCPC/ENSO-ONI/SST/zzERAI-SSTmean-2015anom.nc")


  f10    = addfile(fils10, "r")  
;  x10    = f10->sst(0,:,:)
  x10    = f10->sstanom(:,:)

  difAve10 = x10  ; (ERAI - CPC)
;  copy_VarCoords (difAve10, x10) 

  printVarSummary(difAve10)
  printMinMax( difAve10, True ) 

;#############################################################
;###############  FIGURE CONFIGS...  #########################
;#############################################################

  res4 = True                                 ; plot mods desired

  res4@mpMinLonF =  lon_min    ;-- sub-region minimum longitude
  res4@mpMaxLonF =  lon_max    ;-- sub-region maximum longitude
  res4@mpMinLatF =  lat_min    ;-- sub-region minimum latitude
  res4@mpMaxLatF =  lat_max    ;-- sub-region maximum latitude
  res4@cnFillPalette        = colors      ; set color map
  res4@mpDataSetName = "Earth..4"
  res4@mpOutlineBoundarySets = "National"
  res4@pmTickMarkDisplayMode = "Always"
  res4@mpGeophysicalLineColor = "Black"

  res4@gsnDraw              = False           ; Do not draw plot
  res4@gsnFrame             = False           ; Do not advance frome

  res4@gsnLeftString     = "c) SST (ERAI)"
  res4@gsnCenterString    = "Anomaly (2015)" 
;  res4@gsnRightString    = "Anomaly (2015)                   Clim. [1998 to 2018]" 
;  res4@gsnRightStringFontHeightF = 0.016
  res4@gsnLeftStringFontHeightF = 0.016
  res4@gsnCenterStringFontHeightF = 0.016

  res4@mpFillOn             = True        ; turn off map fill
  res4@mpCenterLonF         = 270

  res4@cnFillOn             = True         ; turn on color fill
  res4@cnLinesOn            = False        ; True is default
  res4@cnLineLabelsOn       = False        ; True is default
;  res4@lbLabelBarOn         = True       ; turn off individual lb's
;  res4@lbBoxMinorExtentF   = 0.17            ; decrease the height of the labelbar
;  res4@lbLabelFontHeightF = .01 

  res4@lbLabelBarOn = True
  res4@lbLabelFontHeightF = .01 
  res4@lbBoxMinorExtentF   = 0.1            ; decrease the height of the labelbar
  res4@lbBottomMarginF  = - 1.5  ; bar distance

  res4@cnLevelSelectionMode   = "ManualLevels"     ;-- set manual contour levels
  res4@cnMinLevelValF         =  var_min5           ;-- set min contour level
  res4@cnMaxLevelValF         =  var_max5           ;-- set max contour level
  res4@cnLevelSpacingF        =  var_inc5           ;-- set increment
;  res4@lbLabelBarOn = False

  res4@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res4@cnLevels = escala       ;set levels

  plots(2) = gsn_csm_contour_map(wks,difAve10(:,:), res4)

;***************************************************************
;*****************  create panel  ******************************
;***************************************************************

resP = True

;resP@gsnPanelLabelBar = True
;resP@lbBottomMarginF  = - 1.5          ; bar position (down; up)
;resP@lbBottomMarginF  = - 0.2          ; bar position (down; up)
;resP@lbBoxMinorExtentF   = 0.17        ; decrease the height of the labelbar
;resP@lbBoxMinorExtentF   = 0.25        ; decrease the height of the labelbar
;resP@lbLabelFontHeightF = .01         ; decrease the text font of the lbbar

;gsn_panel(wks,plots,(/5,2/),resP)
gsn_panel(wks,plots,(/3,1/),resP)


end
EOF
ncl studentBR.ncl



