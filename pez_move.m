function pez_move(action,is_a_pole)
%
%  pez_move():: Hard code for moving poles/zeros about
%  for PeZ v3.0 last rev June 10,1996  -- No Modifications without author's consent
%  (type 'pez' in MATLAB to run)
%  Craig Ulmer / GRiMACE@ee.gatech.edu


global w_main_win z_axis move_x_val move_y_val move_handle move_numh move_place 
global p_list z_list pez_fuz mirror_x mirror_y pez_real_drag;
  
figure(w_main_win);

if strcmp(action,'move')

  pt=get(gca,'CurrentPoint');
  if ~( (pt(1,1)==move_x_val)&(pt(1,2)==move_y_val) ) 
        if (abs(pt(1,1))<z_axis ) & (abs(pt(1,2))<z_axis )
           move_x_val=pt(1,1); 
           move_y_val=pt(1,2); 
        elseif (~(pt(1,1)>-z_axis) & ~(pt(1,2)>-z_axis)) 
            move_x_val=-z_axis; 
            move_y_val=-z_axis; 
        elseif (~(pt(1,1)<z_axis) & ~(pt(1,2)>-z_axis)) 
            move_x_val=z_axis; 
            move_y_val=-z_axis; 
        elseif (~(pt(1,1)>-z_axis) & ~(pt(1,2)<z_axis)) 
            move_x_val=-z_axis; 
            move_y_val=z_axis; 
        elseif (~(pt(1,1)<z_axis) & ~(pt(1,2)<z_axis)) 
            move_x_val=z_axis; 
            move_y_val=z_axis; 
        elseif ~(pt(1,1)>-z_axis)  
            move_x_val=-z_axis; 
            move_y_val=pt(1,2); 
        elseif ~(pt(1,1)<z_axis)  
            move_x_val=z_axis; 
            move_y_val=pt(1,2); 
        elseif ~(pt(1,2)>-z_axis)  
            move_x_val=pt(1,1);   
            move_y_val=-z_axis; 
        else                     
            move_x_val=pt(1,1); 
            move_y_val=z_axis;  
       end,

       set(move_handle(1),'Xdata',move_x_val);  
       set(move_handle(1),'Ydata',move_y_val);  
       if (move_numh(1))
          set(move_numh(1),'pos',[move_x_val move_y_val]+pez_fuz );
       end;
       if (pez_real_drag)
          if (is_a_pole==1)
             p_list(move_place(1),1)=move_x_val;
             p_list(move_place(1),2)=move_y_val;
          else
             z_list(move_place(1),1)=move_x_val;
             z_list(move_place(1),2)=move_y_val;  
          end;
       end;
       
           
       if (move_handle(2))
          set(move_handle(2),'Xdata',move_x_val);  
          set(move_handle(2),'Ydata',-move_y_val);  
          if (move_numh(2))
             set(move_numh(2),'pos',[move_x_val -move_y_val]+pez_fuz );
          end;
          if (pez_real_drag)
            if (is_a_pole==1)
               p_list(move_place(2),1)=move_x_val;
               p_list(move_place(2),2)=-move_y_val;
            else
               z_list(move_place(2),1)=move_x_val;
               z_list(move_place(2),2)=-move_y_val;  
            end;
          end;
       end;

       if (move_handle(3))
          set(move_handle(3),'Xdata',-move_x_val);  
          set(move_handle(3),'Ydata',move_y_val);  
          if (move_numh(3))
             set(move_numh(3),'pos',[-move_x_val move_y_val]+pez_fuz );
          end;
          if (pez_real_drag)
            if (is_a_pole==1)
               p_list(move_place(3),1)=-move_x_val;
               p_list(move_place(3),2)=move_y_val;
            else
               z_list(move_place(3),1)=-move_x_val;
               z_list(move_place(3),2)=move_y_val;  
            end;
          end;
       end;

       if (move_handle(4))
          set(move_handle(4),'Xdata',-move_x_val);  
          set(move_handle(4),'Ydata',-move_y_val);  
          if (move_numh(4))
             set(move_numh(4),'pos',[-move_x_val -move_y_val]+pez_fuz );
          end;
          if (pez_real_drag)
            if (is_a_pole==1)
               p_list(move_place(4),1)=-move_x_val;
               p_list(move_place(4),2)=-move_y_val;
            else
               z_list(move_place(4),1)=-move_x_val;
               z_list(move_place(4),2)=-move_y_val;  
            end;
          end;
       end;  
       
       %If real time draw, update plots.
       if (pez_real_drag)
          pez_plot(1);
       end;
  end;                

elseif strcmp(action,'finalize')

    if (is_a_pole), the_weight=p_list(move_place(1),4);
    else,           the_weight=z_list(move_place(1),4);      end;
        
    pez_del(move_place(1),is_a_pole,the_weight);
    
    %--If deleted(1), then must shift -1 all places that were higher than (1)
    move_place=move_place-(move_place>move_place(1));
        
    if (move_place(2)), pez_del(move_place(2), is_a_pole, the_weight);
                        move_place=move_place-(move_place>move_place(2));
    end;
    if (move_place(3)), pez_del(move_place(3), is_a_pole,the_weight);
                        move_place=move_place-(move_place>move_place(3));
    end;
    if (move_place(4)), pez_del(move_place(4), is_a_pole, the_weight);
    end;

    if (abs(move_x_val)<=0.05),  move_x_val=0; end;
    if (abs(move_y_val)<=0.05),  move_y_val=0; end;
    
    pez_add([move_x_val move_y_val],is_a_pole, the_weight);
        
    if (mirror_x&move_y_val), pez_add([move_x_val -move_y_val], is_a_pole, the_weight); end;
    if (mirror_y&move_x_val), pez_add([-move_x_val move_y_val], is_a_pole, the_weight); end;
    if (mirror_x&mirror_y&(move_x_val*move_y_val)), pez_add([-move_x_val -move_y_val],is_a_pole, the_weight); end;

    pez_plot(0);  
    set(w_main_win,'WindowButtonMotionFcn',' ');
    set(w_main_win,'WindowButtonUpFcn',' ');
    global axes_zplane;
    axes(axes_zplane);
    refresh;
    

end;
    
          
                            
                         
 