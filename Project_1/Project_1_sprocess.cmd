###########################################################################
# Sentaurus Process Command File
# Project 1 : 180 nm 2D nMOS — WITHOUT reflection in final save
#
# Reference : sp_3.html (Applications_Library/GettingStarted/sprocess/2DGS)
#             EICT/IIT TCAD Summer Training 2024 — Day 1-5 sample scripts
#
# The standard 2DGS template ends with:
#     transform reflect left
#     struct tdr= n@node@_NMOS
# This project intentionally OMITS "transform reflect left" as required.
###########################################################################


###########################################################################
# SECTION 1 : Initial 2D Grid and Simulation Domain
###########################################################################

line x location= 0.0       spacing= 1.0<nm>   tag= SiTop
line x location= 50.0<nm>  spacing= 10.0<nm>
line x location= 0.5<um>   spacing= 50.0<nm>
line x location= 2.0<um>   spacing= 0.2<um>
line x location= 4.0<um>   spacing= 0.4<um>
line x location= 10.0<um>  spacing= 2.0<um>   tag= SiBottom

line y location= 0.0       spacing= 50.0<nm>  tag= Mid
line y location= 0.40<um>  spacing= 50.0<nm>  tag= Right

region Silicon xlo= SiTop xhi= SiBottom ylo= Mid yhi= Right

init concentration= 1.0e+15<cm-3> field= Phosphorus !DelayFullD

AdvancedCalibration

struct tdr= n@node@_wafer !Gas


###########################################################################
# SECTION 2 : Boron Implantations  (p-well + retrograde + Vt adjust)
###########################################################################

implant Boron dose= 2.0e13<cm-2> energy= 200<keV> tilt= 0 rotation= 0
implant Boron dose= 1.0e13<cm-2> energy= 80<keV>  tilt= 0 rotation= 0
implant Boron dose= 2.0e12<cm-2> energy= 25<keV>  tilt= 0 rotation= 0

struct tdr= n@node@_pwell !Gas


###########################################################################
# SECTION 3 : Gate Oxide Growth  (~2.9 nm dry SiO2)
###########################################################################

grid set.min.normal.size= 1<nm> set.normal.growth.ratio.2d= 1.5
pdbSet Oxide Grid perp.add.dist 1e-7

diffuse temperature= 1050<C> time= 10.0<s>

select z=1
layers

struct tdr= n@node@_gateox !Gas


###########################################################################
# SECTION 4 : Polysilicon Gate Deposition and Patterning
###########################################################################

deposit material= {PolySilicon} type= anisotropic time= 1 rate= {0.18}

struct tdr= n@node@_polydep !Gas

mask name= gate_mask left= -1 right= 90<nm>

etch material= {PolySilicon} type= anisotropic time= 1 rate= {0.2} \
     mask= gate_mask

etch material= {Oxide} type= anisotropic time= 1 rate= {0.1}

struct tdr= n@node@_gateetch !Gas


###########################################################################
# SECTION 5 : Polysilicon Reoxidation  (stress relief)
###########################################################################

diffuse temperature= 900<C> time= 10.0<min> O2

struct tdr= n@node@_gatemask !Gas


###########################################################################
# SECTION 6 : Remesh for LDD and Halo
###########################################################################

refinebox Silicon min= {0.0 0.05} max= {0.1 0.12} \
          xrefine= {0.01 0.01 0.01} \
          yrefine= {0.01 0.01 0.01} add
grid remesh


###########################################################################
# SECTION 7 : LDD and Halo Implantations
###########################################################################

implant Arsenic dose= 4e14<cm-2>    energy= 10<keV> tilt= 0  rotation= 0

implant Boron   dose= 0.25e13<cm-2> energy= 20<keV> tilt= 30<degree> \
                rotation= 0
implant Boron   dose= 0.25e13<cm-2> energy= 20<keV> tilt= 30<degree> \
                rotation= 90<degree>
implant Boron   dose= 0.25e13<cm-2> energy= 20<keV> tilt= 30<degree> \
                rotation= 180<degree>
implant Boron   dose= 0.25e13<cm-2> energy= 20<keV> tilt= 30<degree> \
                rotation= 270<degree>

diffuse temperature= 1050<C> time= 0.1<s>

struct tdr= n@node@_ldd !Gas


###########################################################################
# SECTION 8 : Spacer Formation
###########################################################################

deposit material= {Nitride} type= isotropic  time= 1 rate= {0.06}
etch    material= {Nitride} type= anisotropic time= 1 rate= {0.084} \
        isotropic.overetch= 0.01
etch    material= {Oxide}   type= anisotropic time= 1 rate= {0.01}

struct tdr= n@node@_spacer !Gas


###########################################################################
# SECTION 9 : Remesh for Source/Drain
###########################################################################

refinebox Silicon min= {0.04 0.12} max= {0.18 0.4} \
          xrefine= {0.01 0.01 0.01} \
          yrefine= {0.05 0.05 0.05} add
grid remesh


###########################################################################
# SECTION 10 : Source/Drain Implantations
###########################################################################

implant Arsenic dose= 5e15<cm-2> energy= 40<keV> \
                tilt= 7<degree>  rotation= -90<degree>

diffuse temperature= 1050<C> time= 10.0<s>

struct tdr= n@node@_sourcedrain !Gas


###########################################################################
# SECTION 11 : Contact Pads
###########################################################################

deposit material= {Aluminum} type= isotropic time= 1 rate= {0.03}

mask name= contacts_mask left= 0.2<um> right= 1.0<um>

etch material= {Aluminum} type= anisotropic time= 1 rate= {0.25} \
     mask= contacts_mask

struct tdr= n@node@_contacts !Gas


###########################################################################
# SECTION 12 : 1D Profile Extraction
###########################################################################

SetPlxList {BTotal NetActive}
WritePlx n@node@_NMOS_channel.plx y= 0.0   Silicon

SetPlxList {AsTotal BTotal NetActive}
WritePlx n@node@_NMOS_ldd.plx     y= 0.1   Silicon

SetPlxList {AsTotal BTotal NetActive}
WritePlx n@node@_NMOS_sd.plx      y= 0.39  Silicon


###########################################################################
# SECTION 13 : Final Structure Save — NO reflection
###########################################################################

struct tdr= n@node@_fps !Gas

exit
