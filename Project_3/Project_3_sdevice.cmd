###########################################################################
# Sentaurus Device Command File
# Project 3 : Parametric 2D nMOS — Full Characterization (Q5)
#
# Runs in sequence:
#   Step 0 : Equilibrium
#   Step 1 : Id-Vg at Vd = 50 mV   (linear, Vth_lin, Ioff)
#   Step 2 : Id-Vg at Vd = 1.5 V   (saturation, Vth_sat, Isat, SS)
#   Step 3 : Id-Vd at Vg = 1.0 V   (output characteristic)
#   Step 4 : Gate C-V at 1 MHz
###########################################################################

File {
   Grid=      "@tdr@"
   Plot=      "n@node@_des.tdr"
   Current=   "n@node@_des.plt"
   Output=    "n@node@_des.log"
   ACExtract= "n@node@_des.acplot"
}

Electrode {
   { Name="source"    Voltage= 0.0 }
   { Name="drain"     Voltage= 0.0 }
   { Name="gate"      Voltage= 0.0 }
   { Name="substrate" Voltage= 0.0 }
}

Physics {
   EffectiveIntrinsicDensity( OldSlotboom )
   Fermi
   IncompleteIonization
}

Physics(Material="Silicon") {
   Mobility(
      PhuMob
      DopingDep
      HighFieldSaturation
      Enormal
   )
   Recombination(
      Avalanche
      SRH( DopingDependence TempDependence )
   )
}

Math {
   Extrapolate
   RelErrControl
   Digits= 5
   ErrRef(electron)= 1.e10
   ErrRef(hole)= 1.e10
   Iterations= 20
   Notdamped= 100
   Method= Blocked
   SubMethod= Super
   ACMethod= Blocked
   ACSubMethod= Super
   ExitOnFailure
}

Plot {
   eDensity hDensity
   TotalCurrent/Vector eCurrent/Vector hCurrent/Vector
   eMobility hMobility
   eVelocity hVelocity
   eQuasiFermi hQuasiFermi
   ElectricField/Vector Potential SpaceCharge
   Doping DonorConcentration AcceptorConcentration
   SRH AvalancheGeneration
   BandGap BandGapNarrowing
   ConductionBand ValenceBand
   eQuantumPotential
}

Solve {

*========================================================================
* STEP 0 : Equilibrium
*========================================================================
   NewCurrentPrefix= "init_"
   Coupled(Iterations= 100){ Poisson }
   Coupled{ Poisson Electron Hole }
   Plot(FilePrefix= "n@node@_equi")

*========================================================================
* STEP 1 : Id-Vg at Vd = 50 mV  (linear regime)
*========================================================================
   Quasistationary(
      InitialStep= 0.05 Increment= 1.5
      MinStep= 1e-5    MaxStep= 0.05
      Goal{ Name="drain" Voltage= 0.05 }
   ){ Coupled{ Poisson Electron Hole } }

   NewCurrentPrefix= "IdVg_lin_"
   Quasistationary(
      DoZero
      InitialStep= 0.01 Increment= 1.5
      MinStep= 1e-5    MaxStep= 0.05
      Goal{ Name="gate" Voltage= 2.0 }
   ){ Coupled{ Poisson Electron Hole } }

*========================================================================
* STEP 2 : Id-Vg at Vd = 1.5 V  (saturation regime)
*========================================================================
   Quasistationary(
      InitialStep= 0.05 Increment= 1.5
      MinStep= 1e-5    MaxStep= 0.2
      Goal{ Name="drain" Voltage= 1.5 }
   ){ Coupled{ Poisson Electron Hole } }

   NewCurrentPrefix= "IdVg_sat_"
   Quasistationary(
      DoZero
      InitialStep= 0.01 Increment= 1.5
      MinStep= 1e-5    MaxStep= 0.05
      Goal{ Name="gate" Voltage= 2.0 }
   ){ Coupled{ Poisson Electron Hole } }

*========================================================================
* STEP 3 : Id-Vd  (output characteristic at Vg = 1.0 V)
*========================================================================
   Quasistationary(
      InitialStep= 0.05 Increment= 1.5
      MinStep= 1e-5    MaxStep= 0.2
      Goal{ Name="gate"  Voltage= 0.0 }
      Goal{ Name="drain" Voltage= 0.0 }
   ){ Coupled{ Poisson Electron Hole } }

   Quasistationary(
      InitialStep= 0.05 Increment= 1.5
      MinStep= 1e-5    MaxStep= 0.1
      Goal{ Name="gate" Voltage= 1.0 }
   ){ Coupled{ Poisson Electron Hole } }

   NewCurrentPrefix= "IdVd_"
   Quasistationary(
      DoZero
      InitialStep= 0.05 Increment= 1.5
      MinStep= 1e-5    MaxStep= 0.1
      Goal{ Name="drain" Voltage= 1.5 }
   ){ Coupled{ Poisson Electron Hole } }

*========================================================================
* STEP 4 : Gate C-V at 1 MHz
*========================================================================
   Quasistationary(
      InitialStep= 0.05 Increment= 1.5
      MinStep= 1e-5    MaxStep= 0.2
      Goal{ Name="gate"  Voltage= 0.0 }
      Goal{ Name="drain" Voltage= 0.0 }
   ){ Coupled{ Poisson Electron Hole } }

   Quasistationary(
      DoZero
      InitialStep= 0.01 Increment= 1.3
      MaxStep= 0.05    MinStep= 1e-5
      Goal{ Name="gate" Voltage= -3.0 }
   ){ Coupled{ Poisson Electron Hole } }

   NewCurrentPrefix= "CV_"
   Quasistationary(
      InitialStep= 0.01 Increment= 1.3
      MaxStep= 0.05    MinStep= 1e-5
      Goal{ Name="gate" Voltage= 3.0 }
   ){ ACCoupled(
      StartFrequency= 1e6 EndFrequency= 1e6 NumberOfPoints= 1 Decade
      Node("gate" "drain" "source" "substrate")
      Exclude("drain" "source" "substrate")
      ACCompute(Time= (Range= (0 1) Intervals= 40))
   ){ Poisson Electron Hole }
   }

}
