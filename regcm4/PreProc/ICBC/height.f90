      subroutine height(hp,h,t,ps,p3d,ht,im,jm,km,p,kp)
 
!  HEIGHT DETERMINES THE HEIGHT OF PRESSURE LEVELS.
!     ON INPUT:
!        H AND T ARE HEIGHT AND TEMPERATURE ON SIGMA, RESPECTIVELY.
!        PS = SURFACE PRESSURE
!        PTOP = MODEL TOP PRESSURE.
!        SIG = SIGMA LEVELS.
!        P = PRESSURE LEVELS DESIRED.
!     ON OUTPUT:
!        ALL FIELDS EXCEPT H ARE UNCHANGED.
!        H HAS HEIGHT FIELDS AT KP PRESSURE LEVELS.
!
!  FOR UPWARD EXTRAPOLATION, T IS CONSIDERED TO HAVE 0 VERITCAL DERIV.
!  FOR DOWNWARD EXTRAPOLATION, T HAS LAPSE RATE OF TLAPSE (K/KM)
!     AND EXTRAPOLATION IS DONE FROM THE LOWEST SIGMA LEVEL ABOVE
!     THE BOUNDARY LAYER (TOP ARBITRARILY TAKEN AT SIGMA = BLTOP).
!     EQUATION USED IS EXACT SOLUTION TO HYDROSTATIC RELATION,
!     GOTTEN FROM R. ERRICO (ALSO USED IN SLPRES ROUTINE):
!      Z = Z0 - (T0/TLAPSE) * (1.-EXP(-R*TLAPSE*LN(P/P0)/G))
!
      use mod_constants , only : rgti , rgas , lrate

      implicit none
!
! Dummy arguments
!
      integer :: im , jm , km , kp
      real , dimension(im,jm,km) :: h , p3d , t
      real , dimension(im,jm,kp) :: hp
      real , dimension(im,jm) :: ht , ps
      real , dimension(kp) :: p
      intent (in) h , ht , im , jm , km , kp , p , p3d , ps , t
      intent (out) hp
!
! Local variables
!
      real :: psfc , temp , wb , wt
      integer :: i , j , k , kb , kbc , kt , n
      real , dimension(61) :: psig
      real , dimension(60) :: sig
      real, parameter :: bltop = 0.96
!
      do j = 1 , jm
        do i = 1 , im
          psfc = ps(i,j)
          if ( psfc>-9995.0 ) then
            do k = 1 , km
              sig(k) = p3d(i,j,k)/ps(i,j)
              if ( sig(k)<bltop ) kbc = k
              psig(k) = p3d(i,j,k)
            end do
            do n = 1 , kp
              kt = 1
              do k = 1 , km
                if ( psig(k)<p(n) ) kt = k
              end do
              kb = kt + 1
              if ( p(n)<=psig(1) ) then
                temp = t(i,j,1)
                hp(i,j,n) = h(i,j,1) + rgas*temp*log(psig(1)/p(n))*rgti
              else if ( (p(n)>psig(1)) .and. (p(n)<psig(km)) ) then
                wt = log(psig(kb)/p(n))/log(psig(kb)/psig(kt))
                wb = log(p(n)/psig(kt))/log(psig(kb)/psig(kt))
                temp = wt*t(i,j,kt) + wb*t(i,j,kb)
                temp = (temp+t(i,j,kb))/2.
                hp(i,j,n) = h(i,j,kb) + rgas*temp*log(psig(kb)/p(n))    &
                          & *rgti
              else if ( (p(n)>=psig(km)) .and. (p(n)<=psfc) ) then
                temp = t(i,j,km)
                hp(i,j,n) = ht(i,j) + rgas*temp*log(psfc/p(n))*rgti
              else if ( p(n)>psfc ) then
                temp = t(i,j,kbc) + lrate*(h(i,j,kbc)-ht(i,j))
                hp(i,j,n) = ht(i,j) + (temp/lrate)                      &
                          & *(1.-exp(+rgas*lrate*log(p(n)/psfc)*rgti))
!
              else
              end if
            end do
          else
            do n = 1 , kp
              hp(i,j,n) = -9999.0
            end do
          end if
        end do
      end do
      end subroutine height
