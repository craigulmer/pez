function pez_bin(action,p_val)
%
%  pez_bin() :: Bulk of decode action routines. Zscale, Add Mirrors,etc
%  for PeZ v2.8b last Rev Feb 25  -- No Modifications without author's consent
%  (type 'pez' in MATLAB to run)
%  Craig Ulmer / GRiMACE@ee.gatech.edu

global ed_scale sli_scale p_list z_list num_poles num_zeros z_axis w_main_win axes_zplane place num_diff_poles num_diff_zeros
global weight ed_weight sli_weight new mirror_x mirror_y del_place del_x del_y pz z_axis x_val y_val 
global precision dp move_x_val move_y_val move_type move_place move_handle move_num_handle drag_move 
global ed_real ed_imag ed_mag ed_angle edit_type fr_omega id_plot pez_fuz 
global str_p_1 str_p_2 str_p_3 str_p_4 str_z_1 str_z_2 str_z_3 str_z_4 str_handle_1 str_handle_2 str_handle_3 str_handle_4 str_ending str_do_plot
global ui_text_line1 ui_text_line2 ui_text_line3 ui_text_line4 ed_change pez_gain

if nargin<1,
     action='new';
end;     




% ===================================
%  Handle the RESET Z_AXIS or 'rzaxis' call
if strcmp(action,'rzaxis')
       if p_val  % Came from sli_scale
           p_val=get(sli_scale,'val');
       else      % Came from ed_scale
           p_val=str2num(get(ed_scale,'string'));
       end;   
       if (p_val>=.5) & (p_val<=10)
          z_axis=p_val;
          axes(axes_zplane);
          axis([-z_axis z_axis -z_axis z_axis]);
          pez_plot(0);
       end,
       set(ed_scale,'string',num2str(z_axis));
       set(sli_scale,'val',z_axis);
       
       pez_fuz=2*z_axis/80;

% ===================================
%  Handle the RESET WEIGHT or 'rweight' call
elseif strcmp(action,'rweight')
       if p_val  % Came from sli_weight
           p_val=get(sli_weight,'val');
       else      % Came from ed_scale
           p_val=str2num(get(ed_weight,'string'));
       end;
    % Figure out direction  
       if (p_val > weight)
           p_val=ceil(p_val);
       else        
           p_val=floor(p_val);
       end;    
    % Determine if in range
       if (p_val>=1) & (p_val<=50)
          weight=p_val;
       elseif (p_val<1)
          weight=1;
       else
          weight=50;   
       end,
        
       set(ed_weight,'string',num2str(weight));
       set(sli_weight,'val',weight);



% ===================================
%  Handle the Figure Mirrors for Poles or 'addmirrorp' call
elseif strcmp(action,'addmirrorp')
    place=0;

    if (abs(new(1,1))<=0.05)
       new(1,1)=0;
    end;
    if (abs(new(1,2))<=0.05)
       new(1,2)=0;
    end;          
   
    pez_add(new,1);
   
    if (mirror_x & new(1,2))
        new(1,2)= -new(1,2);
        pez_add(new,1);
        new(1,2)= -new(1,2);
    end;
    if (mirror_y & new(1,1))
        new(1,1)= -new(1,1);
        pez_add(new,1);
        new(1,1)= -new(1,1);
    end;
    if ( mirror_x & mirror_y & new(1,1) & new(1,2) )
        new= -new;
        pez_add(new,1);
        new= -new;
    end;    
 
% ===================================
%  Handle the ADD Single POLE or 'addsp' call
elseif strcmp(action,'addsp')
    
    set(ui_text_line1,'horizontalalignment','center','string','Add a Pole');
    set(ui_text_line2,'horizontalalignment','left','string','Use the mouse to position the crosshairs over the z-plane.');
    set(ui_text_line3,'horizontalalignment','left','string','Click the mouse button to add the pole. To abort adding a ');
    set(ui_text_line4,'horizontalalignment','left','string','pole, click outside of the z-plane. ');
    
    axes(axes_zplane);
    new = ginput(1);  
    if ( (abs(new(1,1)) < z_axis) & (abs(new(1,2)) < z_axis ))
        pez_bin('addmirrorp');
        pez_plot(0);  % -- Do a new plot   
    else
        place=0;
    end;        
    pez('restore_text');
                            
% ===================================
%  Handle the ADD Multiple POLES or 'addmp' call
elseif strcmp(action,'addmp')

    place=1;
    while (place)
       pez_bin('addsp');
    end;       

