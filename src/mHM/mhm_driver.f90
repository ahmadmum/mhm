!>       \file mhm_driver.f90

!>       \brief Distributed precipitation-runoff model mHM

!>       \details This is the main driver of mHM, which calls
!>       one instance of mHM for a multiple domains and a given period.
!>       \image html  mhm5-logo.png "Typical mHM cell"
!>       \image latex mhm5-logo.pdf "Typical mHM cell" width=10cm

!>       \authors Luis Samaniego & Rohini Kumar (UFZ)

!>       \date Jun 2018

!>       \version \htmlinclude version.txt \latexinclude version.txt

!>       \copyright (c) \f$2005 - \the\year{}\f$, Helmholtz-Zentrum fuer Umweltforschung GmbH - UFZ.
!!       All rights reserved.
!!
!!       This code is a property of:
!!
!!       ----------------------------------------------------------
!!
!!       Helmholtz-Zentrum fuer Umweltforschung GmbH - UFZ
!!       Registered Office: Leipzig
!!       Registration Office: Amtsgericht Leipzig
!!       Trade Register: Nr. B 4703
!!       Chairman of the Supervisory Board: MinDirig Wilfried Kraus
!!       Scientific Director: Prof. Dr. Georg Teutsch
!!       Administrative Director: Dr. Heike Grassmann
!!
!!       ----------------------------------------------------------
!!
!!       NEITHER UFZ NOR THE DEVELOPERS MAKES ANY WARRANTY,
!!       EXPRESS OR IMPLIED, OR ASSUMES ANY LIABILITY FOR THE USE
!!       OF THIS SOFTWARE. If software is modified to produce
!!       derivative works, such modified software should be
!!       clearly marked, so as not to confuse it with the version
!!       available from UFZ.  This code can be used for research
!!       purposes ONLY provided that the following sources are
!!       acknowledged:
!!
!!       Samaniego L., Kumar R., Attinger S. (2010): Multiscale
!!       parameter regionalization of a grid-based hydrologic
!!       model at the mesoscale.  Water Resour. Res., 46,
!!       W05523, doi:10.1029/2008WR007327.
!!
!!       Kumar, R., L. Samaniego, and S. Attinger (2013), Implications
!!       of distributed hydrologic model parameterization on water
!!       fluxes at multiple scales and locations, Water Resour. Res.,
!!       49, doi:10.1029/2012WR012195.
!!
!!       For commercial applications you have to consult the
!!       authorities of the UFZ.

! Modifications:
! Stephan Thober                Nov 2013 - added read in of latitude longitude fields
! Matthias Zink                 Mar 2013 - edited screen output for gauges added inflow gauges
! Matthias Cuntz & Juliane Mai  Mar 2014 - Likelihood Kavetski uses 2 more parameters for the
!                                          error model global_parameters -> local_parameters
! Rohini Kumar                  Apr 2014 - implementation of the mHM run on a single cell configuration
!                                          also for the routing mode.
!                                        - run mHM at the input data level i.e. L0 grid
! Rohini Kumar                  May 2014 - model run on a regular lat-lon grid or on a regular X-Y coordinate system
! Stephan Thober                May 2014 - moved read meteo forcings to mo_mhm_eval
! Matthias Cuntz & Juliane Mai  Nov 2014 - LAI input from daily, monthly or yearly files
! Matthias Zink                 Mar 2015 - added optional soil mositure read in for calibration
! Luis Samaniego                Jul 2015 - added temporal directories for optimization
! Stephan Thober                Aug 2015 - removed routing related variables
! Stephan Thober                Oct 2015 - reorganized optimization (now compatible with mRM)
! Oldrich Rakovec, Rohini Kumar Oct 2015 - added reading of domain averaged TWS and objective function 15
!                                          for simultaneous calibration based on runoff and TWS
! Rohini Kumar                  Mar 2016 - options to handle different soil databases modified MPR to included
!                                          soil horizon specific properties/parameters
! Stephan Thober                Nov 2016 - implemented adaptive timestep for routing
! Rohini Kumar                  Dec 2016 - options to read (monthly mean) LAI fields
! Robert Schweppe               Jun 2018 - refactoring and reformatting
! Maren Kaluza                  Oct 2019 - TWS to data structure
! M.C. Demirel, Simon Stisen    Jun 2020 - New Soil Moisture Process: Feddes and FC dependency on root fraction coefficient processCase(3) = 4
! Sebastian Müller              Nov 2021 - refactoring driver to use provided interfaces
PROGRAM mhm_driver
  use mo_common_mHM_mRM_variables, only: optimize
  use mo_common_mpi_tools, only: &
    mpi_tools_init, &
    mpi_tools_finalize
  use mo_mhm_cli, only: parse_command_line
  use mo_mhm_interface, only: &
    mhm_interface_init, &
    mhm_interface_run, &
    mhm_interface_run_optimization, &
    mhm_interface_finalize

  IMPLICIT NONE

  ! setup MPI if wanted (does nothing if not compiled with MPI support)
  call mpi_tools_init()

  ! parse command line arguments
  call parse_command_line()

  ! initialize mhm
  call mhm_interface_init()

  ! RUN OR OPTIMIZE
  if (optimize) then
    call mhm_interface_run_optimization()
  else
    ! single mhm run with current settings
    call mhm_interface_run()
  end if

  ! WRITE RESTART files and RUNOFF and finish
  call mhm_interface_finalize()

  ! finalize MPI (does nothing if not compiled with MPI support)
  call mpi_tools_finalize()

END PROGRAM mhm_driver
