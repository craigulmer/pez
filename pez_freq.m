function hh = pez_freq(b,a,n,dum,Fs)
a = a(:).';
b = b(:).';
na = max(size(a));
nb = max(size(b));
nn = max(size(n));
%	Frequency vector specified.  Use Horner's method of polynomial
%	evaluation at the frequency points and divide the numerator
%	by the denominator.
    a = [a zeros(1,nb-na)];  % Make sure a and b have the same length
    b = [b zeros(1,na-nb)];
        w = n;
        s = exp(sqrt(-1)*w);
    h = polyval(b,s) ./ polyval(a,s);


    hh = h;
