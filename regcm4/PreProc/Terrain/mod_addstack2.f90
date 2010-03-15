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

      module mod_addstack2
      use mod_param , only : ix , jx , nsg
      implicit none
      real(4) :: clong
      real(4) , dimension(ix,jx) :: corc , hscr1 , htsavc , sumc ,      &
                                  & wtmaxc
      real(4) , dimension(ix*nsg,jx*nsg) :: corc_s , hscr1_s ,          &
           & htsavc_s , sumc_s , wtmaxc_s
      real(4) , dimension(ix,jx,2) :: itex , land
      real(4) , dimension(ix*nsg,jx*nsg,2) :: itex_s , land_s
      integer , dimension(ix,jx) :: nsc
      integer , dimension(ix*nsg,jx*nsg) :: nsc_s
      end module mod_addstack2
