# Sentaurus TCAD — 2D MOSFET Process & Device Simulation

**Summer Training Project | IIT / EICT Academy TCAD Workshop 2026**
**Author: Kevin Jacob | ECE, MBCET Trivandrum | Batch 2029**
**GitHub: [github.com/programerz30](https://github.com/programerz30)**

---

## Overview

This repository documents three progressive TCAD simulation projects completed during the Synopsys Sentaurus TCAD summer training program. The projects cover 2D semiconductor process simulation, device characterization, and parametric analysis of n-channel MOSFETs using the Sentaurus Workbench (SWB) tool suite.

All simulations were performed using:
- **Sentaurus Process (sprocess)** — fabrication simulation
- **Sentaurus Device (sdevice)** — electrical characterization
- **Sentaurus Visual (svisual)** — result visualization and plotting

---

## Repository Structure

```
Sentaurus-TCAD-MOSFET/
│
├── Project_1/                        # 180 nm 2D nMOS (no reflection)
│   ├── sprocess_180nm.cmd            # Process flow script
│   └── screenshots/
│       └── final_structure.png
│
├── Project_2/                        # 180 nm 2D nMOS (full structure)
│   ├── sprocess_180nm_full.cmd       # Process flow with reflect
│   ├── sdevice_180nm.cmd             # I-V + C-V characterization
│   ├── svisual_180nm.tcl             # Plotting script
│   └── screenshots/
│       └── final_structure.png
│
├── Project_3/                        # Parametric 2D MOSFET (Lg sweep)
│   ├── sprocess_parametric.cmd       # Parametric process (Lg = 0.13–1 um)
│   ├── sdevice_parametric.cmd        # Device characterization
│   ├── svisual_parametric.tcl        # Plots: IdVg, IdVd, CV
│   └── screenshots/
│       ├── Lg_0.13um/
│       ├── Lg_0.18um/
│       ├── Lg_0.35um/
│       ├── Lg_0.5um/
│       └── Lg_1um/
│
└── README.md
```

---

## Project 1 — 180 nm 2D nMOS (No Reflection)

### Objective
Simulate a nominal 0.18 µm n-channel MOSFET in 2D using the `Applications_Library/GettingStarted/sprocess/2DGS` template, **without using** `transform reflect left` in the final structure save step.

### Approach
The simulation uses the standard half-cell approach from the sp_3 tutorial, but the final `struct tdr=` command intentionally omits the reflect keyword. This preserves the half-cell geometry exactly as simulated, rather than creating a mirrored full device.

### Key Parameters

| Parameter | Value |
|---|---|
| Technology node | 180 nm |
| Gate oxide (Tox) | ~2.9 nm (dry O2, 1050°C, 10s) |
| Substrate doping | 1×10¹⁵ cm⁻³ Phosphorus (n-type) |
| P-well | Boron, 2×10¹³ cm⁻², 200 keV |
| Gate length | 180 nm (mask: left=-1, right=90 nm) |
| LDD | Arsenic, 4×10¹⁴ cm⁻², 10 keV |
| Halo | Boron quad implant, 30° tilt |
| S/D | Arsenic, 5×10¹⁵ cm⁻², 40 keV, 7° tilt |
| Final save | `struct tdr= n@node@_fps` (no reflect) |

### Process Flow

1. **2D grid initialization** — 1 nm surface spacing, relaxing to 2 µm/div at depth
2. **Boron implantations** — P-well (200 keV), retrograde punch-through stop (80 keV), Vt adjust (25 keV)
3. **Gate oxide growth** — Dry O2, 1050°C, 10 s → ~2.9 nm
4. **Polysilicon gate** — 0.18 µm deposit + anisotropic etch with gate mask
5. **Poly reoxidation** — 900°C, 10 min, O2 (stress relief before spacers)
6. **LDD + Halo implants** — Arsenic LDD + quad Boron halo with remeshing
7. **Spacer formation** — 60 nm isotropic Nitride + anisotropic etch-back
8. **Source/Drain implant** — Arsenic 5×10¹⁵ cm⁻², 40 keV, -90° rotation
9. **Contact pads** — Aluminum deposit and etch
10. **Final save** — No reflection (assignment requirement)

### Result
The saved `n@node@_fps.tdr` contains the half-cell structure. In Sentaurus Visual the Y-axis spans 0 to 0.4 µm (not mirrored), showing the gate stack centred at y=0, with drain contact at y~0.3 µm. Net doping shows N+ source/drain regions (red, ~3.27×10²⁰ cm⁻³) clearly separated by the P-type channel region (blue, ~6.88×10¹⁷ cm⁻³).

---

## Project 2 — 180 nm 2D nMOS (Full Structure + Device Characterization)

### Objective
Extend Project 1 to produce a **full symmetric device** using `transform reflect left`, then perform complete electrical characterization (I-V and C-V) using Sentaurus Device.

### What Changed from Project 1
The only process flow change is the addition of `transform reflect left` before the final struct save:

```tcl
transform reflect left
struct tdr= n@node@_NMOS !Gas
```

This mirrors the simulated half-cell about y=0, producing a complete transistor with source at y<0 and drain at y>0, visible as a symmetric structure in Sentaurus Visual (Y-axis: -0.4 to +0.4 µm).

### Device Characterization (sdevice)

The sdevice simulation runs four characterization sequences in a single file:

**Electrodes defined:**
- source (0 V reference)
- drain (swept)
- gate (swept)
- substrate (0 V, body contact)

**Simulation sequence:**

| Step | Sweep | Purpose |
|---|---|---|
| 0 | Equilibrium | Initial guess (Poisson solver) |
| 1 | Id-Vg at Vd=50 mV | Linear transfer characteristic, Vth_lin, Ioff |
| 2 | Id-Vg at Vd=1.5 V | Saturation transfer characteristic, Isat, SS |
| 3 | Id-Vd at Vg=1.0 V | Output characteristic |
| 4 | C-V: Vg = -3V to +3V | Gate capacitance vs gate voltage at 1 MHz |

**Physics models used:**
- `EffectiveIntrinsicDensity(OldSlotboom)` — bandgap narrowing
- `PhuMob` — phonon scattering mobility
- `HighFieldSaturation` + `Enormal` — velocity saturation and surface mobility
- `SRH(DopingDependence)` — recombination
- `Fermi` — Fermi-Dirac statistics

### Structures Observed

The final structure (`n@node@_fps.tdr`) viewed in Sentaurus Visual shows all material layers clearly:
- **PolySilicon** gate (red, N+ doped, ~3.27×10²⁰ cm⁻³ peak)
- **Gate oxide** (thin cyan line at Si surface)
- **Nitride spacers** (olive/yellow-green, flanking gate)
- **N+ Source/Drain** (red regions in Si)
- **P-type channel** (deep blue under gate, Boron-doped)
- **Aluminum** contact pads (gray, over S/D)
- **P-type substrate** (uniform blue, Boron ~1×10¹⁵ cm⁻³)

---

## Project 3 — Parametric 2D MOSFET (Gate Length Sweep + Full Characterization)

### Objective
Simulate a 2D nMOS for five different gate lengths (Lg = 1 µm, 0.5 µm, 0.35 µm, 0.18 µm, 0.13 µm), extract threshold voltage for each, and plot Vth vs Lg. Additionally perform full characterization of the 180 nm device.

### Design Specifications

| Parameter | Specification | Value Used |
|---|---|---|
| S/D doping | 5×10¹⁸ – 1×10²⁰ cm⁻³ | ~3.27×10²⁰ cm⁻³ peak |
| Substrate doping | 1×10¹⁶ – 1×10¹⁷ cm⁻³ | 1×10¹⁶ cm⁻³ Boron |
| S/D junction depth | 0.18 – 0.2 µm | ~0.19 µm (Arsenic 40 keV + 1050°C anneal) |
| LDD doping | 1–2 orders below S/D | ~5×10¹⁷ cm⁻³ (Arsenic 5×10¹³ dose, 10 keV) |
| Gate oxide | 8–10 nm | ~9 nm (dry O2, 850°C, 20 min) |
| Gate lengths | 1, 0.5, 0.35, 0.18, 0.13 µm | SWB parameter `@Lg@` |

### Sentaurus Workbench Setup

The parametric sweep is set up in SWB with a single parameter `Lg` defined as a **List** type:

```
Lg = 1   0.5   0.35   0.18   0.13   (um)
```

This creates 5 separate sprocess simulation instances automatically. The `@Lg@` token in the command file is replaced by SWB with each value at runtime.

The SWB project node chain is:
```
sprocess → sdevice → svisual
```

### Process Flow Summary

The process flow is identical across all Lg values except for the gate mask and poly deposition:

```tcl
deposit material= {PolySilicon} type= anisotropic time= 1 rate= {@Lg@}
mask name= gate_mask left= -1 right= @Lg@/2<um>
```

The `left= -1` shortcut (outside domain) combined with `right= @Lg@/2` protects the gate region during etch, making the gate length exactly `@Lg@` µm self-consistently for all 5 cases.

**Process steps (same for all Lg):**

| Section | Step | Parameters |
|---|---|---|
| 1 | Substrate | Boron 1×10¹⁶ cm⁻³, 10 µm deep, ±0.8 µm wide |
| 2 | Well implants | P-well 200 keV + retrograde 80 keV + Vt 25 keV |
| 3 | Gate oxide | 850°C, 20 min, dry O2 → ~9 nm |
| 4 | Gate | Poly deposit @Lg@, mask + etch |
| 5 | Reoxidation | 900°C, 10 min, O2 |
| 6 | LDD remesh | refinebox near gate edges |
| 7 | LDD + Halo | Arsenic 5×10¹³ + quad Boron halo |
| 8 | Spacers | 60 nm Nitride isotropic + etch-back |
| 9 | S/D remesh | refinebox in S/D region |
| 10 | S/D implant | Arsenic 5×10¹⁵, 40 keV, 7° tilt, 1050°C anneal |
| 11 | Contacts | Aluminum deposit + etch |
| 12 | Contact defs | substrate/source/drain/gate named contacts |
| 13 | Final save | `transform reflect left` + `struct tdr= n@node@_fps` |

### Simulated Structures

**Lg = 0.18 µm (180 nm):**
The final structure (`n3_fps`) shows a well-formed nMOS with clear N+ source and drain regions (red, peak ~3.27×10²⁰ cm⁻³) separated by a narrow P-type channel. Nitride spacers are visible flanking the poly gate. The zoomed-in view confirms the 180 nm gate length and the characteristic doping gradient from the LDD extensions into the deep S/D.

**Lg = 0.35 µm:**
The wider gate is clearly visible in the net doping plot. The LDD extension length relative to gate length is noticeably smaller compared to the 180 nm device, as expected for this node.

**Lg = 0.5 µm:**
The structure shows a more relaxed geometry. The channel region (blue) is wider and the halo implant penetration is less critical at this gate length.

**Lg = 1 µm:**
Long-channel behavior is clearly visible — the source and drain N+ regions are well-separated with a large uniform channel. Short-channel effects such as DIBL and Vth roll-off are not expected to be significant at this length.

### Device Characterization (Q5 — 180 nm nMOS)

#### a) Transfer and Output Characteristics

The sdevice simulation sweeps the gate voltage at two drain bias conditions:

- **Vd = 50 mV (linear regime):** Used to extract Vth_linear using the maximum transconductance (gm_max) method, where Vth = Vg at gm_max minus Vd/2
- **Vd = 1.5 V (saturation regime):** Used to extract Vth_sat, Isat (drain current at Vg = Vd = 1.5 V), Ioff (drain current at Vg = 0 V), and subthreshold slope

The subthreshold slope (SS) is extracted from the log(Id) vs Vg plot as:

```
SS = dVg / d(log10 Id)    [mV/decade]
```

Ideal SS at room temperature = 60 mV/decade. The simulated 180 nm device is expected to show SS in the range of 70–90 mV/decade due to short-channel effects.

#### b) Extracted Parameters

From the Id-Vg plots:

| Parameter | Extraction Method |
|---|---|
| Vth_linear | Tangent-line method on Id-Vg at Vd=50 mV |
| Vth_saturation | √Id vs Vg extrapolation at Vd=1.5 V |
| Isat | Id at Vg = Vd = 1.5 V |
| Ioff | Id at Vg = 0 V, Vd = 1.5 V |
| Subthreshold slope | Inverse slope of log(Id) vs Vg below threshold |

#### c) Gate Capacitance C-V

The C-V simulation uses AC small-signal analysis at 1 MHz, sweeping gate voltage from -3 V to +3 V with all other terminals grounded. The Cgg vs Vg curve shows three distinct regions:

- **Accumulation (Vg << Vth):** Cgg = Cox (maximum, oxide capacitance dominates)
- **Depletion (Vg near Vth):** Cgg decreases as depletion region widens
- **Inversion (Vg >> Vth):** Cgg returns toward Cox as inversion charge forms

The gate oxide capacitance per unit area: Cox = ε₀ × εox / Tox = 3.45 fF/µm² for Tox = 9 nm.

#### d) Resistive-Load Inverter VTC

The same 180 nm nMOS is used as a switch with a 1 kΩ drain resistor connected to Vdd = 1.8 V. The Voltage Transfer Characteristic (VTC) plots Vout vs Vin as the gate voltage sweeps from 0 to 1.8 V.

**Key observations vs CMOS inverter:**

| Property | Resistive-load (nMOS + R) | CMOS Inverter |
|---|---|---|
| Static power | High — resistor always draws current | Near-zero — complementary switching |
| Vout at Vin=0 (logic HIGH) | Vdd (1.8 V) when nMOS off | Vdd (ideal) |
| Vout at Vin=Vdd (logic LOW) | Depends on R vs Ron — not 0 V | ~0 V (ideal) |
| Noise margins | Asymmetric, smaller | Symmetric, maximized |
| Switching threshold | Lower than Vdd/2 | ~Vdd/2 (symmetric PMOS/NMOS) |
| Area | Resistor is large in layout | Compact (no separate resistor) |

The resistive-load inverter suffers from poor output low level (Vout_low > 0 when nMOS is on) because the voltage divider between R and the channel resistance doesn't reach ground. CMOS eliminates this by replacing the resistor with a PMOS, which has near-zero on-resistance when complementary to the NMOS switch.

---

## Assumptions

1. Isolation (STI/LOCOS) is excluded — active region only, as per the sp_3 tutorial approach.
2. Default Sentaurus Process models are used (`AdvancedCalibration` enabled) without custom calibration to specific foundry data.
3. All simulations are at room temperature (300 K).
4. The substrate is treated as ideal bulk silicon with no buried oxide or well proximity effects.
5. Contact resistance and interconnect parasitics are not modeled — metal contacts are ideal.
6. For the Lg sweep (Project 3), the same process conditions (implant energies, doses, anneal times) are used for all gate lengths. In a real design, each node would have individually optimized implant conditions.
7. The gate oxide thickness of ~9 nm used in Project 3 is intentionally conservative — a real 130 nm node would use ~2–3 nm gate oxide, but the assignment specification of 8–10 nm is followed.

---

## Tools and Environment

| Tool | Version | Purpose |
|---|---|---|
| Sentaurus Process | W-2024.09-SP1 | Fabrication simulation |
| Sentaurus Device | W-2024.09-SP1 | Electrical simulation |
| Sentaurus Visual | W-2024.09-SP1 | Visualization and plotting |
| Sentaurus Workbench | W-2024.09-SP1 | Project management and parametric sweeps |

---

## References

1. Sentaurus Process 3 — Two-Dimensional Process Simulation, TCAD Sentaurus Tutorial (sp_3.html), Synopsys Inc., 2017
2. Applications_Library/GettingStarted/sprocess/2DGS — 2D Getting Started project template
3. IIT/EICT TCAD Summer Training 2024 — Day 1–5 sample scripts (SP1–SP5)
4. S. M. Sze and K. K. Ng, *Physics of Semiconductor Devices*, 3rd ed., Wiley, 2007

---

*This work was completed as part of the Synopsys Sentaurus TCAD Summer Training Program 2026.*
*All TCAD scripts and results are original work by Kevin Jacob, ECE Dept., MBCET Trivandrum.*
