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

module mod_interp
!
  use mod_realkinds
  use mod_constants
!
  private
!
  public :: interp , filter1plakes
!
  real(dp) , dimension(4,4) :: c
  real(dp) , dimension(16,16) :: wt
  integer , parameter :: maxbins = 20
  integer , dimension(maxbins) :: bincnt
  real(dp) , dimension(maxbins) :: bmindist
  logical , dimension(2,maxbins) :: lndwt
!
  data wt/1.0D0 , 0.0D0 , -3.0D0 , 2.0D0 , 4*0.0D0 , -3.0D0 ,   &
          0.0D0 , 9.0D0 , -6.0D0 , 2.0D0 , 0.0D0 , -6.0D0 ,     &
          4.0D0 , 8*0.0D0 , 3.0D0 , 0.0D0 , -9.0D0 , 6.0D0 ,    &
         -2.0D0 , 0.0D0 , 6.0D0 , -4.0D0 , 10*0.0D0 , 9.0D0 ,   &
         -6.0D0 , 2*0.0D0 , -6.0D0 , 4.0D0 , 2*0.0D0 , 3.0D0 ,  &
         -2.0D0 , 6*0.0D0 , -9.0D0 , 6.0D0 , 2*0.0D0 , 6.0D0 ,  &
         -4.0D0 , 4*0.0D0 , 1.0D0 , 0.0D0 , -3.0D0 , 2.0D0 ,    &
         -2.0D0 , 0.0D0 , 6.0D0 , -4.0D0 , 1.0D0 , 0.0D0 ,      &
         -3.0D0 , 2.0D0 , 8*0.0D0 , -1.0D0 , 0.0D0 , 3.0D0 ,    &
         -2.0D0 , 1.0D0 , 0.0D0 , -3.0D0 , 2.0D0 , 10*0.0D0 ,   &
         -3.0D0 , 2.0D0 , 2*0.0D0 , 3.0D0 , -2.0D0 , 6*0.0D0 ,  &
          3.0D0 , -2.0D0 , 2*0.0D0 , -6.0D0 , 4.0D0 , 2*0.0D0 , &
          3.0D0 , -2.0D0 , 0.0D0 , 1.0D0 , -2.0D0 , 1.0D0 ,     &
          5*0.0D0 , -3.0D0 , 6.0D0 , -3.0D0 , 0.0D0 , 2.0D0 ,   &
         -4.0D0 , 2.0D0 , 9*0.0D0 , 3.0D0 , -6.0D0 , 3.0D0 ,    &
          0.0D0 , -2.0D0 , 4.0D0 , -2.0D0 , 10*0.0D0 , -3.0D0 , &
          3.0D0 , 2*0.0D0 , 2.0D0 , -2.0D0 , 2*0.0D0 , -1.0D0 , &
          1.0D0 , 6*0.0D0 , 3.0D0 , -3.0D0 , 2*0.0D0 , -2.0D0 , &
          2.0D0 , 5*0.0D0 , 1.0D0 , -2.0D0 , 1.0D0 , 0.0D0 ,    &
         -2.0D0 , 4.0D0 , -2.0D0 , 0.0D0 , 1.0D0 , -2.0D0 ,     &
          1.0D0 , 9*0.0D0 , -1.0D0 , 2.0D0 , -1.0D0 , 0.0D0 ,   &
          1.0D0 , -2.0D0 , 1.0D0 , 10*0.0D0 , 1.0D0 , -1.0D0 ,  &
          2*0.0D0 , -1.0D0 , 1.0D0 , 6*0.0D0 , -1.0D0 , 1.0D0 , &
          2*0.0D0 , 2.0D0 , -2.0D0 , 2*0.0D0 , -1.0D0 , 1.0D0/
!
   data lndwt /26*.false.,.true.,.true.,.true.,11*.false./
!
  contains
!
  function inear(x,m,lwrap)
  implicit none
  integer :: inear
  real(dp) , intent(in) :: x
  integer , intent(in) :: m
  logical , intent(in) :: lwrap
  if (.not. lwrap) then
    inear = min(max(nint(x),1),m)
  else
    inear = nint(x)
    if (inear < 1) then
      inear = m - inear
    end if
    if (inear > m) then
      inear = inear - m
    end if
  end if
  end function inear
