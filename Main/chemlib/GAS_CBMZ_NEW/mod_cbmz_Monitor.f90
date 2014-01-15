! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
! 
! Utility Data Module File
! 
! Generated by KPP-2.2.3 symbolic chemistry Kinetics PreProcessor
!       (http://www.cs.vt.edu/~asandu/Software/KPP)
! KPP is distributed under GPL, the general public licence
!       (http://www.gnu.org/copyleft/gpl.html)
! (C) 1995-1997, V. Damian & A. Sandu, CGRER, Univ. Iowa
! (C) 1997-2005, A. Sandu, Michigan Tech, Virginia Tech
!     With important contributions from:
!        M. Damian, Villanova University, USA
!        R. Sander, Max-Planck Institute for Chemistry, Mainz, Germany
! 
! File                 : mod_cbmz_Monitor.f90
! Time                 : Mon Nov 25 13:41:15 2013
! Working directory    : /scratch/ashalaby/kpp-2.2.3/compare/CBMZ
! Equation file        : mod_cbmz.kpp
! Output root filename : mod_cbmz
! 
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



MODULE mod_cbmz_Monitor


  CHARACTER(LEN=15), PARAMETER, DIMENSION(60) :: SPC_NAMES = (/ &
     'CO2            ','H2SO4          ','HCOOH          ', &
     'RCOOH          ','MSA            ','DUMMY          ', &
     'PAN            ','TOL            ','O1D            ', &
     'H2O2           ','SO2            ','XYL            ', &
     'CH4            ','C2H6           ','CRO            ', &
     'DMS            ','HNO4           ','H2             ', &
     'TO2            ','CH3OH          ','HNO2           ', &
     'CH3OOH         ','ETHOOH         ','N2O5           ', &
     'ETH            ','CRES           ','O3P            ', &
     'CO             ','HNO3           ','PAR            ', &
     'OPEN           ','ISOPN          ','ISOPP          ', &
     'ISOPO2         ','H2O            ','AONE           ', &
     'OLEI           ','ISOP           ','HCHO           ', &
     'OLET           ','XO2            ','MGLY           ', &
     'ETHP           ','NAP            ','ALD2           ', &
     'CH3O2          ','ISOPRD         ','ANO2           ', &
     'ROOH           ','RO2            ','ONIT           ', &
     'HO2            ','O3             ','OH             ', &
     'NO             ','NO2            ','NO3            ', &
     'C2O3           ','O2             ','N2             ' /)

  INTEGER, PARAMETER, DIMENSION(4) :: LOOKAT = (/ &
      53,39, 55, 56 /)

  INTEGER, PARAMETER, DIMENSION(2) :: MONITOR = (/ &
      55, 56 /)

  CHARACTER(LEN=15), DIMENSION(1) :: SMASS
  CHARACTER(LEN=100), PARAMETER, DIMENSION(30) :: EQN_NAMES_0 = (/ &
     '         NO2 --> O3P + NO                                                                           ', &
     '         NO3 --> 0.89 O3P + 0.11 NO + 0.89 NO2                                                      ', &
     '        HNO2 --> OH + NO                                                                            ', &
     '        HNO3 --> OH + NO2                                                                           ', &
     '        HNO4 --> HO2 + NO2                                                                          ', &
     '          O3 --> O3P                                                                                ', &
     '          O3 --> O1D                                                                                ', &
     '        H2O2 --> 2 OH                                                                               ', &
     '    O1D + O2 --> O3P + O2                                                                           ', &
     '    O1D + N2 --> O3P + N2                                                                           ', &
     '   O1D + H2O --> 2 OH                                                                               ', &
     '    O3P + O2 --> O3                                                                                 ', &
     '    O3P + O3 --> 2 O2                                                                               ', &
     '   O3P + NO2 --> NO                                                                                 ', &
     '   O3P + NO2 --> NO3                                                                                ', &
     '    O3P + NO --> NO2                                                                                ', &
     '     O3 + NO --> NO2                                                                                ', &
     '    O3 + NO2 --> NO3                                                                                ', &
     '     O3 + OH --> HO2                                                                                ', &
     '    HO2 + O3 --> OH                                                                                 ', &
     '     H2 + OH --> H2O + HO2                                                                          ', &
     '     OH + NO --> HNO2                                                                               ', &
     '    OH + NO2 --> HNO3                                                                               ', &
     '    OH + NO3 --> HO2 + NO2                                                                          ', &
     '   HNO2 + OH --> NO2                                                                                ', &
     '   HNO3 + OH --> NO3                                                                                ', &
     '   HNO4 + OH --> NO2                                                                                ', &
     '    HO2 + OH --> H2O + O2                                                                           ', &
     '   H2O2 + OH --> HO2                                                                                ', &
     '       2 HO2 --> H2O2                                                                               ' /)
  CHARACTER(LEN=100), PARAMETER, DIMENSION(30) :: EQN_NAMES_1 = (/ &
     ' H2O + 2 HO2 --> H2O2                                                                               ', &
     '    HO2 + NO --> OH + NO2                                                                           ', &
     '   HO2 + NO2 --> HNO4                                                                               ', &
     '   HO2 + NO2 --> HNO2                                                                               ', &
     '        HNO4 --> HO2 + NO2                                                                          ', &
     '    NO + NO3 --> 2 NO2                                                                              ', &
     '   NO2 + NO3 --> NO + NO2                                                                           ', &
     '   NO2 + NO3 --> N2O5                                                                               ', &
     '       2 NO3 --> 2 NO2 + O2                                                                         ', &
     '   HO2 + NO3 --> 0.3 HNO3 + 0.7 OH + 0.7 NO2                                                        ', &
     '  N2O5 + H2O --> 2 HNO3                                                                             ', &
     '        N2O5 --> NO2 + NO3                                                                          ', &
     '   2 NO + O2 --> 2 NO2                                                                              ', &
     '     CO + OH --> HO2                                                                                ', &
     '    SO2 + OH --> H2SO4 + HO2                                                                        ', &
     '    CH4 + OH --> CH3O2                                                                              ', &
     '   C2H6 + OH --> ETHP                                                                               ', &
     '    PAR + OH --> RO2                                                                                ', &
     '  CH3OH + OH --> HCHO + HO2                                                                         ', &
     '        HCHO --> CO + 2 HO2                                                                         ', &
     '        HCHO --> CO                                                                                 ', &
     '   HCHO + OH --> CO + HO2                                                                           ', &
     '  HCHO + NO3 --> CO + HNO3 + HO2                                                                    ', &
     '        ALD2 --> CO + CH3O2 + HO2                                                                   ', &
     '   ALD2 + OH --> C2O3                                                                               ', &
     '  ALD2 + NO3 --> HNO3 + C2O3                                                                        ', &
     '        AONE --> CH3O2 + C2O3                                                                       ', &
     '   AONE + OH --> ANO2                                                                               ', &
     '        MGLY --> CO + HO2 + C2O3                                                                    ', &
     '   MGLY + OH --> XO2 + C2O3                                                                         ' /)
  CHARACTER(LEN=100), PARAMETER, DIMENSION(30) :: EQN_NAMES_2 = (/ &
     '  MGLY + NO3 --> CO + HNO3 + C2O3                                                                   ', &
     '    ETH + O3 --> 0.24 CO2 + 0.52 HCOOH + 0.24 CO + HCHO + 0.2 HO2 + 0.12 OH ... etc.                ', &
     '    ETH + OH --> 1.56 HCHO + XO2 + 0.22 ALD2 + HO2                                                  ', &
     '   OLET + O3 --> 0.22 CO2 + 0.22 HCOOH + 0.09 RCOOH + 0.06 CH4 + 0.01 C2H6 ... etc.                 ', &
     '   OLEI + O3 --> 0.18 CO2 + 0.16 RCOOH + 0.08 CH4 + 0.01 C2H6 + 0.04 CH3OH ... etc.                 ', &
     '   OLET + OH --> - PAR + HCHO + XO2 + ALD2 + HO2                                                    ', &
     '   OLEI + OH --> - -2.23 PAR + 0.23 AONE + XO2 + 1.77 ALD2 + HO2                                    ', &
     '  OLET + NO3 --> NAP                                                                                ', &
     '  OLEI + NO3 --> NAP                                                                                ', &
     '    TOL + OH --> 0.8 TO2 + 0.12 CRES + 0.08 XO2 + 0.2 HO2                                           ', &
     '    XYL + OH --> 0.45 TO2 + 0.05 CRES + 1.1 PAR + 0.5 XO2 + 0.8 MGLY ... etc.                       ', &
     '    TO2 + NO --> 0.95 OPEN + 0.05 ONIT + 0.95 HO2 + 0.95 NO2                                        ', &
     '   CRES + OH --> 0.4 CRO + 0.3 OPEN + 0.6 XO2 + 0.6 HO2                                             ', &
     '  CRES + NO3 --> CRO + HNO3                                                                         ', &
     '   CRO + NO2 --> ONIT                                                                               ', &
     '   OPEN + OH --> 2 CO + HCHO + XO2 + 2 HO2 + C2O3                                                   ', &
     '        OPEN --> CO + HO2 + C2O3                                                                    ', &
     '   OPEN + O3 --> 0.69 CO + 0.7 HCHO + 0.03 XO2 + 0.2 MGLY + 0.03 ALD2 ... etc.                      ', &
     '   ISOP + OH --> ISOPP + 0.08 XO2                                                                   ', &
     '   ISOP + O3 --> 0.39 RCOOH + 0.07 CO + 0.6 HCHO + 0.2 XO2 + 0.15 ALD2 ... etc.                     ', &
     '  ISOP + NO3 --> ISOPN                                                                              ', &
     ' ISOPRD + OH --> 0.5 ISOPO2 + 0.2 XO2 + 0.5 C2O3                                                    ', &
     ' ISOPRD + O3 --> 0.46 RCOOH + 0.1 CO + 0.09 AONE + 0.15 HCHO + 0.07 XO2 ... etc.                    ', &
     '      ISOPRD --> 0.33 CO + 0.03 AONE + 0.2 HCHO + 0.07 ALD2 + 0.7 CH3O2 ... etc.                    ', &
     'ISOPRD + NO3 --> 0.64 CO + 0.07 HNO3 + 1.86 PAR + 0.28 HCHO + 0.93 XO2 ... etc.                     ', &
     '      CH3OOH --> HCHO + HO2 + OH                                                                    ', &
     '      ETHOOH --> ALD2 + HO2 + OH                                                                    ', &
     '        ROOH --> - -1.98 PAR + 0.74 AONE + 0.4 XO2 + 0.1 ETHP + 0.3 ALD2 ... etc.                   ', &
     ' CH3OOH + OH --> 0.3 HCHO + 0.7 CH3O2 + 0.3 OH                                                      ', &
     ' ETHOOH + OH --> 0.7 ETHP + 0.3 ALD2 + 0.3 OH                                                       ' /)
  CHARACTER(LEN=100), PARAMETER, DIMENSION(30) :: EQN_NAMES_3 = (/ &
     '   ROOH + OH --> 0.42 PAR + 0.19 MGLY + 0.04 ALD2 + 0.77 RO2 + 0.23 OH ... etc.                     ', &
     '   ONIT + OH --> NAP                                                                                ', &
     '        ONIT --> - -1.98 PAR + 0.74 AONE + 0.41 XO2 + 0.1 ETHP + 0.3 ALD2 ... etc.                  ', &
     '  NO2 + C2O3 --> PAN                                                                                ', &
     '         PAN --> NO2 + C2O3                                                                         ', &
     '  CH3O2 + NO --> HCHO + HO2 + NO2                                                                   ', &
     '   ETHP + NO --> ALD2 + HO2 + NO2                                                                   ', &
     '    RO2 + NO --> - -1.68 PAR + 0.62 AONE + 0.34 XO2 + 0.08 ETHP + 0.25 ALD2 ... etc.                ', &
     '   NO + C2O3 --> CO2 + CH3O2 + NO2                                                                  ', &
     '   ANO2 + NO --> HCHO + NO2 + C2O3                                                                  ', &
     '    NAP + NO --> - PAR + 0.5 HCHO + 0.5 ALD2 + 0.5 ONIT + 0.5 HO2 + 1.5 NO2 ... etc.                ', &
     '  ISOPP + NO --> 0.18 PAR + 0.63 HCHO + 0.91 ISOPRD + 0.09 ONIT + 0.91 HO2 ... etc.                 ', &
     '  ISOPN + NO --> 1.6 PAR + 0.8 ALD2 + 0.2 ISOPRD + 0.8 ONIT + 0.8 HO2 ... etc.                      ', &
     ' ISOPO2 + NO --> 0.59 CO + 0.63 AONE + 0.25 HCHO + 0.34 MGLY + 0.55 ALD2 ... etc.                   ', &
     '    XO2 + NO --> NO2                                                                                ', &
     ' CH3O2 + NO3 --> HCHO + HO2 + NO2                                                                   ', &
     '  ETHP + NO3 --> ALD2 + HO2 + NO2                                                                   ', &
     '   RO2 + NO3 --> - -1.98 PAR + 0.74 AONE + 0.4 XO2 + 0.1 ETHP + 0.3 ALD2 ... etc.                   ', &
     '  NO3 + C2O3 --> CH3O2 + NO2                                                                        ', &
     '  ANO2 + NO3 --> HCHO + NO2 + C2O3                                                                  ', &
     '   NAP + NO3 --> - PAR + 0.5 HCHO + 0.5 ALD2 + 0.5 ONIT + 0.5 HO2 + 1.5 NO2 ... etc.                ', &
     '   XO2 + NO3 --> NO2                                                                                ', &
     ' CH3O2 + HO2 --> CH3OOH                                                                             ', &
     '  ETHP + HO2 --> ETHOOH                                                                             ', &
     '   RO2 + HO2 --> ROOH                                                                               ', &
     '  HO2 + C2O3 --> 0.4 RCOOH + 0.4 O3                                                                 ', &
     '  ANO2 + HO2 --> ROOH                                                                               ', &
     '   NAP + HO2 --> ONIT                                                                               ', &
     ' ISOPP + HO2 --> ROOH                                                                               ', &
     ' ISOPN + HO2 --> 2 PAR + ONIT                                                                       ' /)
  CHARACTER(LEN=100), PARAMETER, DIMENSION(4) :: EQN_NAMES_4 = (/ &
     'ISOPO2 + HO2 --> ROOH                                                                               ', &
     '   XO2 + HO2 --> DUMMY                                                                              ', &
     '    DMS + OH --> 0.6 MSA + 0.4 SO2                                                                  ', &
     '   DMS + NO3 --> SO2 + HNO3                                                                         ' /)
  CHARACTER(LEN=100), PARAMETER, DIMENSION(124) :: EQN_NAMES = (/&
    EQN_NAMES_0, EQN_NAMES_1, EQN_NAMES_2, EQN_NAMES_3, EQN_NAMES_4 /)

! INLINED global variables

! End INLINED global variables


END MODULE mod_cbmz_Monitor
