function getcarnum,nframes
ndigitmx = floor( alog10( 99999 ) ) + 1
car = strarr(nframes)
for i = 0, nframes-1 do begin
       a = string(i)
       if (i gt 0) then $
         ndigit =  floor( alog10( float(i) ) ) + 1 $
       else $
          ndigit = 1 
       for j = 1, ndigitmx - ndigit do begin
           a = '0' + a
       endfor         
       car(i) = strcompress(a, /remove_all)
endfor
return,car
end

pro rd_data,hydro,file=file,ncpu=ncpu

if not keyword_set(file) then file='output_00000'
if not keyword_set(ncpu) then ncpu=1

charpe=getcarnum(ncpu)
; Read file
for icpu=0L,ncpu-1L do begin
    file0=file+'.'+charpe(icpu)
    openr,1,file0,/f77_unformatted
    readu,1,time,gamma
    print,'Found gamma=',gamma
    print,'Found time=',time
    n1=0L
    n2=0L
    n3=0L
    nstep=0L
    readu,1,n1,n2,n3,nstep
    print,'Found step=',nstep
    print,'Found mesh size=',n1,n2
    print,'Found variables=',n3
    u1=fltarr(n1,n2,n3)
    if(icpu eq 0L)then begin
        utot=fltarr(n1,n2*ncpu,n3)
    endif
    readu,1,u1
    close,1
    utot(0:n1-1,icpu*n2:(icpu+1L)*n2-1L,0:n3-1)=u1
endfor

; Convert to primitive variables
d=utot(*,*,0)
u=utot(*,*,1)/d
v=utot(*,*,2)/d
eken=0.5d0*(u*u+v*v)
p=(gamma-1.0d0)*(utot(*,*,3)-d*eken)
eken=0.

; Save to structure
hydro={time:time, nstep:nstep, gamma:gamma, n1:n1, n2:n2, d:d, u:u, v:v, p:p}

end

pro map2mov,imin,imax,colt=colt,min=min,max=max

  if not keyword_set(colt) then colt=33
  loadct,colt
  tvlct,r,g,b,/get

  car=getcarnum(5000)

  if not keyword_set(min)then min=0.001
  if not keyword_set(max)then max=10.

  for i=imin,imax do begin
     print,'====',i
     rd_data,h,file='output_'+car(i)
     print,min(h.d),max(h.d)
     dd=h.d
     dd(0,0)=min
     dd(0,1)=max
     image=bytscl(alog10(dd),min=alog10(min),max=alog10(max))
     write_png,'dens_'+car(i)+'.png',image,r,g,b
  endfor

end