!
  function jnear(y,n)
  implicit none
  integer :: jnear
  real(dp) , intent(in) :: y
  integer , intent(in) :: n
  jnear = min(max(nint(y),1),n)
  end function jnear
!
  function ifloor(x,m,lwrap)
  implicit none
  integer :: ifloor
  real(dp) , intent(in) :: x
  integer , intent(in) :: m
  logical , intent(in) :: lwrap
  if (.not. lwrap) then
    ifloor = min(max(floor(x),1),m)
  else
    ifloor = floor(x)
    if (ifloor < 1) then
      ifloor = m - ifloor
    end if
    if (ifloor > m) then
      ifloor = ifloor - m
    end if
  end if
  end function ifloor
!
  function jfloor(y,n)
  implicit none
  integer :: jfloor
  real(dp) , intent(in) :: y
  integer , intent(in) :: n
  jfloor = min(max(floor(y),1),n)
  end function jfloor
!
  function nearpoint(x,y,m,n,grid,lwrap)
  implicit none
  real(dp) :: nearpoint
  integer :: m , n
  real(dp) :: x , y
  logical :: lwrap
  real(sp) , dimension(m,n) :: grid
  intent (in) lwrap , m , n , grid , x , y
  nearpoint = dble(grid(inear(x,m,lwrap),jnear(y,n)))
  end function nearpoint
!
  function mostaround(x,y,m,n,grid,nbox,ibnty,h2opct,lwrap)
  implicit none
  real(dp) :: mostaround
  integer , intent(in) :: m , n , nbox , ibnty
  real(dp) , intent(in) :: x , y
  logical , intent(in) :: lwrap
  real(sp) , intent(in) , dimension(m,n) :: grid
  real(dp) , intent(in) :: h2opct
!
  real(dp) , dimension(nbox*nbox) :: binval , bindist
  real(dp) :: dist , rx , ry , wtp
  integer :: ii0 , jj0 , ii , jj
  integer :: totpoints , i , j , lastc , hbox

  hbox = nbox / 2
  totpoints = nbox*nbox
  ii0 = ifloor(x,m,lwrap)-hbox
  jj0 = jfloor(y,n)-hbox
  do i = 1 , nbox
    do j = 1 , nbox
      rx = dble(ii0 + i - 1)
      ry = dble(jj0 + j - 1)
      ii = ifloor(rx,m,lwrap)
      jj = jfloor(ry,n)
      binval((i-1)*nbox+j) = dble(grid(ii,jj))
      bindist((i-1)*nbox+j) = sqrt((x-rx)**2+(y-ry)**2)
    end do
  end do
  bincnt = 0
  bmindist = d_two*dble(nbox)
  do i = 1 , totpoints
    bincnt(int(binval(i))) = bincnt(int(binval(i))) + 1
    if (bindist(i) < bmindist(int(binval(i)))) &
      bmindist(int(binval(i))) = bindist(i)
  end do
!     Set point to land if less than fixed percent of water
  wtp = (dble(sum(bincnt,mask=lndwt(ibnty,:)))/dble(totpoints))*d_100
  if (wtp > d_zero .and. wtp < 100.0D0-h2opct) then
    if (ibnty == 1) then
      bincnt(14) = 0
      bincnt(15) = 0
    else
      bincnt(15) = 0
    end if
  end if
  mostaround = -d_one
  lastc = -1
  do i = 1 , maxbins
    if (bincnt(i) > 0) then
      if (bincnt(i) > lastc) then
        mostaround = dble(i)
        dist = bmindist(i)
        lastc = bincnt(i)
      else if (bincnt(i) == lastc) then
        if (bmindist(i) < dist) then
          mostaround = dble(i)
          dist = bmindist(i)
          lastc = bincnt(i)
        end if
      end if
    end if
  end do
  end function mostaround
!
  function pctaround(x,y,m,n,grid,nbox,ival,lwrap)
  implicit none
  real(dp) :: pctaround
  integer :: m , n , ival , nbox
  real(dp) :: x , y , rx , ry
  logical :: lwrap
  real(sp) , dimension(m,n) :: grid
  intent (in) lwrap , m , n , grid , x , y , ival
