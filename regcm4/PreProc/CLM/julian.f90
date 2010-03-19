      subroutine julian(idate,julnc,iyr,imo,idy,ihr,xhr)
 
      implicit none
!
! Dummy arguments
!
      integer :: idate , idy , ihr , imo , iyr , julnc
      real(8) :: xhr
      intent (out) xhr
      intent (inout) idate , idy , ihr , imo , iyr , julnc
!
! Local variables
!
      integer :: ileap , iyrm1 , j , julday
      integer , dimension(12) :: jprev , lenmon
!
      data lenmon/31 , 28 , 31 , 30 , 31 , 30 , 31 , 31 , 30 , 31 , 30 ,&
         & 31/
 
      iyr = idate/1000000
      imo = idate/10000 - iyr*100
      idy = idate/100 - iyr*10000 - imo*100
      ihr = idate - idate/100*100
      ileap = mod(iyr,4)
      if ( ileap==0 ) then
        lenmon(2) = 29
      else
        lenmon(2) = 28
      end if
 
      if ( ihr>23 ) then
        ihr = ihr - 24
        idy = idy + 1
      end if
      if ( idy>lenmon(imo) ) then
        idy = 1
        imo = imo + 1
      end if
      if ( imo>12 ) then
        imo = 1
        iyr = iyr + 1
      end if
      idate = iyr*1000000 + imo*10000 + idy*100 + ihr
 
      iyrm1 = iyr - 1
 
 
      jprev(1) = 0
      do j = 2 , 12
        jprev(j) = jprev(j-1) + lenmon(j-1)
      end do
 
      julday = idy + jprev(imo) - 1
 
      julnc = ((iyr-1900)*365+julday+int((iyrm1-1900)/4))*24 + ihr
      xhr = float(julnc)
 
      end subroutine julian