% ===================================
%  Handle the ADD Double POLE or 'adddp' call
elseif strcmp(action,'adddp')

    set(ui_text_line1,'horizontalalignment','center','string','Add a Double Pole: ( Symetric to unit circle )');
    set(ui_text_line2,'horizontalalignment','left','string','Use the mouse to position the crosshairs over the z-plane.');
    set(ui_text_line3,'horizontalalignment','left','string','Click the mouse button to add the pole. To abort adding a ');
    set(ui_text_line4,'horizontalalignment','left','string','pole, click outside of the z-plane. ');

    axes(axes_zplane);
    new = ginput(1);  
    if ( (abs(new(1,1)) < z_axis) & (abs(new(1,2)) < z_axis ))
        pez_bin('addmirrorp');
        k=[new(1,1)+new(1,2)*j];
        r=abs(k);
        theta=angle(k);
        k=(1/r)*exp(j*theta);
        new(1,1)=real(k);
        new(1,2)=imag(k);
        pez_bin('addmirrorp');

        pez_plot(0);  % -- Do a new plot 
    end;      
    pez('restore_text');
        
% ===================================
%  Handle the Figure Mirrors for Zeros or 'addmirrorz' call
elseif strcmp(action,'addmirrorz')
    place=0;

    if (abs(new(1,1))<=0.05)
       new(1,1)=0;
       
    end;
    if (abs(new(1,2))<=0.05)
       new(1,2)=0;
    end;          

    pez_add(new,0);
    
    if (mirror_x & new(1,2) )
           new(1,2)= -new(1,2);
           pez_add(new,0);
           new(1,2)= -new(1,2);
    end;
    if (mirror_y & new(1,1) )
           new(1,1)= -new(1,1);
           pez_add(new,0);
           new(1,1)= -new(1,1);
    end;
    if (mirror_x & mirror_y & new(1,1) & new(1,2) )
           new= -new;
           pez_add(new,0);
           new= -new;
    end; 
      
% ===================================
%  Handle the ADD Single ZERO or 'addsz' call
elseif strcmp(action,'addsz')

    set(ui_text_line1,'horizontalalignment','center','string','Add a Zero');
    set(ui_text_line2,'horizontalalignment','left','string','Use the mouse to position the crosshairs over the z-plane.');
    set(ui_text_line3,'horizontalalignment','left','string','Click the mouse button to add the zero. To abort adding a ');
    set(ui_text_line4,'horizontalalignment','left','string','zero, click outside of the z-plane. ');

    axes(axes_zplane);
    new = ginput(1); 
    if ( (abs(new(1,1)) < z_axis) & (abs(new(1,2)) < z_axis ))
       pez_bin('addmirrorz');
       pez_plot(0);  % -- Do a new plot  
    else
       place=0;
    end;
    pez('restore_text');
        
% ===================================
%  Handle the ADD Multiple ZEROS or 'addmz' call
elseif strcmp(action,'addmz')

    place=1;
    while (place)
       pez_bin('addsz');
    end;       

% ===================================
%  Handle the ADD Double ZERO or 'adddz' call
elseif strcmp(action,'adddz')

    set(ui_text_line1,'horizontalalignment','center','string','Add a Double Zero: ( Symetric to unit circle )');
    set(ui_text_line2,'horizontalalignment','left','string','Use the mouse to position the crosshairs over the z-plane.');
    set(ui_text_line3,'horizontalalignment','left','string','Click the mouse button to add the zero. To abort adding a ');
    set(ui_text_line4,'horizontalalignment','left','string','zero, click outside of the z-plane. ');

    axes(axes_zplane);
    new = ginput(1);
    if ( (abs(new(1,1)) < z_axis) & (abs(new(1,2)) < z_axis ))
       pez_bin('addmirrorz');
       k=[new(1,1)+new(1,2)*j];
       r=abs(k);
       theta=angle(k);
       k=(1/r)*exp(j*theta);
       new(1,1)=real(k);
       new(1,2)=imag(k);
       pez_bin('addmirrorz');
       pez_plot(0);  % -- Do a new plot   
    end;
    pez('restore_text');
        

% ===================================
%  Handle the ADD Double POLE-ZERO COMBO or 'adddpz' call
elseif strcmp(action,'adddpz')

    set(ui_text_line1,'horizontalalignment','center','string','Add a Pole / Zero Double: ( Symetric to unit circle )');
    set(ui_text_line2,'horizontalalignment','left','string','Use the mouse to position the crosshairs over the z-plane.');
    set(ui_text_line3,'horizontalalignment','left','string','Click the mouse button to add the pole/zero. To abort adding a ');
    set(ui_text_line4,'horizontalalignment','left','string','pole/zero, click outside of the z-plane. ');

    axes(axes_zplane);
    new_orig = ginput(1);
    if ( (abs(new_orig(1,1)) < z_axis) & (abs(new_orig(1,2)) < z_axis ))
      k=[new_orig(1,1)+new_orig(1,2)*j];
      r=abs(k);
      theta=angle(k);
      new_comp(1,1)=real((1/r)*exp(j*theta));
      new_comp(1,2)=imag((1/r)*exp(j*theta));
      if (r>1)             % true then original click inside circle          
         new=new_orig;
         pez_bin('addmirrorz');
         new=new_comp;
         pez_bin('addmirrorp');
      else                      % original click outside circle
         new=new_comp;
         pez_bin('addmirrorz');
         new=new_orig;
         pez_bin('addmirrorp');
      end;

      pez_plot(0);  % -- Do a new plot  
    end;   
    pez('restore_text');
        
   
