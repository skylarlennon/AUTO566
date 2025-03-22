classdef Motor
    % Class for BLDC Motor

    properties
        K_t (1, 1) double = 1; % Torque Constant
        alpha_Kt (1, 1) double = 0;
        K_e (1, 1) double = 1; % Back-emf Constant
        alpha_Ke (1, 1) double = 0;
        I_stall (1, 1) double = 300; % Stall Current
        r (1, 1) double {mustBePositive} = 0.2; % Phase resistance of motor
        alpha_r (1, 1) double = 0; % Resistance M_terature Coefficient
        lambda_ec (1, 1) double = 0; % Eddy Current Loss Coefficient
        alpha_ec (1, 1) double = 0; % Eddy Current Loss M_terature Coefficient
        hys (1, 1) double = 0; % Hysteresis
        alpha_hys (1, 1) double = 0; % Hysteresis M_terature coefficient
        STC = 23;
        M_t (1, 1) double {mustBePositive} = 23;
    end

    methods
        function obj = Motor(kt, ke, Is, Ra_t, hy, l_ec, alpha_kt,  alpha_ke, alpha_r, alpha_hy,  alpha_ec, T_init)
            % Construct an instance of Motor class
            %   Detailed explanation goes here
            %   Default Values are 
            %   kt Nm/Arms
            %   kw 1Vrms/(1rad/s)
            %   Is = 300 A
            %   hys = 0;
            %   ec = 0;
            %   All M_terature coefficients initialized to 0 unless
            %   specified.
            obj.K_t = kt;
            obj.K_e = ke;
            obj.I_stall = Is;
            obj.r = Ra_t;
            obj.hys = hy;
            obj.lambda_ec = l_ec;
            obj.alpha_Kt = alpha_kt;
            obj.alpha_Ke = alpha_ke;
            obj.alpha_r = alpha_r;
            obj.alpha_hys = alpha_hy;
            obj.alpha_ec = alpha_ec;
            obj.M_t = T_init;
        end

        function [P_l, P_lr, P_lh, P_lec] = Get_Power_Loss(obj, tau, omega, ambient)
            % Motor Power Loss at certain torque, speed, and M_terature
            
            P_lr = get_power_loss_resistive(obj, tau);
            P_lh = get_power_loss_hysteresis(obj);
            P_lec = get_power_loss_eddy(obj, omega);
            P_l = P_lr + P_lh + P_lec;
        end
        function [P_lr] = get_power_loss_resistive(obj, tau)
            % Calculate Phase current required for torque
            K_t_at_temp = obj.K_t + obj.alpha_Kt.*(obj.M_t - obj.STC);
            R_eq_at_temp = obj.r + obj.alpha_r.*(obj.M_t - obj.STC);
            I_p = tau./K_t_at_temp/sqrt(2);
            if(I_p > obj.I_stall)
                P_lr = 3*obj.I_stall.^2.*R_eq_at_temp;
            else
                P_lr = 3*I_p.^2.*R_eq_at_temp;
            end
        end
        function [P_lh] = get_power_loss_hysteresis(obj)
            P_lh = obj.hys + obj.alpha_hys.*(obj.M_t - obj.STC);
        end
        function [P_lec] = get_power_loss_eddy(obj, omega)
            P_lec = obj.lambda_ec.*(1 + obj.alpha_ec.*(obj.M_t - obj.STC).*omega);
        end
        %function [M_t] = change_motor_M_t(obj, amb)
            % Apply Newton's law of cooling to motor given rotation
            % velocity, power loss, and 
        %end
    end
end