function pez_del(del_place,is_a_pole,weight)
%
%  pez_del() :: For deleting poles/zeros
%  for PeZ v3.1beta last Rev 9/22/97  -- No Modifications without author's consent
%  (type 'pez' in MATLAB to run)
%  Craig Ulmer / GRiMACE@ee.gatech.edu

  global  p_list z_list num_poles num_zeros num_diff_poles num_diff_zeros
    
  if is_a_pole
    a_list  = p_list;
    b_list  = z_list;
    num_a   = num_poles;
    num_b   = num_zeros;
    num_diff_a = num_diff_poles;
    num_diff_b = num_diff_zeros;
  else
    a_list  = z_list;
    b_list  = p_list;
    num_a   = num_zeros;
    num_b   = num_poles;
    num_diff_a = num_diff_zeros;
    num_diff_b = num_diff_poles;
   end;  

        del_weight=weight;
        if ( a_list(del_place,4) < del_weight )  % Pick the lesser - Weight or num there
            del_weight=a_list(del_place,4);
        end;   

      
      if   ( a_list(del_place,4)==del_weight )
          delete(a_list(del_place,3));

          if (del_weight>1)
              delete(a_list(del_place,5));
          end;    
          
          if del_place~=num_diff_a
             a_list(del_place:num_diff_a-1,:)=a_list(del_place+1:num_diff_a,:);
          end;

                         
          if (num_diff_a-1==0)
             a_list=[];
             num_diff_a=0;
             num_a=0;
          else    
             a_list=a_list(1:num_diff_a-1,:);
             num_diff_a=num_diff_a-1;
             num_a=num_a-del_weight;
          end;
      
      else
           num_a=num_a-del_weight;
           a_list(del_place,4)=a_list(del_place,4)-del_weight;
           if a_list(del_place,4)==1
               delete(a_list(del_place,5));
               a_list(del_place,5)=0; 
           else
               set(a_list(del_place,5),'string',num2str(a_list(del_place,4)) );
           end;
      end; 

  if is_a_pole
    p_list  = a_list;
    z_list  = b_list;
    num_poles   = num_a;
    num_zeros   = num_b;
    num_diff_poles = num_diff_a;
    num_diff_zeros = num_diff_b;
  else
    p_list  = b_list;
    z_list  = a_list;
    num_poles   = num_b;
    num_zeros   = num_a;
    num_diff_poles = num_diff_b;
    num_diff_zeros = num_diff_a;
  end;
  
  