% ===================================
%  Handle the Figure Mirrors for Zeros or 'delmirrorz' call
elseif strcmp(action,'delmirrorz')                                                


        pez_del(del_place,0);
         
        if (mirror_x & num_zeros)
           del_place=pez_is_hit(del_x,-del_y,z_list(:,1),z_list(:,2),precision);
           if del_place
              pez_del(del_place,0);
           end;   
        end;
        
        if (mirror_y & num_zeros)
           del_place=pez_is_hit(-del_x,del_y,z_list(:,1),z_list(:,2),precision);
           if del_place   
              pez_del(del_place,0);
           end;   
        end;

        if (mirror_x & mirror_y & num_zeros)
           del_place=pez_is_hit(-del_x,-del_y,z_list(:,1),z_list(:,2),precision);
           if del_place         
              pez_del(del_place,0);
           end;
        end;
  
% ===================================
%  Handle the Figure Mirrors for Poles or 'delmirrorp' call
elseif strcmp(action,'delmirrorp')                                                


        pez_del(del_place,1);
         
        if (mirror_x & num_poles)
           del_place=pez_is_hit(del_x,-del_y,p_list(:,1),p_list(:,2),precision);
           if del_place
              pez_del(del_place,1);
           end;   
        end;
        
        if (mirror_y & num_poles)
           del_place=pez_is_hit(-del_x,del_y,p_list(:,1),p_list(:,2),precision);
           if del_place   
              pez_del(del_place,1);
           end;   
        end;

        if (mirror_x & mirror_y & num_poles)
           del_place=pez_is_hit(-del_x,-del_y,p_list(:,1),p_list(:,2),precision);
           if del_place         
              pez_del(del_place,1);
           end;
        end;


% ===================================
%  Handle the Delete Single  'delexecute' call
elseif strcmp(action,'delexecute')
 
  if ((abs(del_x)<= z_axis) & (abs(del_y) <= z_axis) )
  
    del_place=0;
    if num_zeros
          del_place=pez_is_hit(del_x,del_y,z_list(:,1),z_list(:,2),precision);
          if  del_place 
              pez_bin('delmirrorz');
          end;
    end;
              
    if (num_poles & ~del_place)
          del_place=pez_is_hit(del_x,del_y,p_list(:,1),p_list(:,2),precision);
          if  del_place
              pez_bin('delmirrorp');
          end;
    end;      
 end;
  
  pez_plot(0);

% ===================================
%  Handle the Delete Single  'dels' call
elseif strcmp(action,'dels')

    set(ui_text_line1,'horizontalalignment','center','string','Delete a Weighted Pole/Zero');
    set(ui_text_line2,'horizontalalignment','left','string','Use the mouse to select the object to be removed. If the');
    set(ui_text_line3,'horizontalalignment','left','string','item is weighted, the current weight will be subtracted'); 
    set(ui_text_line4,'horizontalalignment','left','string','from the object. To abort,click outside of the z-plane. ');

    drawnow;

      axes(axes_zplane);
      dp=ginput(1);
      del_x=dp(1,1);
      del_y=dp(1,2);

      pez_bin('delexecute');
      
      pez('restore_text');
 
% ===================================
%  Handle the Delete Many 'delm' call
elseif strcmp(action,'delm')

    set(ui_text_line1,'horizontalalignment','center','string','Delete Multiple Weighted Poles/Zeros');
    set(ui_text_line2,'horizontalalignment','left','string','Use the mouse to select the object to be removed. If the');
    set(ui_text_line3,'horizontalalignment','left','string','item is weighted, the current weight will be subtracted'); 
    set(ui_text_line4,'horizontalalignment','left','string','from the object. To abort, click outside of the z-plane.');

    drawnow;
      
       axes(axes_zplane);
       dp=ginput(1);
       del_x=dp(1,1);
       del_y=dp(1,2);

       pez_bin('delexecute');

       if ((abs(del_x) > z_axis) | (abs(del_y) > z_axis) | ( num_poles+num_zeros==0 ) )     
           pez('restore_text');
       else
           pez_bin('delm');
       end; 


