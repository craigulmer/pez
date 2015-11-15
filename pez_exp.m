function anz=pez_exp(data_points,occs)
%
%  pez_exp() :: Routine for expanding the pez internal rep to a root list
%  for PeZ v2.8b last Rev Feb 25  -- No Modifications without author's consent
%  (type 'pez' in MATLAB to run)
%  Craig Ulmer / GRiMACE@ee.gatech.edu

%This will elaborate a list as follows
%  data_points -- a linear array of data points
%  occs -- the number of occurances there are of the corresponding data point
%  anz -- the expanded list

biggest=max(occs);
num_pts=length(data_points);

a=zeros(num_pts,biggest);
b=zeros(biggest,biggest);
e=a;
f=b;
l=a;
m=b;

a(:,1)=a(:,1)+1;
b(1,:)=1:biggest;

e(:,1)=occs;
f(1,:)=f(1,:)+1;

l(:,1)=data_points;
m(1,:)=m(1,:)+1;

c=a*b;
d=e*f;
n=l*m;

k=c<=d;

inx=find(k);

anz=n(inx);