!
  integer :: ii0 , jj0 , ii , jj
  integer :: i , j
  real(dp) :: pc

  pctaround = d_zero
  pc = dble(nbox*nbox)
  ii0 = ifloor(x,m,lwrap)
  jj0 = jfloor(y,n)
  do i = 1 , nbox
    do j = 1 , nbox
      rx = dble(ii0 + i - nbox/2)
      ry = dble(jj0 + j - nbox/2)
      ii = ifloor(rx,m,lwrap)
      jj = jfloor(ry,n)
      if (int(grid(ii,jj)) == ival) then
        pctaround = pctaround + 1
      end if
    end do
  end do
  pctaround = (pctaround / pc) * d_100
  end function pctaround
!
  function bilinear(x,y,m,n,grid,lwrap)

  implicit none
!
  real(dp) :: bilinear
  integer :: m , n
  real(dp) :: x , y
  logical :: lwrap
  real(sp) , dimension(m,n) :: grid
  intent (in) lwrap , m , n , grid , x , y
!
  real(dp) :: dx, dy, p12, p03
  real(dp) :: ii0, jj0, ii1, jj1, ii2, jj2, ii3, jj3
  integer :: i0, j0, i1, j1, i2, j2, i3, j3
!
!-----bilinear interpolation among four grid values
!
  if (.not. lwrap) then
    ii0 = dble(min(max(floor(x),1),m))
    ii2 = dble(min(max(ceiling(x),1),m))
    dx = (x-ii0)
  else
    ii0 = dble(floor(x))
    ii2 = dble(ceiling(x))
    dx = (x-ii0)
    if (ii0 < 1) then
      ii0 = dble(m)
    end if
    if (ii2 > m) then
      ii2 = d_one
    end if
  end if
  ii1 = ii0
  ii3 = ii2
  jj0 = dble(min(max(floor(y),1),n))
  dy = (y-jj0)
  jj3 = jj0
  jj1 = dble(min(max(ceiling(y),1),n))
  jj2 = jj1

  i0 = int(ii0)
  j0 = int(jj0)
  i1 = int(ii1)
  j1 = int(jj1)
  i2 = int(ii2)
  j2 = int(jj2)
  i3 = int(ii3)
  j3 = int(jj3)

  p12 = dx*grid(i2,j2)+(1-dx)*grid(i1,j1)
  p03 = dx*grid(i3,j3)+(1-dx)*grid(i0,j0)
  bilinear = dy*p12+(1-dy)*p03

  end function bilinear
!
  function bicubic(x,y,m,n,grid,lwrap)
 
  implicit none
!
  real(dp) :: bicubic
  integer :: m , n
  real(dp) :: x , y
  logical :: lwrap
  real(sp) , dimension(m,n) :: grid
  intent (in) grid , m , n , x , y , lwrap
!
  real(dp) , dimension(4) :: f , f1 , f12 , f2
  real(dp) :: xl , xu , yl , yu
  integer :: i , ii , j , mm , nn , im , imp1 , imn1

  mm = int(x)
  nn = int(y)
  if ( .not. lwrap) then
    mm = max(2, min(m-2,mm))
  end if
  nn = max(2, min(n-2,nn))

  xl = dble(mm)
  xu = dble(mm + 1)
  yl = dble(nn)
  yu = dble(nn + 1)
  do j = nn , nn + 1
    do i = mm , mm + 1
      ii = 1 + (i-mm) + 3*(j-nn)
      if ( ii==5 ) ii = 3
      if (lwrap) then
        im = i
        imp1 = i+1
        imn1 = i-1
        if ( i < 1 ) im = m-i
        if ( i > m ) im = i-m
        if ( imp1 < 1 ) imp1 = m-i+1
        if ( imp1 > m ) imp1 = i+1-m
        if ( imn1 < 1 ) imn1 = m-i-1
        if ( imn1 > m ) imn1 = i-1-m
      else
        im = i
        imp1 = i+1
        imn1 = i-1
      end if
      f(ii) = dble(grid(im,j))
      f1(ii) = dble((grid(imp1,j)-grid(imn1,j)))/(d_two)
      f2(ii) = dble((grid(im,j+1)-grid(im,j-1)))/(d_two)
      f12(ii) = dble((grid(imp1,j+1)-grid(imp1,j-1)-&
                      grid(imn1,j+1)+grid(imn1,j-1)))/(d_four)
    end do
  end do
 
  call bcuint(f,f1,f2,f12,xl,xu,yl,yu,x,y,bicubic)
 
  end function bicubic