% ===================================
%  Handle the Button Down for a Move 'movedown' call
elseif (strcmp(action,'movedown') | strcmp(action,'move_down_real') )
  
      if (pz==0) 
          dp=get(gca,'CurrentPoint');

          move_x_val=dp(1,1);
          move_y_val=dp(1,2);

          if ((abs(move_x_val)<=z_axis) & (abs(move_y_val)<=z_axis) & ( num_poles+num_zeros ) )

                move_type=0;
                move_place      = [0 0 0 0];
                move_handle     = [0 0 0 0];
                move_num_handle = [0 0 0 0];

                
                if num_poles
                      k_tmp=pez_is_hit(move_x_val,move_y_val,p_list(:,1),p_list(:,2),precision);
                      if (k_tmp)
                          move_place(1,1)=k_tmp;
                          move_type=1;
                          move_handle(1,1)=p_list(k_tmp,3);
                          move_num_handle(1,1)=p_list(k_tmp,5);
                      end;
                end;
                
                if (move_type & mirror_x)                                                                      
                      k_tmp=pez_is_hit(move_x_val,-move_y_val,p_list(:,1),p_list(:,2),precision);
                      if (k_tmp & ~any(move_place==k_tmp))
                          move_place(1,2)=k_tmp;
                          move_handle(1,2)=p_list(k_tmp,3);
                          move_num_handle(1,2)=p_list(k_tmp,5);
                      end;
                end;    

                if (move_type & mirror_y)
                      k_tmp=pez_is_hit(-move_x_val,move_y_val,p_list(:,1),p_list(:,2),precision);
                      if (k_tmp & ~any(move_place==k_tmp))
                          move_place(1,3)=k_tmp;
                          move_handle(1,3)=p_list(k_tmp,3);
                          move_num_handle(1,3)=p_list(k_tmp,5);
                      end;
                end;    

                if (move_type & mirror_y & mirror_x)

                      k_tmp=pez_is_hit(-move_x_val,-move_y_val,p_list(:,1),p_list(:,2),precision);
                      if (k_tmp & ~any(move_place==k_tmp))
                          move_place(1,4)=k_tmp;
                          move_handle(1,4)=p_list(k_tmp,3);
                          move_num_handle(1,4)=p_list(k_tmp,5);
                      end;
                end;    
                
                if (num_zeros & ~move_type)

                      k_tmp=pez_is_hit(move_x_val,move_y_val,z_list(:,1),z_list(:,2),precision);
                       if (k_tmp)
                          move_type=2;
                          move_place(1,1)=k_tmp;
                          move_handle(1,1)=z_list(k_tmp,3);
                          move_num_handle(1,1)=z_list(k_tmp,5);
                      end;
                end;

                if ((move_type==2) & mirror_x)

                      k_tmp=pez_is_hit(move_x_val,-move_y_val,z_list(:,1),z_list(:,2),precision);
                      if ( k_tmp  & ~any(move_place==k_tmp))
                          move_place(1,2)=k_tmp;
                          move_handle(1,2)=z_list(k_tmp,3);
                          move_num_handle(1,2)=z_list(k_tmp,5);
                      end;
                end;    

                if ((move_type==2) & mirror_y)

                      k_tmp=pez_is_hit(-move_x_val,move_y_val,z_list(:,1),z_list(:,2),precision);
                      if ( k_tmp & ~any(move_place==k_tmp))
                          move_place(1,3)=k_tmp;
                          move_handle(1,3)=z_list(k_tmp,3);
                          move_num_handle(1,3)=z_list(k_tmp,5);
                      end;
                end;    

                if ( (move_type==2) & mirror_y & mirror_x)

                      k_tmp=pez_is_hit(-move_x_val,-move_y_val,z_list(:,1),z_list(:,2),precision);
                      if (k_tmp & ~any(move_place==k_tmp))
                          move_place(1,4)=k_tmp;
                          move_handle(1,4)=z_list(k_tmp,3);
                          move_num_handle(1,4)=z_list(k_tmp,5);
                      end;
                end;    

                
                pz=move_handle(1,1);
                         
                if  move_type & drag_move
                      pez('info_move');
                      if (move_type == 1)          % -- move is a pole
                         if move_place(1,4)        % --   all 4 quads
                           if move_num_handle(1,4) % --      with handle
                                if strcmp(action,'move_down_real')
                                  set(w_main_win,'WindowButtonMotionFcn',[str_p_4, str_handle_4, str_do_plot, str_ending ] );
                                else
                                  set(w_main_win,'WindowButtonMotionFcn',[str_p_4, str_handle_4, str_ending ] );
                                end,    
                           else
                                if strcmp(action,'move_down_real')
                                  set(w_main_win,'WindowButtonMotionFcn',[str_p_4, str_do_plot, str_ending] );
                                else
                                  set(w_main_win,'WindowButtonMotionFcn',[str_p_4, str_ending ] );
                                end,         
                           end,
                         elseif move_place(1,3)    % --   Horizontal quads
                           if move_num_handle(1,3) % --      with handle
                                if strcmp(action,'move_down_real')
                                  set(w_main_win,'WindowButtonMotionFcn',[str_p_3, str_handle_3, str_do_plot, str_ending] );
                                else
                                  set(w_main_win,'WindowButtonMotionFcn',[str_p_3, str_handle_3, str_ending ] );
                                end,
                           else
                                if strcmp(action,'move_down_real')
                                  set(w_main_win,'WindowButtonMotionFcn',[str_p_3, str_do_plot, str_ending] );
                                else
                                  set(w_main_win,'WindowButtonMotionFcn',[str_p_3, str_ending ] );
                                end,         
                           end,
                         elseif move_place(1,2)    % --   Vertical quads
                           if move_num_handle(1,2) % --      with handle
                                if strcmp(action,'move_down_real') 
                                  set(w_main_win,'WindowButtonMotionFcn',[str_p_2, str_handle_2, str_do_plot, str_ending] );
                                else
                                  set(w_main_win,'WindowButtonMotionFcn',[str_p_2, str_handle_2, str_ending ] );
                                end, 
                           else
                                if strcmp(action,'move_down_real')
                                  set(w_main_win,'WindowButtonMotionFcn',[str_p_2, str_do_plot, str_ending] );
                                else
                                  set(w_main_win,'WindowButtonMotionFcn',[str_p_2, str_ending ] );
                                end,         
                           end,
                         else % move_place(1,1)    % --   Only 1st Quad
                           if move_num_handle(1,1) % --      with handle
                                if strcmp(action,'move_down_real')  
                                  set(w_main_win,'WindowButtonMotionFcn',[str_p_1, str_handle_1, str_do_plot, str_ending] );
                                else
                                  set(w_main_win,'WindowButtonMotionFcn',[ str_p_1, str_handle_1, str_ending] );
                                end, 
                           else
                                if strcmp(action,'move_down_real')
                                  set(w_main_win,'WindowButtonMotionFcn',[str_p_1, str_do_plot, str_ending] ); 
                                else
                                  set(w_main_win,'WindowButtonMotionFcn',[str_p_1, str_ending ] );
                                end,        
                           end,
                         end,  

                      else                         % -- move is a zero
                         if move_place(1,4)        % --   all 4 quads
                           if move_num_handle(1,4) % --      with handle
                                if strcmp(action,'move_down_real')
                                  set(w_main_win,'WindowButtonMotionFcn',[str_z_4, str_handle_4, str_do_plot, str_ending] );
                                else
                                  set(w_main_win,'WindowButtonMotionFcn',[str_z_4, str_handle_4, str_ending ] );
                                end,  
                           else
                                if strcmp(action,'move_down_real')
                                  set(w_main_win,'WindowButtonMotionFcn',[str_z_4, str_do_plot,  str_ending ] ); 
                                 else
                                  set(w_main_win,'WindowButtonMotionFcn',[str_z_4,  str_ending  ] );
                                end,        
                           end,
                         elseif move_place(1,3)    % --   Horizontal quads
                           if move_num_handle(1,3) % --      with handle
                                if strcmp(action,'move_down_real')
                                  set(w_main_win,'WindowButtonMotionFcn',[str_z_3, str_handle_3, str_do_plot, str_ending] );
                                else
                                  set(w_main_win,'WindowButtonMotionFcn',[str_z_3, str_handle_3, str_ending  ] );
                                end,  
                           else
                                if strcmp(action,'move_down_real')
                                  set(w_main_win,'WindowButtonMotionFcn',[str_z_3, str_do_plot, str_ending] ); 
                                else
                                  set(w_main_win,'WindowButtonMotionFcn',[str_z_3, str_ending ] );
                                end,        
                           end,
                         elseif move_place(1,2)    % --   Vertical quads
                           if move_num_handle(1,2) % --      with handle
                                if strcmp(action,'move_down_real')
                                  set(w_main_win,'WindowButtonMotionFcn',[str_z_2, str_handle_2, str_do_plot, str_ending] );
                                else
                                  set(w_main_win,'WindowButtonMotionFcn',[str_z_2, str_handle_2, str_ending ] );
                                end,  
                           else
                                if strcmp(action,'move_down_real')
                                  set(w_main_win,'WindowButtonMotionFcn',[str_z_2, str_do_plot, str_ending] ); 
                                else
                                  set(w_main_win,'WindowButtonMotionFcn',[str_z_2, str_ending ] );
                                end,       
                           end,
                         else                      % --   Only 1st Quad
                           if move_num_handle(1,1) % --      with handle
                                if strcmp(action,'move_down_real')
                                  set(w_main_win,'WindowButtonMotionFcn',[str_z_1, str_handle_1, str_do_plot, str_ending] );
                                else
                                  set(w_main_win,'WindowButtonMotionFcn',[str_z_1, str_handle_1, str_ending ] );
                                end,  
                           else
                                if strcmp(action,'move_down_real')
                                  set(w_main_win,'WindowButtonMotionFcn',[str_z_1, str_do_plot, str_ending] );
                                else
                                  set(w_main_win,'WindowButtonMotionFcn',[str_z_1,  str_ending ] );
                                end,         
                           end,
                         end,
                      end,   

                 
                                      
                 else 
                         pz=0;
                 end;
         else
               pz=0;
               set(w_main_win,'WindowButtonDownFcn',' ');
               set(w_main_win,'WindowButtonUpFcn',' ');
               set(w_main_win,'Pointer','Arrow');   
              
               set(ed_real, 'string',num2str(0) );
               set(ed_imag, 'string',num2str(0) );
               set(ed_mag,  'string',num2str(0) );
               set(ed_angle,'string',num2str(0) );
               set(ed_real, 'call',' ');
               set(ed_imag, 'call',' ');
               set(ed_mag,  'call',' ');
               set(ed_angle,'call',' ');

         end;
   end;



