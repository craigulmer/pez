function pez_import(B,A,are_roots)
% pez_import(B,A,are_roots)
% 
%
% This function will import polynomial/root vectors into the pez interface,
% where:             B is the Zeros' vector
%                    A is the Poles' vector
%     and (optional) are_roots specifies the vector type(1=roots, 0=poly).
%
% for example:
%    pez_import(B,A)  ---> Imports polynomials
%    pez_import(B)    ---> Imports polynomial Zero vector
%    pez_import(B_root,A_root,1) --> Imports root vectors
%
% Note that importing polynomials MAY add some error due to how roots()
%      factors a polynomial(ie,  A!=roots(poly(A)) ).
%
% Craig Ulmer, Feb 25, 1996  :: grimace@ee.gatech.edu

global pez_gain;

if (nargin<1)
  help pez_import,
  return,
end;  
  
if (nargin==1), A=[]; are_roots=0; end;
if (nargin==2), are_roots=0; end;

if ~(are_roots)
   if length(B(1)), pez_gain=pez_gain*B(1); end;  %<-----Notice Gain! Is Right?

   B=roots(B); A=roots(A); 
end;

B=B(:); A=A(:);

%-- Add Zeros ----------
if length(B)
  for loops_suck=1:length(B)
      pez_add([real(B(loops_suck)) imag(B(loops_suck))],0);
  end;
end;

%-- Add Poles ----------
if length(A)
  for loops_suck=1:length(A)
      pez_add([real(A(loops_suck)) imag(A(loops_suck))],1);
  end;
end;
  
pez_plot(0);    


  
  
