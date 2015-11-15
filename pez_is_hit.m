function place = pez_is_hit(x,y,x_array,y_array,precision)
%  place = pez_is_hit(x,y,x_array,y_array,precision)
%     Craig Ulmer / 1995   ---> GRiMACE@ee.gatech.edu <---
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
    