% ===================================
%  Handle the Button Up for a Move 'moveup' call
elseif strcmp(action,'moveup')
 
  set(w_main_win,'WindowButtonMotionFcn',' ');       
  if ~(pz==0) 

     weight_tmp=weight;
     
     if move_type==1
        weight    = p_list(move_place(1,1),4);
        del_place = move_place(1,1);
        del_x     = p_list(move_place(1,1),1);
        del_y     = p_list(move_place(1,1),2);
        pez_bin('delmirrorp');
     else
        weight    = z_list(move_place(1,1),4);
        del_place = move_place(1,1);
        del_x     = z_list(move_place(1,1),1);
        del_y     = z_list(move_place(1,1),2);
        pez_bin('delmirrorz');
     end;

     new(1,1) = move_x_val;
     new(1,2) = move_y_val;     

     if move_type==1
        pez_bin('addmirrorp');
     else
        pez_bin('addmirrorz');
     end;    
     
     weight=weight_tmp;
        
     if drag_move
         pz=0;
         set(w_main_win,'WindowButtonDownFcn',' ');
         set(w_main_win,'WindowButtonUpFcn',' ');
         set(w_main_win,'Pointer','Arrow');
     end;
                 
end;

    axes(axes_zplane);
    refresh;
    pez('restore_text');
    pez_plot(0);  % -- Do a new plot   

