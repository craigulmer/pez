function place = pez_hit(x,y,x_array,y_array,precision)
%
%  pez_bin() :: Bulk of decode action routines. Zscale, Add Mirrors,etc
%  for PeZ v3.0 last rev June 10,1996  -- No Modifications without author's consent
%  (type 'pez' in MATLAB to run)
%  Craig Ulmer / GRiMACE@ee.gatech.edu
%
%  place = pez_is_hit(x,y,x_array,y_array,precision)
%
%
%   Finds the first match of a co-ordinate within the given array. If
%   a precision is given, it rounds to that decimal place (ie, 1
%   rounds all values to integers, 10 rounds all values to the tenths place,
%   100 for the hundredths place.  The higher the precision, the more accurate
%   the results have to be.
%
%   Used in the PEZ system


x      =round(x*precision)/precision;
y      =round(y*precision)/precision;
x_array=round(x_array*precision)/precision;
y_array=round(y_array*precision)/precision;

place = find((1:size(x_array) )'.*(( x_array == x ) & (y_array == y )));

if size(place)<1
  place=0;        %-- if empty, return 0
else
  place=place(1); %-- otherwise return first find
end;
    