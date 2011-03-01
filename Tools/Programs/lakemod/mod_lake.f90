!::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
!
!    This file is part of ICTP RegCM.
!
!    ICTP RegCM is free software: you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation, either version 3 of the License, or
!    (at your option) any later version.
!
!    ICTP RegCM is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with ICTP RegCM.  If not, see <http://www.gnu.org/licenses/>.
!
!::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

!
!     LAKE MODEL
!
      module mod_lake

      use mod_constants
!
      private
!
      public :: initlake , lake
!
      integer , parameter :: ndpmax = 400
!
      real(8) , dimension(ndpmax) :: tprof
      integer :: idep
      real(8) :: eta
      real(8) :: hi
      real(8) :: aveice
      real(8) :: hsnow
      real(8) :: tgl
!
      real(8) , dimension(ndpmax) :: de , dnsty , tt
!
      public :: tprof , idep , aveice , hsnow , tgl
!
!     surface thickness
      real(8) , parameter :: surf = 1.0D0
!     vertical grid spacing in m
      real(8) , parameter :: dz = surf
!
      contains
!
!-----------------------------------------------------------------------
!
      subroutine initlake(depth)
      implicit none
! 
      real(8) , intent(in) :: depth
      integer :: i, j, n

      idep   = int(max(2.D0,min(depth,dble(ndpmax))))
      hi     = 0.01D0
      aveice = 0.0D0
      hsnow  = 0.0D0
      eta    = 0.5D0
      tprof(1:idep) = 6.0D0
      tprof(idep+1:ndpmax) = -1D+34

      end subroutine initlake
!
!-----------------------------------------------------------------------
!
      subroutine lake(dtlake,tl,vl,zl,ql,fsw,flw,hsen, &
                      xl,prec,evl)
! 
      implicit none
!
      real(8) :: dtlake , evl , hsen , flw , &
               & prec , ql , fsw , tl , vl , zl , xl
      intent (in) hsen , ql , tl , vl , zl
      intent (inout) evl
!
      real(8) :: ai , ea , ev , hs , ld , lu , qe , qh , tac , tk , u2
!
!***  dtlake:  time step in seconds
!***  zo:      surface roughness length
!
      real(8) , parameter :: zo = 0.001D0
      real(8) , parameter :: z2 = 2.0D0
      real(8) , parameter :: tcutoff = -0.001D0
      logical , parameter :: lfreeze = .true.
      integer , parameter :: kmin = 1
!
!     interpolate winds at z1 m to 2m via log wind profile
      u2 = vl*log(z2/zo)/log(zl/zo)
      if ( u2.lt.0.5D0 ) u2 = 0.5D0
 
!     ****** Check if conditions not exist for lake ice
      if ( (aveice.lt.1.0D-8) .and. (tprof(1).gt.tcutoff) ) then
 
        qe = -1.0D0*evl*wlhv
        qh = hsen

!       ******    Calculate eddy diffusivities
        call eddy(idep,dtlake,u2,xl,tprof)
 
!       ******    Lake temperature calc using sensible and latent heats
        call temp(idep,dtlake,fsw,flw,qe,qh,eta,tprof)
 
!       ******    Convective mixer
        call mixer(kmin,idep,tprof)

        hi     = 0.01
        evl    = 0.0D0
        aveice = 0.0D0
        hsnow  = 0.0D0

!     ****** Lake ice
      else
 
!       convert mixing ratio to air vapor pressure
        ea  = ql*88.0D0/(ep2+0.378D0*ql)
        tac = tl - tzero
        tk  = tzero + tprof(1)
        lu  = -emsw*sigm*tk**4.0D0
        ld  = flw - lu
        ev  = evl*3600.0D0        ! convert to mm/hr
        ai  = aveice / 1000.0D0   ! convert to m
        hs  = hsnow / 100.0D0     ! convert to m

        call ice(fsw,ld,tac,u2,ea,hs,hi,ai,ev,prec,tprof)
        if ( .not. lfreeze ) tprof(1) = tk - tzero

        evl    = ev/3600.0D0      ! convert evl  from mm/hr to mm/sec
        aveice = ai*1000.0D0      ! convert ice  from m to mm
        hsnow  = hs*100.0D0       ! convert snow from m depth to mm h20
 
      end if
 
      tgl = tprof(1) + tzero
 
      end subroutine lake