% ===================================
%  Handle the Edit Change 'point2point' call
elseif strcmp(action,'point2point')

    set(ui_text_line1,'horizontalalignment','center','string','Move from Point to Point');
    set(ui_text_line2,'horizontalalignment','left','string','This moves an object from a starting point to a destination.');
    set(ui_text_line3,'horizontalalignment','center','string','      To begin, Click on the object you want to move.'); 
    set(ui_text_line4,'horizontalalignment','left','string','To abort moving a pole/zero, click outside of the z-plane. ');

    axes(axes_zplane);
    old_obj = ginput(1);  
    
    if ((abs(old_obj(1))<=z_axis) & (abs(old_obj(2))<=z_axis) & ( num_poles+num_zeros ) )
    
       move_type=0;
       
       if num_poles
           move_place=pez_is_hit(old_obj(1),old_obj(2),p_list(:,1),p_list(:,2),precision);
           if (move_place~=0)
                 move_type=1;
           end;
       end;
       
       if ( num_zeros & ~move_place )
           move_place=pez_is_hit(old_obj(1),old_obj(2),z_list(:,1),z_list(:,2),precision);
           if ( move_place~=0 )
                 move_type=2;
           end;
       end;    
       
       if  ( move_type )  
           
           set(ui_text_line3,'horizontalalignment','center','string','  Now click on the location you wish to place the object.'); 
            
           new_obj = ginput(1);

           if  ( (abs(new_obj(1))<=z_axis) & (abs(new_obj(2))<=z_axis)  )   
                   move_x_val=new_obj(1);
                   move_y_val=new_obj(2);
                   pz=1;
                   pez_bin('moveup');  
           end;
       
       else
           pez_bin('point2point');
       end;
       
    end;   
    pez('restore_text');                  

% ===================================
%  Handle the Select Edits 'edit_select' call
elseif strcmp(action,'edit_select')

  pez('info_edsel');
  new_obj=ginput(1);
  move_place=0;
  move_type=0;
  
  if ( (abs(new_obj(1))<=z_axis) & (abs(new_obj(2))<=z_axis)  )
    if num_poles 
        move_place=pez_is_hit(new_obj(1),new_obj(2),p_list(:,1),p_list(:,2),precision);
        if ( move_place~=0 )
                 move_type=1;
        end;
    end
    if (num_zeros & ~move_place)
        move_place=pez_is_hit(new_obj(1),new_obj(2),z_list(:,1),z_list(:,2),precision);
    end;
  end;
  
  if move_place
      set(ed_real,'call', 'global edit_type;edit_type=1; pez_bin(''edit_set'');');      
      set(ed_imag,'call', 'global edit_type;edit_type=1; pez_bin(''edit_set'');');      
      set(ed_mag,'call',  'global edit_type;edit_type=0; pez_bin(''edit_set'');');      
      set(ed_angle,'call','global edit_type;edit_type=0; pez_bin(''edit_set'');');      
      if move_type
        set(ed_real,'string',num2str(p_list(move_place,1)));
        set(ed_imag,'string',num2str(p_list(move_place,2)));
        set(ed_mag,'string',  num2str(  abs(p_list(move_place,1)+j*p_list(move_place,2)) ) );
        set(ed_angle,'string',num2str(angle(p_list(move_place,1)+j*p_list(move_place,2)) ) );
      else  
        set(ed_real,'string',num2str(z_list(move_place,1)));
        set(ed_imag,'string',num2str(z_list(move_place,2)));
        set(ed_mag,'string',  num2str(  abs(z_list(move_place,1)+j*z_list(move_place,2)) ) );
        set(ed_angle,'string',num2str(angle(z_list(move_place,1)+j*z_list(move_place,2)) ) );
      end;
      set(ed_change,'visible','on');
      pez('info_edch');
  else %No hit, blank out
      set(ed_change,'visible','off');
      set(ed_real,'string','0');      
      set(ed_imag,'string','0');      
      set(ed_mag,'string','0');      
      set(ed_angle,'string','0');      
      set(ed_real,'call',' ');      
      set(ed_imag,'call',' ');      
      set(ed_mag,'call',' ');      
      set(ed_angle,'call',' '); 
      pez('info_edco');     
  end;       

