      subroutine normer(xlon,xlat,xmap,coriol,iy,jx,clon,clat,delx,idot)
      implicit none
!
! Dummy arguments
!
      real(4) :: clat , clon , delx
      integer :: idot , iy , jx
      real(4) , dimension(iy,jx) :: coriol , xlat , xlon , xmap
      intent (in) clat , clon , delx , idot , iy , jx
      intent (out) coriol , xlon , xmap
      intent (inout) xlat
!
! Local variables
!
      real(4) :: aa , c2 , cell , cntri , cntrj , d2r , deglat , phi1 , &
               & phictr , pi , pole , x , xcntr , xomega , xomega2 , y ,&
               & ycntr
      integer :: i , ii1 , j , jj1
!
!     COMPUTE LATS, LONS, AND MAP-SCALE FACTORS FOR
!     LAMBERT CONFORMAL MAP CENTERED AT CLON,CLAT. TRUE AT 30.N AND
!     60.N. IY IS NUMBER OF N-S POINTS.  JX IS NUMBER OF E-W POINTS.
!     CLON, CLAT IS LAT, LON OF CENTER OF GRID (DEGREES EAST, NORTH).
!     DELX IS GRID SPACING IN METERS.
!     ALWAYS FOR CROSS GRID.
 
      xomega = 7.2722E-5                     ! ANG. ROT OF EARTH IN S**-1
      aa = 6.371229E6
      pi = atan(1.)*4.
      d2r = atan(1.)/45.                     ! CONVERT DEGREES TO RADIANS
      pole = 90.
      cntrj = (jx+idot)/2.
      cntri = (iy+idot)/2.
      if ( clat<0.0 ) pole = -90.0
!
!     FOR MERCATOR PROJECTION TRUE AT PHI1
!
      phi1 = 0.
      phi1 = phi1*d2r
      c2 = aa*cos(phi1)
      xcntr = 0.
      phictr = clat*d2r
      cell = cos(phictr)/(1.+sin(phictr))
      ycntr = -c2*log(cell)
!
      ii1 = iy
      jj1 = jx
      do i = 1 , ii1
        y = ycntr + (i-cntri)*delx
        do j = 1 , jj1
          x = xcntr + (j-cntrj)*delx
!
!         CALCULATIONS FOR MERCATOR
!
          xlon(i,j) = clon + ((x-xcntr)/c2)/d2r
          cell = exp(y/c2)
          xlat(i,j) = 2.*(atan(cell)/d2r) - 90.
          deglat = xlat(i,j)*d2r
          xmap(i,j) = cos(phi1)/cos(deglat)
        end do
      end do
 
      if ( idot==1 ) then
        xomega2 = 2.*xomega
        do i = 1 , iy
          do j = 1 , jx
            coriol(i,j) = xomega2*sin(xlat(i,j)*d2r)
          end do
        end do
      end if
 
      end subroutine normer
