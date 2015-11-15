function pez_config(action,config_file_name)

global mirror_x mirror_y precision fr_omega frs_omega w_main_win id_plot w_config plot_theta

if nargin<1,
     action='help';
end;     

% ================================
%  Handle the Edit Config event

if strcmp(action,'edit_config'),

  if ~exist('w_config') 
    w_config=0; end;  % never opened before, set the win id to something we can't get
  
  if ~any( get(0,'children') == w_config )
        % Open up main control window
        w_config = figure('resize','on','units','pixels',...
                  'Pointer','watch',... 
                  'pos',[600 0 400 150],...
                  'numbertitle','off','name','PEZ v2.0 : Set Configuration');


        frame_color=[.50 .50 .65];

        % Set up Mirror frame
        uicontrol(w_config, 'style','frame','units','norm','backgroundcolor',frame_color,'pos', [ .05 .80 .45 .20]);

        % Set up Add Title Text        
        uicontrol(w_config,'style','text','units','norm','pos', [ .06 .81 .44 .18],...
                       'backgroundcolor',frame_color,...
                       'foregroundcolor',[1 1 1],...
                       'horizontalalignment','center','string','Set Mirror');

        % Set up Mirror frame
        uicontrol(w_config, 'style','frame','units','norm','backgroundcolor',frame_color,'pos', [ .05 .60 .45 .20]);

        uicontrol('style','checkbox','units','normal', ...
                         'string','Mirror across X-Axis', ...
                         'pos',[0.06 0.70 0.44 0.10],...
                         'val',mirror_x,'fore',[1 1 1],'back',frame_color,...
                         'call',' ');

        uicontrol('style','checkbox','units','normal', ...
                         'string','Mirror across Y-Axis', ...
                         'pos',[0.06 0.61 0.44 0.10],...
                         'val',mirror_y,'fore',[1 1 1],'back',frame_color,...
                         'call',' ');

        % Set up Precision frame
        uicontrol(w_config, 'style','frame','units','norm','backgroundcolor',frame_color,'pos', [ .05 .21 .45 .10]);

        % Set up Precision Text        
        uicontrol(w_config,'style','text','units','norm','pos', [ .06 .20 .44 .10],...
                       'backgroundcolor',frame_color,...
                       'foregroundcolor',[1 1 1],...
                       'horizontalalignment','center','string','Set Mouse Precision');

        % Set up Precision frame
        uicontrol(w_config, 'style','frame','units','norm','backgroundcolor',frame_color,'pos', [ .05 .05 .45 .15]);

        % Set up Precision Text        
        uicontrol(w_config,'style','text','units','norm','pos', [ .06 .10 .44 .10],...
                       'backgroundcolor',frame_color,...
                       'foregroundcolor',[1 1 1],...
                       'horizontalalignment','left','string','Accuracy:');
                         

        % Set up Main window frame
        uicontrol(w_config, 'style','frame','units','norm','backgroundcolor',frame_color,'pos', [ .55 .80 .45 .20]);

        % Set up Add Title Text        
        uicontrol(w_config,'style','text','units','norm','pos', [ .55 .81 .44 .18],...
                       'backgroundcolor',frame_color,...
                       'foregroundcolor',[1 1 1],...
                       'horizontalalignment','center','string','Main Window Size');


        % Set up main window size frame
        uicontrol(w_config, 'style','frame','units','norm','backgroundcolor',frame_color,'pos', [ .55 .60 .45 .20]);

        uicontrol('style','checkbox','units','normal', ...
                         'string','Super Small', ...
                         'pos',[0.56 0.80 0.44 0.20],...
                         'val',mirror_x,'fore',[1 1 1],'back',frame_color,...
                         'call',' ');

        uicontrol('style','checkbox','units','normal', ...
                         'string','Small', ...
                         'pos',[0.56 0.71 0.44 0.10],...
                         'val',mirror_y,'fore',[1 1 1],'back',frame_color,...
                         'call',' ');

        uicontrol('style','checkbox','units','normal', ...
                         'string','Regular', ...
                         'pos',[0.56 0.61 0.44 0.10],...
                         'val',mirror_y,'fore',[1 1 1],'back',frame_color,...
                         'call',' ');

        
  else  % Our window is still around, bring it up
     figure(w_config);
  end;     




% ================================
%  Handle the Load Default event

elseif strcmp(action,'load_default'),

  if exist('pez_config.mat')

      pez_config('set_config','pez_config.mat');
     
  else
      mirror_x=1;
      mirror_y=0;
      precision=10;
      fr_omega= linspace(-pi,pi,1001);
      frs_omega=linspace(-pi,pi,256);
      plot_theta=linspace(0,2*pi,70);
      % -- Windows stay at normal sizes
  end,      


% ================================
%  Handle the Set Config event

elseif strcmp(action,'set_config'),

      load(config_file_name);
      fr_omega = linspace(-pi,pi,graph_sampling_rate);
      
      if main_size==1
         figure(w_main_win);
         pez8b('size_supersmall');   
      elseif main_size==2
         figure(w_main_win);
         pez8b('size_small');
      end,
      
      if plots_size==1
         figure(w_main_win);
         pez8b('size2_small');   
      elseif plots_size==2
         figure(w_main_win);
         pez8b('size2_large');
      end,
      

% ================================
%  No options, churn out the safety message
else
  sprintf(['This file is an internal configuration procedure for PEZ.\n',...),
           'To run pez, type ''pez''.\n']),
end,
    