!
!-----------------------------------------------------------------------
!
      subroutine eddy(ndpt,dtlake,u2,xl,tprof)
 
! Computes density and eddy diffusivity
 
      implicit none
!
      integer , intent (in) :: ndpt
      real(8) , intent (in) :: dtlake , u2 , xl
      real(8) , dimension(ndpmax) , intent (in) :: tprof
!
      real(8) :: demax , demin , dpdz , ks , n2 , po
      real(8) :: zmax , rad , ri , ws , z
      integer :: k
!
!     demin molecular diffusion of heat in water
      demin = hdmw
!
!     Added to keep numerical stability of code
      demax = .50D0*dz**2.0D0/dtlake
      demax = .99D0*demax
!
      do k = 1 , ndpt
        dnsty(k) = 1000.0D0*(1.0D0-1.9549D-05 * &
                      (abs((tprof(k)+tzero)-277.0D0))**1.68D0)
      end do
! 
! Compute eddy diffusion profile
!
! Reference:
!
! B. Henderson-Sellers
!  New formulation of eddy diffusion thermocline models.
!  Appl. Math. Modelling, 1985, Vol. 9 December, pp. 441-446
!
 
!     Decay constant of shear velocity - Ekman profile parameter
      ks = 6.6D0*sqrt(sin(xl*degrad))*u2**(-1.84D0)

!     Ekman layer depth where eddy diffusion happens
      zmax = ceiling(surf+40.0D0/(vonkar*ks))

!     Surface shear velocity
      ws = 0.0012D0*u2

!     Inverse of turbulent Prandtl number
      po = 1.0D0
 
      do k = 1 , ndpt - 1

!       Actual depth from surface
        z = surf + dble(k-1)*dz
        if (z >= zmax) then
          de(k) = demin
          cycle
        end if

        if ( k == 1 ) then
          dpdz = (dnsty(k+1)-dnsty(k))/surf
        else
          dpdz = (dnsty(k+1)-dnsty(k))/dz
        end if

!       Brunt Vaisala frequency squared : we do not mind stability,
!       we just look for energy here.
!        n2 = abs((dpdz/dnsty(k))*gti)
        n2 = (dpdz/dnsty(k))*gti
        if (abs(n2) < 1.0D-30) then
          de(k) = demin
          cycle
        end if

!       Richardson number estimate
        rad = 1.0D0+40.0D0*n2*((vonkar*z)/(ws*exp(-ks*z)))**2.0D0
        if (rad < 0.0D0) rad = 0.0D0
        ri = (-1.0D0+sqrt(rad))/20.0D0

!       Total diffusion coefficient for heat: molecular + eddy (Eqn 42)
        de(k) = demin + vonkar*ws*z*po*exp(-ks*z) / &
                        (1.0D0+37.0D0*ri**2.0D0)
        if ( de(k).lt.demin ) de(k) = demin
        if ( de(k).gt.demax ) de(k) = demax

      end do
      de(ndpt) = demin
 
      end subroutine eddy
!
!-----------------------------------------------------------------------
!
      subroutine temp(ndpt,dtlake,fsw,flw,qe,qh,eta,tprof)
!
!*****************BEGIN SUBROUTINE TEMP********************
!             COMPUTES TEMPERATURE PROFILE                *
!**********************************************************
!
      implicit none
!
      integer , intent(in) :: ndpt
      real(8) , intent(in) :: dtlake , eta , flw , qe , qh , fsw
      real(8) , dimension(ndpmax) , intent(inout) :: tprof
!
      real(8) :: bot , dt1 , dt2 , top
      integer :: k
 
