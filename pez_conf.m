function pez_conf(action,config_file_name)
%
%  pez_conf() :: Configuration window and loader
%  for PeZ v3.1b last Rev 11/10/97  -- No Modifications without author's consent
%  (type 'pez' in MATLAB to run)
%  Craig Ulmer / GRiMACE@ee.gatech.edu

global mirror_x mirror_y pez_precision fr_omega frs_omega w_main_win id_plot w_config plot_theta
global pez_real_drag pez_log pez_precision_ed pez_precision_sli pez_angle_type pez_groupdelay

if nargin<1,
     action='help';
end;     

% ================================
%  Handle the Edit Config event

if strcmp(action,'edit_config'),

  if ~exist('w_config') 
    w_config=0; end;  % never opened before, set the win id to something we can't get
  
  if ( isempty(w_config) | ~any( get(0,'children') == w_config ))
        % Open up main control window
        w_config = figure('resize','on','units','pixels','pos',[10 0 400 150],...
                  'numbertitle','off','name','PEZ v3.0 : Edit Configuration');
        
        pez_conf('load_basic');
        userdata=get(gcf,'userdata');
        
        frame_color=[.50 .50 .65];

        % Set up Mirror frame
        uicontrol(w_config, 'style','frame','units','norm','backgroundcolor',frame_color,'pos', [ .02 .80 .45 .15]);

        % Set up Add Title Text        
        uicontrol(w_config,'style','text','units','norm','pos', [ .03 .81 .43 .12],...
                       'backgroundcolor',frame_color,'foregroundcolor',[1 1 1],...
                       'horizontalalignment','center','string','Axis Mirroring');

        % Set up Mirror frame
        uicontrol(w_config, 'style','frame','units','norm','backgroundcolor',frame_color,'pos', [ .02 .40 .45 .40]);

        uicontrol('style','checkbox','units','normal','string','Vertically (Conjugates)','pos',[0.03 0.60 0.43 0.14],...
                         'val',mirror_x,'fore',[1 1 1],'back',frame_color,...
                         'call',['global mirror_x;mirror_x=get(gco,''val'');set(gco,''val'',mirror_x);']);

        uicontrol('style','checkbox','units','normal','string','Horizontally', 'pos',[0.03 0.43 0.43 0.14],...
                         'val',mirror_y,'fore',[1 1 1],'back',frame_color,...
                         'call','global mirror_y;mirror_y=get(gco,''val'');set(gco,''val'',mirror_y);');

        % Set up Precision frame ---------------------
        uicontrol(w_config, 'style','frame','units','norm','backgroundcolor',frame_color,'pos', [ .02 .05 .45 .31]);

         
        uicontrol('style','text','units','norm','pos', [ .03 .20 .34 .12],...
                       'backgroundcolor',frame_color,'foregroundcolor',[1 1 1],...
                       'horizontalalignment','left','string','Adding Precision:');
  
        % Gain Entry Box
        pez_precision_ed = uicontrol('style','edit','units','norm','pos', [.37 .20 .09 .12],...
                   'horizontalalignment','left','string', num2str(log10(pez_precision)), ...
                   'val', log10(pez_precision),'call', 'pez_conf(''set_precision'',0); ');
          
        % Gain Slider
        pez_precision_sli = uicontrol('Style','slider','units','norm','Min',1,'Max',10,'pos',[ .03 .07 .43 .10],...
                      'val',log10(pez_precision),...
                      'CallBack','pez_conf(''set_precision'',1);' );



        % Set up Boot window frame -----------------------------
        uicontrol(w_config, 'style','frame','units','norm','backgroundcolor',frame_color,'pos', [ .50 .82 .46 .15]);

        % Set up Add Title Text        
        uicontrol(w_config,'style','text','units','norm','pos', [ .51 .835 .44 .11],...
                       'backgroundcolor',frame_color,...
                       'foregroundcolor',[1 1 1],...
                       'horizontalalignment','center','string','Pez Boot Defaults');


        % Set up main window size frame
        uicontrol(w_config, 'style','frame','units','norm','backgroundcolor',frame_color,'pos', [ .50 .29 .46 .53]);

        uicontrol('style','checkbox','units','normal','string','Mag Plots in dB', 'pos',[0.51 0.70 0.44 0.11],...
                         'val',userdata(1),'fore',[1 1 1],'back',frame_color,...
                          'call','usertmp=get(gcf,''userdata'');usertmp(1)=get(gco,''val'');set(gcf,''userdata'',usertmp);');

        uicontrol('style','checkbox','units','normal', 'string','Phase Grpdly Plot','pos',[0.51 0.59 0.44 0.11],...
                         'val',userdata(2),'fore',[1 1 1],'back',frame_color,...
                         'call','usertmp=get(gcf,''userdata'');usertmp(2)=get(gco,''val'');set(gcf,''userdata'',usertmp);');
                         
        %-----
        uicontrol('Units','norm','back',frame_color,'fore',[1 1 1],'Pos',[ .51 .45 .44 .14 ],... 
                     'Style','popupmenu','horizontalalign','left','val',userdata(3),... 
                     'string','Tiny Main Window|Small Main Window|Regular Main Window',...
                     'call','usertmp=get(gcf,''userdata'');usertmp(3)=get(gco,''val'');set(gcf,''userdata'',usertmp);');
                         
        uicontrol('Units','norm','back',frame_color,'fore',[1 1 1],'Pos',[ .51 .31 .44 .14 ],... 
                     'Style','popupmenu','horizontalalign','left','val',userdata(4),... 
                     'string','Tiny Plot Window|Regular Plot Window|Large Plot Window',...
                     'call','usertmp=get(gcf,''userdata'');usertmp(4)=get(gco,''val'');set(gcf,''userdata'',usertmp);');


        uicontrol('style','push','units','norm','pos', [ .51 .05 .20 .20],...
                       'horizontalalignment','center','string','Save','call','pez_conf(''save_config'');');

        uicontrol('style','push','units','norm','pos', [ .74 .05 .20 .20],...
                       'horizontalalignment','center','string','Done','call','delete(gcf);');
              
  else  % Our window is still around, bring it up
     figure(w_config);
  end;     

