!::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
!
!    This file is part of RegCM model.
!
!    RegCM model is free software: you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation, either version 3 of the License, or
!    (at your option) any later version.
!
!    RegCM model is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with RegCM model.  If not, see <http://www.gnu.org/licenses/>.
!
!::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
 
      subroutine dragdn
!
!     returns neutral drag coefficient for grid square
!
!     zlnd = soil roughness length
!     zoce = ocean roughness length
!     zsno = snow roughness length
!     vonkar = von karman constant
!
!     frav = fraction of grid point covered by vegetation
!     fras = fraction of grid point covered by snow
!     frab = fraction of grid point covered by bare soil
!     cdb = neutral drag coeff over bare soil, ocean, sea ice
!     cds = neutral drag coeff over snow
!     cdv = neutral drag coeff over vegetation
!     cdrn = neutral drag coeff for momentum avgd over grid point
!
      use regcm_param
      use mod_bats , only : npts , lveg , z1d , z1 , z1log , cdrn ,     &
                   & sigf , vonkar , zoce , zsno , zlnd , sice1d ,      &
                   & ldoc1d , veg1d , scvk , rough , wt , displa
      implicit none
!
! Local variables
!
      real(8) :: asigf , cdb , cds , cdv , frab , fras , frav
      integer :: n , np
!
!     ******           sea ice classified same as desert
      do np = np1 , npts
        do n = 1 , nnsg
          if ( lveg(n,np).le.0 .and. sice1d(n,np).gt.0. ) lveg(n,np) = 8
        end do
      end do
 
      call depth
 
      do np = np1 , npts
        do n = 1 , nnsg
 
          z1(n,np) = z1d(n,np)
          z1log(n,np) = dlog(z1(n,np))
 
          if ( ldoc1d(n,np).gt.0.5 ) then
 
!           ******           drag coeff over land
            frav = sigf(n,np)
            asigf = veg1d(n,np)
            fras = asigf*wt(n,np) + (1.-asigf)*scvk(n,np)
            frab = (1.-asigf)*(1.-scvk(n,np))
            cdb = (vonkar/dlog(z1(n,np)/zlnd))**2
            cds = (vonkar/dlog(z1(n,np)/zsno))**2
            cdv = (vonkar/dlog((z1(n,np)-displa(lveg(n,np)))/rough(lveg(&
                & n,np))))**2
            cdrn(n,np) = frav*cdv + frab*cdb + fras*cds
 
          else
!           ******           drag coeff over ocean
            sigf(n,np) = 0.0
            cdrn(n,np) = (vonkar/dlog(z1(n,np)/zoce))**2
          end if
        end do
      end do
 
      end subroutine dragdn
