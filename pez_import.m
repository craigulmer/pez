function pez_import(B,A,GAIN,are_roots)
% pez_import(B,A,GAIN,are_roots)
% 
%
% This function will import polynomial/root vectors into the pez interface,
% where:             B is the Zeros' vector
%                    A is the Poles' vector
%     and (optional) are_roots specifies the vector type(1=roots, 0=poly).
%
% for example:
%    pez_import(B,A)  ---> Imports polynomials, gain of B(1)
%    pez_import(B)    ---> Imports polynomial Zero vector, gain of B(1)
%    pez_import(B,A,5) --> Import with a gain of 5(Ignores B(1) )
%    pez_import(B_root,A_root,8,1) --> Imports root vectors,gain of 8
%
% Note that importing polynomials MAY add some error due to how roots()
%      factors a polynomial(ie,  A!=roots(poly(A)) ).
%
% Craig Ulmer, Feb 25, 1996  :: grimace@ee.gatech.edu

global pez_gain pez_gain_ed pez_gain_sli w_main_win;

if (nargin<1)
  help pez_import,
  return,
end;  

if ( (exist('w_main_win')~=1) | ~find(get(0,'children')==w_main_win) )
    %No pez running, crank a new one up
    pez;
end;
  
if (nargin==1), A=[]; end;
if (nargin<3), GAIN=1; end;
if (nargin<4), are_roots=0; end;


if ~(are_roots)
   if length(B(1)), 
      if (GAIN==1), pez_gain=pez_gain*B(1); 
      else,         pez_gain=pez_gain*GAIN; end;
      set(pez_gain_ed,'string',num2str(pez_gain) );
      set(pez_gain_sli,'val',pez_gain);      
    end; 
    B=roots(B); A=roots(A); 
else
    if ( GAIN~=1 )
      pez_gain=pez_gain*GAIN;
      set(pez_gain_ed,'string',num2str(pez_gain) );
      set(pez_gain_sli,'val',pez_gain);      
    end;    
end;

B=B(:); A=A(:);

%-- Add Zeros ----------
if length(B)
  for loops_suck=1:length(B)
      pez_add([real(B(loops_suck)) imag(B(loops_suck))],0,1);
  end;
end;

%-- Add Poles ----------
if length(A)
  for loops_suck=1:length(A)
      pez_add([real(A(loops_suck)) imag(A(loops_suck))],1,1);
  end;
end;
  
pez_plot(0);    


  
  
