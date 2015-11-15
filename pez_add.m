function pez_add(new,is_a_pole,weight)
%
%  pez_add(cartesian,is_a_pole) :: Root routine for pole or zero add
%  for PeZ v3.0 last Rev June 10,1996  -- No Modifications without author's consent
%  (type 'pez' in MATLAB to run)
%  Craig Ulmer / GRiMACE@ee.gatech.edu

   global pez_precision pez_fuz axes_zplane p_list z_list num_poles num_zeros num_diff_poles num_diff_zeros
   global w_main_win
 
   if is_a_pole
      a_list=p_list;
      b_list=z_list;
      num_a = num_poles;
      num_b = num_zeros;
      num_diff_a=num_diff_poles;
      num_diff_b=num_diff_zeros;
   else
      a_list=z_list;
      b_list=p_list;
      num_a = num_zeros;
      num_b = num_poles;
      num_diff_a=num_diff_zeros;
      num_diff_b=num_diff_poles;
   end;   
      

         axes(axes_zplane);
         
         place=0;
          
         if num_a   
           place=pez_hit(new(1),new(2),a_list(:,1),a_list(:,2),pez_precision);
         end;   
         
         t_weight=weight;
         num_a=num_a+t_weight;  % -- add weight
         
         if num_b
           warn=pez_hit(new(1),new(2),b_list(:,1),b_list(:,2),pez_precision);
           if (warn~=0)
                % -- There is already a ZERO here, we have a CONTEST
                % -- We know that there could not be a POLE here
                if b_list(warn,4) <= t_weight
                         % -- we know there were multi zeros, but fewer than new additions
                         t_weight=t_weight-b_list(warn,4);
                         num_a=num_a-b_list(warn,4);
                         num_b=num_b-b_list(warn,4);

                         % -- delete the old Zero
                         if b_list(warn,5)
                            delete(b_list(warn,5));
                         end;
                         
                         delete(b_list(warn,3));
                         
                         if warn~=num_diff_b
                             b_list(warn:num_diff_b-1,:)=b_list(warn+1:num_diff_b,:);
                         end;
                         
                         if (num_diff_b-1==0)
                             b_list=[];
                             num_diff_b=0;
                             num_b=0;
                         else    
                             b_list=b_list(1:num_diff_b-1,:);
                             num_diff_b=num_diff_b-1;
                         end;
                         
                         % -- If no poles left to plot, make sure the rotines aren't run
                         place= -( t_weight==0 );
                             
                else 
                         % -- we know there are multi zeros, and there are more zeros than poles
                         num_a=num_a-t_weight;
                         b_list(warn,4)=b_list(warn,4)-t_weight;
                         if (b_list(warn,4)==1)           
                             delete(b_list(warn,5));
                             b_list(warn,5)=0;
                         else
                             set(b_list(warn,5),'string',num2str(b_list(warn,4)) );
                         end;
                         t_weight=-1; % -- Set so we don't add a new pole
                         place=1;     % -- No new pole to add    
                               
                end;
           end;
         end; 
               
         if (place==0) 
              num_diff_a=num_diff_a+1;
              place=num_diff_a;
              axes(axes_zplane);
              a_list(place,1)=new(1);
              a_list(place,2)=new(2);
              if is_a_pole
                  a_list(place,3)=plot(new(1),new(2),'x','erasemode','background',...
                      'ButtonDownFcn','global w_main_win;set(w_main_win,''WindowButtonUpFcn'',''pez_bin(''''moveup'''')'');pez_bin(''movedown_b'',gco);');
              else
                  a_list(place,3)=plot(new(1),new(2),'o','erasemode','background',...
                      'ButtonDownFcn','global w_main_win;set(w_main_win,''WindowButtonUpFcn'',''pez_bin(''''moveup'''')'');pez_bin(''movedown_b'',gco);');
              end;    
              a_list(place,4)=1;
              a_list(place,5)=0;
              t_weight=t_weight-1;
         end;
         
         if (t_weight>0) 
             
           % -- We already have an occurance
              if (a_list(place,4)==1)
                  %-- new handle
                  a_list(place,4)=a_list(place,4)+t_weight; 
                  
                  a_list(place,5)=text(a_list(place,1)+pez_fuz,a_list(place,2)+pez_fuz,num2str(a_list(place,4)),'erasemode','background',...
                      'ButtonDownFcn',['global w_main_win;',...
                      'set(w_main_win,''WindowButtonUpFcn'',''pez_bin(''''moveup'''')'');',...
                      'pez_bin(''movedown_b'' ,',num2str(a_list(place,3),32) ,');' ]);
                     
              else
                  %-- old handle - we already have multiple occurrances         
                  a_list(place,4)=a_list(place,4)+t_weight; 
                  set(a_list(place,5),'string',num2str(a_list(place,4)));
              end;          
         end; 
         
   if is_a_pole
      p_list=a_list;
      z_list=b_list;
      num_poles = num_a;
      num_zeros = num_b;
      num_diff_poles=num_diff_a;
      num_diff_zeros=num_diff_b;
   else
      p_list=b_list;
      z_list=a_list;
      num_poles = num_b;
      num_zeros = num_a;
      num_diff_poles=num_diff_b;
      num_diff_zeros=num_diff_a;
   end;   
