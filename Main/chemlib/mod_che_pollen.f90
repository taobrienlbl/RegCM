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

module mod_che_pollen
  
  use mod_intkinds
  use mod_realkinds
  use mod_dynparam
  use mod_constants
  use mod_che_common
  use mod_che_species

  private

  ! Parameter usefull for wet and dry deposition of carbon aerosol 
  ! densities in kg/m3
  !
  real(rk8) , public , parameter:: rhopollen = 1200.0D0

  ! effctive dimaters ( and not radius!)  in micrometer
  ! ( should they be defined intercatively in the future ? ) 
  real(rk8) , public , dimension(pbin) :: pollbed

  !
  ! solubility of carbon aer for rain out param of giorgi and chameides
  !
  real(rk8) , public , dimension(pbin) :: solpollen

  data solpollen / 0.05D0, 0.05D0/
  data pollbed   /2.0D0, 20.D0/

  public :: pollen_emission
  
  contains

    subroutine pollen_emission(j, ustar, wind10, rh10, prec, convprec )
      implicit none
      integer, intent(in) :: j
      real(rk8) , dimension(ici1:ici2) , intent(in) ::ustar, wind10, rh10, prec,convprec
      real(rk8) , dimension(ici1:ici2) :: precip
      real(rk8) , dimension(ici1:ici2,pbin) :: emispol
      integer(ik4) :: i , n
      real (rk8) :: emispot, fh,fw,fr,uconv,htc,ce
            
! calculate the actual pollen flux corrected for meteo 
! receive emission potential in grain/m2/hr      
! 
      htc = d_one ! cover height 
      uconv = d_zero
      precip = (prec + convprec ) * 3600.D0 
      emispol(:,:) = d_zero
      ce = 1.D-4 ! flowering factor, a raffiner en fonction calendrier floraison

      do n = 1 , pbin
        do i = ici1 , ici2
    
          ! in particle/m2 + derniere correction
          emispot = chemsrc(j,i,ipollen(n)) * 24.D0
          if ( emispot < 1.D-20 ) cycle
          emispol(i,n) = emispot * mathpi /  &
                 6.D0 * (pollbed(n) * 1.D-06)**3  *  rhopollen   ! in kg/m2

          if (  rh10(i)*100.0D0 < 50.D0 ) then
            fh = d_one
          else if ( rh10(i)*100.0D0 > 80.D0 ) then
            fh = d_zero
          else  
            fh = (80.D0 - rh10(i)*100.0D0 )/ (80.D0 - 50.D0)  
          end if

          if (  precip(i) < 1.0D-5 ) then
            fr = d_one
          else if ( precip(i) > 0.5D0 ) then 
            fr = d_zero
          else
            fr = (0.5D0 - precip(i))/0.5D0 
          end if
          !
          ! Sofiev et al., 2006
          !
          fw = 0.5D0 + 1.0D0 * ( 1.D0 - dexp( -(wind10(i) + uconv) / 5.D0 ))
          emispol(i,n) = emispol(i,n) * ustar(i)/ htc  * ce * fh * fw * fr
        end do

        if ( ichdrdepo /= 2 ) then
          do i = ici1 , ici2
            chiten(j,i,kz,ipollen(n)) = chiten(j,i,kz,ipollen(n)) + &
               emispol(i,n)*egrav/(dsigma(kz)*1.0D3)
            ! diagnostic for source, cumul
            cemtrac(j,i,ipollen(n)) = cemtrac(j,i,ipollen(n)) + &
                    emispol(i,n)*cfdout
          end do
        else if ( ichdrdepo == 2 ) then
          do i = ici1 , ici2
            !then emission is injected in the PBL scheme
            cchifxuw(j,i,ipollen(n)) = cchifxuw(j,i,ipollen(n)) + emispol(i,n)
            ! diagnostic for source, cumul
            cemtrac(j,i,ipollen(n)) = cemtrac(j,i,ipollen(n)) + &
                    emispol(i,n)*cfdout
          end do
        end if 
      end do
    end subroutine pollen_emission
!
end module mod_che_pollen