!******    solve differential equations of heat transfer

      tt(1:ndpt) = tprof(1:ndpt)
 
      dt1 = (fsw*(1.0D0-exp(-eta*surf))+(flw+qe+qh)) / &
              (surf*dnsty(1)*cpw)
      dt2 = -de(1)*(tprof(1)-tprof(2))/surf
      tt(1) = tt(1) + (dt1+dt2)*dtlake
 
      do k = 2 , ndpt - 1
        top = (surf+(k-2)*dz)
        bot = (surf+(k-1)*dz)
        dt1 = fsw*(exp(-eta*top)-exp(-eta*bot))/(dz*dnsty(k)*cpw)
        dt2 = (de(k-1)*(tprof(k-1)-tprof(k))    -    &
               de(k)  *(tprof(k)  -tprof(k+1))) / dz
        tt(k) = tt(k) + (dt1+dt2)*dtlake
      end do
 
      top = (surf+(ndpt-2)*dz)
      dt1 = fsw*exp(-eta*top)/(dz*dnsty(ndpt)*cpw)
      dt2 = de(ndpt-1)*(tprof(ndpt-1)-tprof(ndpt))/dz
      tt(ndpt) = tt(ndpt) + (dt1+dt2)*dtlake
 
      do k = 1 , ndpt
        tprof(k) = tt(k)
        dnsty(k) = 1000.0D0*(1.0D0-1.9549D-05 * &
                   (abs((tprof(k)+tzero)-277.0D0))**1.68D0)
      end do

      end subroutine temp
!
!-----------------------------------------------------------------------
!
      subroutine mixer(kmin,ndpt,tprof)
!
! Simulates convective mixing
!
      implicit none
!
      integer , intent(in) :: ndpt , kmin
      real(8) , intent(inout) , dimension(ndpmax) :: tprof
!
      real(8) :: avet , avev , tav , vol
      integer :: k , k2
! 
      tt(kmin:ndpt) = tprof(kmin:ndpt)
 
      do k = kmin , ndpt - 1
        avet = 0.0D0
        avev = 0.0D0
 
        if ( dnsty(k).gt.dnsty(k+1) ) then
 
          do k2 = kmin , k + 1
            if ( k2.eq.1 ) then
              vol = surf
            else
              vol = dz
            end if
            avet = avet + tt(k2)*vol
            avev = avev + vol
          end do
 
          tav = avet/avev

          do k2 = kmin , k + 1
            tt(k2) = tav
            dnsty(k2) = 1000.0D0*(1.0D0-1.9549D-05 * &
                        (abs((tav+tzero)-277.0D0))**1.68D0)
          end do
        end if
 
      end do ! K loop
 
      tprof(kmin:ndpt) = tt(kmin:ndpt)
 
      end subroutine mixer
!
!-----------------------------------------------------------------------
!
      subroutine ice(fsw,ld,tac,u2,ea,hs,hi,aveice,evl,prec,tprof)

      implicit none
      real(8) :: ea , evl , hi , aveice , hs , fsw , &
                 ld , prec , tac , u2
      real(8) , dimension(ndpmax) :: tprof
      intent (in) ea , ld , prec , tac , u2
      intent (out) evl
      intent (inout) hi , aveice , hs , fsw , tprof
!
      real(8) :: di , ds , f0 , f1 , khat , psi , q0 , qpen , t0 , t1 , &
               & t2 , tf , theta , rho
      integer :: nits
!
      real(8) , parameter :: isurf = 0.6D0
      real(8) , parameter :: lami1 = 1.5D0
      real(8) , parameter :: lami2 = 20.0D0
      real(8) , parameter :: lams1 = 6.0D0
      real(8) , parameter :: lams2 = 20.0D0
      real(8) , parameter :: ki = 2.3D0
      real(8) , parameter :: ks = 0.31D0
      real(8) , parameter :: atm = 950.0D0
      real(8) , parameter :: qw = 1.389D0
      real(8) , parameter :: li = 334.0D03
      real(8) , parameter :: cd = 0.001D0
      real(8) , parameter :: sec = 3600.0D0