!
  subroutine bcuint(y,y1,y2,y12,x1l,x1u,x2l,x2u,x1,x2,a)
  implicit none
!
  real(dp) :: a , x1 , x1l , x1u , x2 , x2l , x2u
  real(dp) , dimension(4) :: y , y1 , y12 , y2
  intent (in) x1 , x1l , x1u , x2 , x2l , x2u , y , y1 , y12 , y2
  intent (out) a
!
  integer :: i
  real(dp) :: t , u
!
  call bcucof(y,y1,y2,y12,x1u-x1l,x2u-x2l)
  t = (x1-x1l)/(x1u-x1l)
  u = (x2-x2l)/(x2u-x2l)
  a = d_zero
  do i = 4 , 1 , -1
    a = t*a + ((c(i,4)*u+c(i,3))*u+c(i,2))*u + c(i,1)
  end do
  end subroutine bcuint
!
  subroutine bcucof(y,y1,y2,y12,d1,d2)
  implicit none
!
  real(dp) :: d1 , d2
  real(dp) , dimension(4) :: y , y1 , y12 , y2
  intent (in) d1 , d2 , y , y1 , y12 , y2
!
  real(dp) , dimension(16) :: cl , x
  real(dp) :: d1d2 , xx
  integer :: i , j , k , l

  d1d2 = d1*d2
  do i = 1 , 4
    x(i) = y(i)
    x(i+4) = y1(i)*d1
    x(i+8) = y2(i)*d2
    x(i+12) = y12(i)*d1d2
  end do
  do i = 1 , 16
    xx = d_zero
    do k = 1 , 16
      xx = xx + wt(i,k)*x(k)
    end do
    cl(i) = xx
  end do
  l = 0
  do i = 1 , 4
    do j = 1 , 4
      l = l + 1
      c(i,j) = cl(l)
    end do
  end do
  end subroutine bcucof
!
! Interpolates input regolar lat/lon grid on output model grid
!
  subroutine interp(iy,jx,xlat,xlon,omt,iniy,injx,milat,milon,imt, &
                    ntypec,itype,lwrap,lcross,ival,ibnty,h2opct)
 
  use mod_stdio
  use mod_message

  implicit none
!
  integer , intent(in) :: iy , jx , iniy , injx , ntypec , itype
  real(sp) , intent(in) , dimension(iy, jx) :: xlat , xlon
  real(sp) , intent(in) , dimension(injx, iniy) :: imt
  real(dp) , intent(in) :: milat , milon
  logical , intent(in) :: lwrap , lcross
  integer , intent(in) , optional :: ival
  integer , intent(in) , optional :: ibnty
  real(dp) , intent(in) , optional :: h2opct
  real(sp) , intent(out) , dimension(iy, jx) :: omt
!
  integer :: nbox , ii , jj
  real(dp) :: xx , yy , rinc
!
  rinc = 60.0D0/dble(ntypec)
!
  if (itype < 1 .or. itype > 5) then
    write(stderr,*) 'Unknown interpolation type'
    call die('interp')
  end if
!
  do ii = 1 , iy
    do jj = 1 , jx
      yy = (dble(xlat(ii,jj))-milat)*rinc + d_one
      if (lcross) then
        xx = (mod((dble(xlon(ii,jj))+deg360),deg360)-milon) * &
              rinc + d_one
      else
        xx = (dble(xlon(ii,jj))-milon)*rinc + d_one
      end if
 
