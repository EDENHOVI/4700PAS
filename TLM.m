%addpath('/Users/EdenHovi/Desktop/ELEC_4700_Proj/4700PAS/functions.m')

set(0, 'defaultaxesfontsize',20)
set(0, 'DefaultFigureWindowStyle','docked')
set(0, 'Defaultaxeslinewidth',2);
set(0, 'Defaultaxeslinewidth',2)

set(0, 'DefaultFigureWindowStyle', 'docked')

c_c = 299792458;            % m/s TWM speed of light
c_eps_0 = 8.8542149e-12;    % F/m vacuum permitivitty
c_eps_0_cm = c_eps_0/100;   % F/cm
c_mu_0 = 1/c_eps_0/c_c^2;
c_q = 1.60217653e-19;
c_hb = 1.05457266913e-34;           %Dirac constant
c_h =c_hb*2*pi;


RL = 0.9i; % Mirror coefficient parameter (left side/entry side) 
RR = 0.9i; %Mirror coefficient parameter (right side/output side)

beta_r = 80;
beta_i = 8;
beta = ones(size(z))*(beta_r + 1i*beta_i); % gain for the waves beta = beta_r + beta_i
exp_det = exp(-1i*dz*beta); % the exponential factor being multiplied by the original wave to give it gain
                            % if Beta_i is negative there is a gain
                            %beta_r determines phase shift (whether
                            %positive of negative)


InputParasL.E0 = 1e5;
InputParasL.we = 0.5e13;
InputParasL.t0 = 1e-12;
InputParasL.wg = 5e-13;
InputParasL.phi = 0.5;
InputParasR = 4;

n_g = 3.15;
vg = c_c/n_g*1e2;
Lamda = 1550e-9;

plotN = 10;


L = 1000e-6*1e2;
XL = [0,L];
YL = [-InputParasL.E0,InputParasL.E0]; %Changed here

Nz = 100;
dz = L/(Nz-1);
dt = dz/vg;
fsync = dt*vg/dz;

Nt = floor(8*Nz);
tmax = Nt*dt;
t_L = dt*Nz;        %time to travel length

z = linspace(0,L,Nz).';      %Nz points, Nz-1 segments
time = nan(1,Nt);
InputL = nan(1,Nt);
InputR = nan(1,Nt);
OutputL = nan(1,Nt);
OutputR = nan(1,Nt);

Ef = zeros(size(z));
Er = zeros(size(z));

Ef1 = @SourceFct;
ErN = @SourceFct;

t = 0;
time(1) = t;

InputL(1) = Ef1(t, InputParasL);
InputR(1) = ErN(t, InputParasR);

OutputR(1) = Ef(Nz);
OutputL(1)= Er(1);

Ef(1) = InputL(1);

Er(Nz)= InputR(1);





figure('name', 'Fields')
subplot(3,1,1)
plot(z*10000, real(Ef), 'r');
hold off
xlabel('z(\mum)')
ylabel('E_f')
subplot(3,1,2)
plot(z*10000,real(Er), 'b');
xlabel('z(\mum)')
ylabel('E_r')
hold off
subplot(3,1,3)
plot(time*1e12, real(InputL), 'r'); hold on
plot(time*1e12, real(OutputR), 'r--');
plot(time*1e12,real(InputR), 'b'); hold on
plot (time*1e12,real(OutputL), 'b');
xlabel('time(ps)')
ylabel('E')
hold off

for i = 2:Nt
    t = dt*(i-1);
    time(i) = t;

    InputL(i) = Ef1(t, InputParasL);
    InputR(i) = ErN(t,InputParasR); 

    %Ef(1) = InputL(i); %for simulating forward field without reflections
    %Er(Nz) = InputR(i); %for simulating reverse field without reflections

    Er(Nz) = InputR(i) + RR*Ef(Nz); % this is for the reverse fieldhaving the same number of iterations as the loop
                                    % but with reverse wave summing
                                    % to the initial forward travelling
                                    % wave

    Ef(1)= InputL(i) + RL*Er(1); % this if for the forward field having the same number of iterations as the loop
                                 % but with forward wave basially summing
                                 % with the previous reverse travelling
                                 % wave

    %Ef(2:Nz) = fsync*Ef(1:Nz-1); %normal forward without gain
    %Er(1:Nz-1) = fsync*Er(2:Nz); %normal reverse wave without gain


    Ef(2:Nz) = fsync*exp_det(1:Nz-1).*Ef(1:Nz-1); %normal forward with gain
    Er(1:Nz-1)= fsync* exp_det(2:Nz).*Er(2:Nz);%normal forward without gain


    %OutputR(i) = Ef(Nz);      %for plotting simulated forward field once

    OutputR(i) = Ef(Nz)*(1-RR);% this is for plotting the reverse fieldhaving the same number of iterations as the loop
                               % but with reverse wave summing
                               % to the initial forward travelling
                               % wave

    OutputL(i) = Er(1)*(1-RL); % this if for plotting the forward field having the same number of iterations as the loop
                                 % but with forward wave basially summing
                                 % with the previous reverse travelling
                                 % wave

    %OutputL(i) = Er(1);      %for plotting simulated reversed field once


    if mod(i,plotN) == 0
        subplot(3,1,1)
        plot(z*10000, real(Ef), 'r'); hold on
        plot(z*10000, imag(Ef), 'r--'); hold off
        xlim(XL*1e4)
        ylim(YL)
        xlabel('z(\mum)')
        ylabel('E_f')
        legend('\Re','\Im')
        hold off
        subplot(3,1,2)
        plot(z*10000, real(Er),'b'); hold on
        plot(z*10000,imag(Er),'b--'); hold off
        xlim(XL*1e4)
        ylim(YL)
        xlabel('z(\mum)')
        ylabel('E_r')
        legend('\Re', '\Im')
    
    
        hold off 
        subplot(3,1,3)
        plot(time*1e12,real(InputL), 'r'); hold on
        plot(time*1e12, real(OutputR), 'g')
        plot(time*1e12, real(InputR), 'b')
        plot(time*1e12, real(OutputL), 'm');
        xlim([0,Nt*dt*1e12])
        ylim(YL)
        xlabel('time(ps)')
        ylabel('0')
        legend('Left Input', 'Right Output', 'Right Input', 'Left Output', 'Location', 'east')
        hold off

        %fftOutput= fftshift(fft(OutputR));
        %omega = fftshift(wspace(time));
        %plot(abs(fftOutput))
        pause(0.01)
        %hold off
    end
    
end

%SourceFct