!
!
!****************************SUBROUINE ICE*****************************
!     SIMULATES LAKE ICE                           
!**********************************************************************
 
      if ( (tac.le.0.0D0) .and. (aveice.gt.0.0D0) ) &
        hs = hs + prec*10.0D0/1000.0D0  ! convert prec(mm) to depth(m)
      if ( hs < 0.0D0 ) hs = 0.0D0
 
      t0 = tprof(1)
      tf = 0.0D0
      rho = rhoh2o/1000.0D0
 
      khat = (ki*hs+ks*hi)/(ki*ks)
      theta = cpd*rho*cd*u2
      psi = wlhv*rho*cd*u2*ep2/atm
      evl = 100.0D0*psi*(eomb(t0)-ea)/(wlhv*rho)
      qpen = fsw*0.7D0*((1.0D0-exp(-lams1*hs))/(ks*lams1) +            &
                        (exp(-lams1*hs))*(1.0D0-exp(-lami1*hi)) /      &
                        (ki*lami1))+fsw*0.3D0*((1.0D0-exp(-lams2)) /   &
                        (ks*lams2)+(-lams2*hs)*(1.0D0-exp(-lami2*hi))/ &
                        (ki*lami2))
      fsw = fsw - qpen
 
      nits = 0
      t1 = -50.0D0
      f0 = f(t0)
      f1 = f(t1)
      do
        nits = nits + 1
        t2 = t1 - (t1-t0)*f1/(f1-f0)
        if ( abs((t2-t1)/t1).ge.0.001D0 ) then
          t0 = t1
          t1 = t2
          f0 = f1
          f1 = f(t1)
          cycle
        end if
 
        t0 = t2
        if ( t0.ge.tf ) then
 
          if ( hs.gt.0.0D0 ) then
            ds = sec*                                        &
               & ((-ld+0.97D0*sigm*t4(tf)+psi*(eomb(tf)-ea)+ &
               &  theta*(tf-tac)-fsw)-1.0D0/khat*(t0-tf+qpen))/(rhos*li)
            if ( ds.gt.0.0D0 ) ds = 0.0D0
            hs = hs + ds
            if ( hs.lt.0.0D0 ) then
              hs = 0.0D0
              tprof(1) = (aveice*t0+(isurf-aveice)*tprof(2))/isurf
            end if
          end if
          if ( (hs.eq.0.0D0) .and. (aveice.gt.0.0D0) ) then
            di = sec*                                        &
              & ((-ld+0.97D0*sigm*t4(tf)+psi*(eomb(tf)-ea) + &
                 theta*(tf-tac)-fsw)-1.0D0/khat*(t0-tf+qpen))/(rhoi*li)
            if ( di.gt.0.0D0 ) di = 0.0D0
            hi = hi + di
          end if
 
        else if ( t0.lt.tf ) then
 
          q0 = -ld + 0.97D0*sigm*t4(t0) + psi*(eomb(t0)-ea)             &
             & + theta*(t0-tac) - fsw
          qpen = fsw*0.7D0*(1.0D0-exp(-(lams1*hs+lami1*hi))) +          &
               & fsw*0.3D0*(1.0D0-exp(-(lams2*hs+lami2*hi)))
          di = sec*(q0-qw-qpen)/(rhoi*li)
 
          hi = hi + di
        end if
 
        if ( hi.le.0.01D0 ) then
          hi = 0.01D0
          aveice = 0.0D0
          hs = 0.0D0
          tprof(1) = (hi*t0+(isurf-hi)*tprof(2))/isurf
        else
          aveice = hi
          tprof(1) = t0
        end if
        exit
      end do
 
      contains

      function t4(x)
        implicit none
        real(8) :: t4
        real(8) , intent(in) :: x
        t4 = (x+tzero)**4.0D0
      end function t4
      ! Computes air vapor pressure as a function of temp (in K)
      function tr1(x)
        implicit none
        real(8) :: tr1
        real(8) , intent(in) :: x
        tr1 = 1.0D0 - (tboil/(x+tzero))
      end function tr1
      function eomb(x)
        implicit none
        real(8) :: eomb
        real(8) , intent(in) :: x
        eomb = stdpmb*exp(13.3185D0*tr1(x)-1.976D0*tr1(x)**2.D0   &
           &   -0.6445D0*tr1(x)**3.D0- 0.1299D0*tr1(x)**4.D0)
       end function eomb
      function f(x)
        implicit none
        real(8) :: f
        real(8) , intent(in) :: x
        f = (-ld+0.97D0*sigm*t4(x)+psi*(eomb(x)-ea)+theta*(x-tac)-fsw)  &
            - 1.0D0/khat*(qpen+tf-x)
      end function f
 
      end subroutine ice
!
      end module mod_lake