!     yy and xx are the exact index values of a point i,j of the
!     mesoscale mesh when projected onto an earth-grid of lat_s
!     and lon_s for which terrain observations are available.  it
!     is assumed that the earth grid has equal spacing in both
!     latitude and longitude.

      select case (itype)
        case(1)
          omt(ii,jj) = real(bilinear(xx,yy,injx,iniy,imt,lwrap))
        case(2)
          omt(ii,jj) = real(bicubic(xx,yy,injx,iniy,imt,lwrap))
        case(3)
          omt(ii,jj) = real(nearpoint(xx,yy,injx,iniy,imt,lwrap))
        case(4,5)
          if (lwrap) then
            if (ii == 1 .or. ii == iy ) then 
              omt(ii,jj) = real(nearpoint(xx,yy,injx,iniy,imt,lwrap))
              cycle
            else
              if (jj == jx) then
                nbox = nint(max(abs(xlon(ii,jx-1)-(xlon(ii,1)+ &
                            real(deg360)))*real(rinc)/2.0, 2.0))
                nbox = min(nbox,8)
              else if (jj == 1) then
                nbox = nint(max(abs(xlon(ii,2)-(xlon(ii,jx)- &
                            real(deg360)))*real(rinc)/2.0, 2.0))
                nbox = min(nbox,8)
              else
                nbox = nint(max(abs(xlon(ii,jj-1)-xlon(ii,jj+1))* &
                            real(rinc)/2.0, 2.0))
                nbox = min(nbox,8)
              end if
              nbox = nint(max(abs(xlat(ii-1,jj)-xlat(ii+1,jj))* &
                          real(rinc)/2.0, real(nbox)))
            end if
          else
            if (ii == 1 .or. jj == 1 .or. ii == iy .or. jj == jx) then
              omt(ii,jj) = real(nearpoint(xx,yy,injx,iniy,imt,lwrap))
              cycle
            else
              nbox = nint(max(abs(xlon(ii,jj-1)-xlon(ii,jj+1))* &
                          real(rinc)/2.0, 2.0))
              nbox = nint(max(abs(xlat(ii-1,jj)-xlat(ii+1,jj))* &
                          real(rinc)/2.0, real(nbox)))
            end if
          end if
          nbox = nbox * nint(abs(cos(xlat(ii,jj)*degrad))) + 1
          if (nbox < 2.0) then
            omt(ii,jj) = real(nearpoint(xx,yy,injx,iniy,imt,lwrap))
          else
            nbox = (nbox / 2) * 2
            if (itype == 4) then
              omt(ii,jj) = real(mostaround(xx,yy,injx,iniy,imt,nbox, &
                                      ibnty,h2opct,lwrap))
            else
              omt(ii,jj) = real(pctaround(xx,yy,injx,iniy,imt, &
                                     nbox,ival,lwrap))
            end if
          end if
      end select

    end do
  end do

  end subroutine interp

  subroutine filter1plakes(iy,jx,omt)
    implicit none
    integer , intent(in) :: iy , jx
    real(sp) , intent(out) , dimension(iy, jx) :: omt
    integer , dimension(maxbins) :: cnt
    integer , dimension(9) :: around
    integer , parameter :: ilake = 14
    integer , parameter :: iocn = 15
    integer , parameter :: minlak = 2*ilake
    integer :: i , j , ii , jj , ip , jp , k , mpindex

    do i = 1 , iy
      do j = 1 , jx
        if (int(omt(i,j)) == ilake) then
          k = 1
          do ii = -1 , 1 , 1
            do jj = -1 , 1 , 1
              ip = max(min(i+ii,iy),1)
              jp = max(min(j+jj,jx),1)
              around(k) = int(omt(ip,jp))
              k = k + 1
            end do
          end do
          if (sum(around, around==ilake) .lt. minlak) then
            do k = 1 , maxbins
              cnt(k) = sum(around/k,around==k)
            end do
            mpindex = 0
            do k = 1 , maxbins
              if (k == ilake) cycle
              if (k == iocn) cycle
              if (cnt(k) > mpindex) mpindex = k
            end do
            if (mpindex == 0) mpindex = iocn
            omt(i,j) = real(mpindex)
          end if
        end if
      end do
    end do
  end subroutine filter1plakes
!
end module mod_interp
