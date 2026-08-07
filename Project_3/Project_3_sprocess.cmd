###########################################################################
# Sentaurus Process Command File
# Project 3 : Parametric 2D nMOS — Gate Length Sweep
#
# SWB Parameter : Lg (List) = 1  0.5  0.35  0.18  0.13   [um]
#
# Assignment specs:
#   S/D doping    : 5e18 – 1e20 cm-3
#   Substrate     : 1e16 cm-3 Boron
#   Junction depth: ~0.19 um (Arsenic 40 keV + 1050 C anneal)
#   LDD           : ~5e17 cm-3 (1-2 orders below S/D)
#   Gate oxide    : ~9 nm (850 C, 20 min, dry O2)
###########################################################################


###########################################################################
# SECTION 1 : 2D Grid (half-cell, y=0 is symmetry axis)
###########################################################################

line x location= 0.0       spacing= 1.0<nm>   tag= SiTop
line x location= 20.0<nm>  spacing= 5.0<nm>
line x location= 0.2<um>   spacing= 20.0<nm>
line x location= 0.5<um>   spacing= 50.0<nm>
line x location= 2.0<um>   spacing= 0.2<um>
line x location= 4.0<um>   spacing= 0.5<um>
line x location= 10.0<um>  spacing= 2.0<um>   tag= SiBottom

line y location= 0.0       spacing= 20.0<nm>  tag= Mid
line y location= 0.8<um>   spacing= 50.0<nm>  tag= Right

region Silicon xlo= SiTop xhi= SiBottom ylo= Mid yhi= Right

init concentration= 1.0e+16<cm-3> field= Boron !DelayFullD

AdvancedCalibration

struct tdr= n@node@_wafer !Gas


###########################################################################
# SECTION 2 : Well and Channel Implants
###########################################################################

implant Boron dose= 2.0e13<cm-2> energy= 200<keV> tilt= 0 rotation= 0
implant Boron dose= 1.0e13<cm-2> energy= 80<keV>  tilt= 0 rotation= 0
implant Boron dose= 2.0e12<cm-2> energy= 25<keV>  tilt= 0 rotation= 0

struct tdr= n@node@_pwell !Gas


###########################################################################
# SECTION 3 : Gate Oxide Growth  (~9 nm)
###########################################################################

grid set.min.normal.size= 1<nm> set.normal.growth.ratio.2d= 1.5
pdbSet Oxide Grid perp.add.dist 1e-7

diffuse temperature= 850<C> time= 20.0<min> O2

select z=1
layers

struct tdr= n@node@_gateox !Gas


###########################################################################
# SECTION 4 : Polysilicon Gate (parametric Lg)
# left=-1 covers the symmetry side; right=@Lg@/2 sets the gate edge
###########################################################################

deposit material= {PolySilicon} type= anisotropic time= 1 rate= {@Lg@}

struct tdr= n@node@_polydep !Gas

mask name= gate_mask left= -1 right= @Lg@/2<um>

etch material= {PolySilicon} type= anisotropic time= 1 rate= {0.5} \
     mask= gate_mask

etch material= {Oxide} type= anisotropic time= 1 rate= {0.1}

struct tdr= n@node@_gateetch !Gas


###########################################################################
# SECTION 5 : Poly Reoxidation
###########################################################################

diffuse temperature= 900<C> time= 10.0<min> O2

struct tdr= n@node@_gatemask !Gas


###########################################################################
# SECTION 6 : Remesh for LDD and Halo
###########################################################################

refinebox Silicon min= {0.0 0.05} max= {0.15 0.2} \
          xrefine= {0.005 0.005 0.005} \
          yrefine= {0.005 0.005 0.005} add
grid remesh


###########################################################################
# SECTION 7 : LDD and Halo Implants
###########################################################################

implant Arsenic dose= 5e13<cm-2>    energy= 10<keV> tilt= 0  rotation= 0

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

refinebox Silicon min= {0.04 0.2} max= {0.25 0.8} \
          xrefine= {0.01 0.01 0.01} \
          yrefine= {0.05 0.05 0.05} add
grid remesh


###########################################################################
# SECTION 10 : Deep Source/Drain Implant + Anneal
###########################################################################

implant Arsenic dose= 5e15<cm-2> energy= 40<keV> \
                tilt= 7<degree>  rotation= -90<degree>

diffuse temperature= 1050<C> time= 10.0<s>

struct tdr= n@node@_sourcedrain !Gas


###########################################################################
# SECTION 11 : Contact Pads
###########################################################################

deposit material= {Aluminum} type= isotropic time= 1 rate= {0.05}

mask name= contacts_mask left= 0.3<um> right= 0.8<um>

etch material= {Aluminum} type= anisotropic time= 1 rate= {0.25} \
     mask= contacts_mask

struct tdr= n@node@_contacts !Gas


###########################################################################
# SECTION 12 : Electrical Contact Definitions
###########################################################################

contact name= substrate bottom
contact name= source   point y= 0.0     x= -0.02<um>
contact name= drain    point y= 0.5<um> x= -0.02<um> replace
contact name= gate     point y= 0.0     x= -0.10<um>


###########################################################################
# SECTION 13 : Final Structure Save (full symmetric device)
###########################################################################

transform reflect left
struct tdr= n@node@_fps !Gas

exit