% ===================================
%  Handle the Edit Change 'edit_set' call
elseif strcmp(action,'edit_set')

    if edit_type
       % -- Real/Imag value changed
       move_x_tmp=str2num(get(ed_real,'string'));
       move_y_tmp=str2num(get(ed_imag,'string'));
       total_tmp =move_x_tmp + j*move_y_tmp;
       mag_tmp   =abs(total_tmp);
       angle_tmp =angle(total_tmp);
    else
       % -- Mag / Ang  value changed
       mag_tmp    =str2num(get(ed_mag,'string'));
       angle_tmp  =str2num(get(ed_angle,'string'));
       total_tmp  =mag_tmp*exp(j*angle_tmp);
       move_x_tmp =real(total_tmp);
       move_y_tmp =imag(total_tmp);
    end;    

    set(ed_real, 'string',num2str(move_x_tmp));
    set(ed_imag, 'string',num2str(move_y_tmp));
    set(ed_mag,  'string',num2str(mag_tmp   ));
    set(ed_angle,'string',num2str(angle_tmp ));   
   
% ===================================****************************************************
%  Handle the Edit Change 'edit_final' call
elseif strcmp(action,'edit_final')

    new(1,1)=str2num(get(ed_real,'string'));
    new(1,2)=str2num(get(ed_imag,'string'));

    del_place=move_place;
    tmp_weight=weight;
    if move_type
      weight=p_list(move_place,4);
      del_x= p_list(move_place,1);
      del_y= p_list(move_place,2);
      pez_bin('delmirrorp');
      pez_bin('addmirrorp');
    else        
      weight=z_list(move_place,4);
      del_x= z_list(move_place,1);
      del_y= z_list(move_place,2);
      pez_bin('delmirrorz');
      pez_bin('addmirrorz');
    end;
    
    weight=tmp_weight;
    set(ed_real, 'string','0');
    set(ed_imag, 'string','0');
    set(ed_mag,  'string','0');
    set(ed_angle,'string','0');   
    set(ed_real,'call', ' ');      
    set(ed_imag,'call', ' ');      
    set(ed_mag,'call',  ' ');      
    set(ed_angle,'call',' ');      
    set(ed_change,'visible','off');
    
    pez('info_edco');
    pez_plot(0);
    
        
% ===================================
%  Handle the Clear Zeros 'kill_zeros' call
elseif strcmp(action,'kill_zeros')

    if num_zeros
      delete(z_list(:,3));
      delete(z_list(find(z_list(:,5)),5))
    end;
    
    pez_gain=1;
    z_list=[];
    num_zeros=0;
    num_diff_zeros=0;
    pez_plot(0);

% ===================================
%  Handle the Clear Poles 'kill_poles' call
elseif strcmp(action,'kill_poles')

    if num_poles
      delete(p_list(:,3));
      delete(p_list(find(p_list(:,5)),5))
    end;
    
    p_list=[];
    num_poles=0;
    num_diff_poles=0;
    pez_plot(0);