% ================================
%  Handle the reset precision

elseif strcmp(action,'set_precision'),

    % See if came from slider or edit
       if (config_file_name), p_val=get(pez_precision_sli,'val');
       else,       p_val=str2num(get(pez_precision_ed,'string')); end;

    % Figure out direction  
       if (p_val>log10(pez_precision)), p_val=ceil(p_val);
       elseif (p_val<log10(pez_precision)), p_val=floor(p_val); end;

       
    % Determine if in range
       if (p_val>=1) & (p_val<=10), pez_precision=10^p_val;
       elseif (p_val<1),            pez_precision=10;
       else,                        pez_precision=10^10;   end;
        
       set(pez_precision_ed,'string',num2str(log10(pez_precision)));
       set(pez_precision_sli,'val',log10(pez_precision));
   


% ================================
%  Handle the Load Default event

elseif strcmp(action,'load_default'),

  if exist('pez_conf.mat')

      pez_conf('set_config','pez_conf.mat');
      
  else
      mirror_x=1;
      mirror_y=0;
      pez_precision=10;
      pez_real_drag=0;
      pez_log=0;
      pez_angle_type=1;
      pez_groupdelay=0;
      pez('new_plot_win');

  end,      
  fr_omega= linspace(-pi,pi,1024);
  frs_omega=linspace(-pi,pi,256);
  plot_theta=linspace(0,2*pi,70);


% ================================
%  Handle the Set Config event

elseif strcmp(action,'set_config'),

      load(config_file_name);

      pez_log        =userdata(1);
      pez_groupdelay =userdata(2);
      main_win_size  =userdata(3);
      plot_win_size  =userdata(4);      
      mirror_x       =userdata(5);
      mirror_y       =userdata(6);
      pez_precision  =userdata(7);
      pez_real_drag  =userdata(8);
      pez_angle_type =userdata(9);
      
     if main_win_size==1
         figure(w_main_win);
         pez('size_supersmall');   
      elseif main_win_size==2
         figure(w_main_win);
         pez('size_small');
      else
         figure(w_main_win);
         pez('size_regular');
      end,
      
      pez('new_plot_win');
      
      if plot_win_size==1
         pez('size2_small');   
      elseif plot_win_size==2
         pez('size2_regular');
      else
         pez('size2_large');
      end,
      

% ================================
%  Handle the Save Config event

elseif strcmp(action,'save_config'),
      
      userdata=get(gcf,'userdata');

      userdata(5) = mirror_x;
      userdata(6) = mirror_y;
      userdata(7) = pez_precision;
      userdata(8) = pez_real_drag;
      userdata(9) = pez_angle_type;
      
      save pez_conf.mat userdata;

% ================================
%  Handle the load basic event
elseif strcmp(action,'load_basic'),

  if exist('pez_conf.mat')
      load pez_conf;
  else
      userdata=[ 0 0 3 2];
  end;
      
  set(gcf,'userdata',userdata);

      
% ================================
%  No options, churn out the safety message
else
  sprintf(['This file is an internal configuration procedure for PEZ.\n',...),
           'To run pez, type ''pez''.\n']),
end,
    