% ===================================
%  Handle the Clear Poles 'init_strings' call
elseif strcmp(action,'init_strings')


    str_all1=   [   'global w_main_win z_axis pz move_x_val move_y_val ',...
                           'move_handle move_num_handle move_type move_place ',...
                           'p_list z_list precision pez_fuz;',...
                         'figure(w_main_win);',...
                         'pt=get(gca,''CurrentPoint'');',...
                         'if ~( (pt(1,1)==move_x_val)&(pt(1,2)==move_y_val) ) ',...
                         ' if (abs(pt(1,1))<z_axis ) & (abs(pt(1,2))<z_axis )  ',...
                         '  move_x_val=pt(1,1);',...
                         '  move_y_val=pt(1,2);',...
                         ' elseif (~(pt(1,1)>-z_axis) & ~(pt(1,2)>-z_axis))',...
                         '  move_x_val=-z_axis;',...
                         '  move_y_val=-z_axis;',...
                         ' elseif (~(pt(1,1)<z_axis) & ~(pt(1,2)>-z_axis))',...
                         '  move_x_val=z_axis;',...
                         '  move_y_val=-z_axis;',...
                         ' elseif (~(pt(1,1)>-z_axis) & ~(pt(1,2)<z_axis))',...
                         '  move_x_val=-z_axis;',...
                         '  move_y_val=z_axis;',...
                         ' elseif (~(pt(1,1)<z_axis) & ~(pt(1,2)<z_axis))',...
                         '  move_x_val=z_axis;',...
                         '  move_y_val=z_axis;',...
                         ' elseif ~(pt(1,1)>-z_axis) ',...
                         '  move_x_val=-z_axis;',...
                         '  move_y_val=pt(1,2);',...
                         ' elseif ~(pt(1,1)<z_axis) ',...
                         '  move_x_val=z_axis;',...
                         '  move_y_val=pt(1,2);',...
                         ' elseif ~(pt(1,2)>-z_axis) ',...
                         '  move_x_val=pt(1,1);',...
                         '  move_y_val=-z_axis;',...
                         ' else                    ',...
                         '  move_x_val=pt(1,1);',...
                         '  move_y_val=z_axis;',...
                         ' end,',...
                         ' set(pz,''Xdata'',move_x_val);  ',...
                         ' set(pz,''Ydata'',move_y_val);  '];
                         
    % Pole Strings                         
         str_p1 =    [   'p_list(move_place(1,1),1)=move_x_val;',...
                         'p_list(move_place(1,1),2)=move_y_val;'    ];
                         
         str_p2a  =  [   'set(p_list(move_place(1,2),3),''Xdata'',move_x_val);',...
                         'set(p_list(move_place(1,2),3),''Ydata'',-move_y_val);',...
                         'p_list(move_place(1,2),1)=move_x_val;',...
                         'p_list(move_place(1,2),2)=-move_y_val;' ];
                        
         str_p2b  = [    'set(p_list(move_place(1,3),3),''Xdata'',-move_x_val);',...
                         'set(p_list(move_place(1,3),3),''Ydata'',move_y_val);',...
                         'p_list(move_place(1,3),1)=-move_x_val;',...
                         'p_list(move_place(1,3),2)=move_y_val;'];
                     
         str_p2c  = [    'set(p_list(move_place(1,4),3),''Xdata'',-move_x_val);',...
                         'set(p_list(move_place(1,4),3),''Ydata'',-move_y_val);',...
                         'p_list(move_place(1,4),1)=-move_x_val;',...
                         'p_list(move_place(1,4),2)=-move_y_val;'];
                        
     str_do_plot  =      'pez_plot(1);';
         
    % Zero Strings                         
                       
          str_z1  = [    'z_list(move_place(1,1),1)=move_x_val;',...
                         'z_list(move_place(1,1),2)=move_y_val;'];
                   
          str_z2a  = [   'set(z_list(move_place(1,2),3),''Xdata'',move_x_val);',...
                         'set(z_list(move_place(1,2),3),''Ydata'',-move_y_val);',...
                         'z_list(move_place(1,2),1)=move_x_val;',...
                         'z_list(move_place(1,2),2)=-move_y_val;'  ];
      
          str_z2b = [    'set(z_list(move_place(1,3),3),''Xdata'',-move_x_val);',...
                         'set(z_list(move_place(1,3),3),''Ydata'',move_y_val);',...
                         'z_list(move_place(1,3),1)=-move_x_val;',...
                         'z_list(move_place(1,3),2)=move_y_val;'];
                     
          str_z2c = [    'set(z_list(move_place(1,4),3),''Xdata'',-move_x_val);',...
                         'set(z_list(move_place(1,4),3),''Ydata'',-move_y_val);',...
                         'z_list(move_place(1,4),1)=-move_x_val;',...
                         'z_list(move_place(1,4),2)=-move_y_val;'];
                         
    % Handle Strings
          str_h_1 =      'set(move_num_handle(1,1),''pos'',[move_x_val+pez_fuz move_y_val+pez_fuz 0]  );';
          str_h_2 =      'set(move_num_handle(1,2),''pos'',[move_x_val+pez_fuz -move_y_val+pez_fuz 0]  );';
          str_h_3 =      'set(move_num_handle(1,3),''pos'',[-move_x_val+pez_fuz move_y_val+pez_fuz 0]  );';
          str_h_4 =      'set(move_num_handle(1,4),''pos'',[-move_x_val+pez_fuz -move_y_val+pez_fuz 0]  );';
                         
       str_ending =      'drawnow;end,';
                      
                         
     str_p_1 = [ str_all1, str_p1 ]; 
     str_p_2 = [ str_all1, str_p1, str_p2a ];
     str_p_3 = [ str_all1, str_p1, str_p2b ];
     str_p_4 = [ str_all1, str_p1, str_p2a, str_p2b, str_p2b ];
     
     str_z_1 = [ str_all1, str_z1 ]; 
     str_z_2 = [ str_all1, str_z1, str_z2a ];
     str_z_3 = [ str_all1, str_z1, str_z2b ];
     str_z_4 = [ str_all1, str_z1, str_z2a, str_z2b, str_z2b ];
     
     str_handle_1 = [ str_h_1 ];
     str_handle_2 = [ str_h_1 , str_h_2  ];
     str_handle_3 = [ str_h_1 , str_h_3  ];
     str_handle_4 = [ str_h_1 , str_h_2, str_h_3, str_h_4 ];
                         
      



    
% ===================================
%  Handle the OPTIONS event  
elseif strcmp(action,'options'),  
end

