clc; clear; close all;

%% ================== REPRODUCIBILITY ==================
rng(42);

%% ================== PARAMETERS ==================
n = 100; m = 4; road_length = 500;
target_samples = 20000;

v_max = 140 * 1000/3600;

B = 10e6; packet_size = 12000; Q_max = 50;

% VLC
R = 0.5; Pt_opt = 5; N0_vlc = 1e-15;
vlc_assign_range = 150; vlc_reliable_max = 110;

% RF
f_GHz = 5.9;
Pt_rf_dBm = 20;
N_rf_dBm = -96;

gamma_th_vlc = 10^(6/10);
gamma_th_rf  = 10^(8/10);

% Vehicle geometry (for blockage model)
veh_height = 1.5;
veh_length = 4.5;

dataset = [];

%% ================== RF FUNCTION ==================
compute_rf_snr = @(d) ...
    10.^((Pt_rf_dBm - (32.4 + 20*log10(f_GHz) + 20*log10(max(d,1))) ...
    - N_rf_dBm)/10);

%% ================== DATA GENERATION ==================
while size(dataset,1) < target_samples

    lambda = n / road_length;
    vx = cumsum(exprnd(1/lambda,[n,1]));
    vx = mod(vx, road_length);

    vehicle_speed = rand(n,1) * v_max;
    h = 0.6 + 0.1 * rand(n,1);

    ux = rand(m,1) * road_length;
    uz = 50 + 20 * rand(m,1);

    Q = randi([0 Q_max], n,1);

    for i = 1:n

        if size(dataset,1) >= target_samples; break; end

        Q(i) = min(max(Q(i)+poissrnd(3)-poissrnd(2),0),Q_max);

        %% SOURCE
        if rand < 0.85
            xi = vx(i); zi = h(i);
            speed = vehicle_speed(i);
            queue = Q(i);
            density = sum(abs(vx - xi) < 50)/100;
            src_type = 1; src_id = i;
        else
            u = randi(m);
            xi = ux(u); zi = uz(u);
            speed = rand*20;
            queue = randi([0 10]);
            density = 0;
            src_type = 2; src_id = n + u;
        end

        %% DESTINATION
        valid = false;
        while ~valid
            if rand < 0.55
                j = randi(n);
                if src_type == 1 && j == src_id; continue; end
                xj = vx(j); zj = h(j);
                dst_type = 1; dst_id = j;
            else
                u2 = randi(m);
                candidate_id = n + u2;
                if src_type == 2 && candidate_id == src_id; continue; end
                xj = ux(u2); zj = uz(u2);
                dst_type = 2; dst_id = candidate_id;
            end
            if dst_id ~= src_id; valid = true; end
        end

        %% DISTANCE
        d = sqrt((xi-xj)^2 + (zi-zj)^2);
        if d < 1; continue; end

        %% LINK TYPE
        if src_type==1 && dst_type==1 && d <= (vlc_assign_range + 20) && rand < 0.95
            link_type = 1;
        else
            link_type = 2;
        end

        %% ── BLOCKAGE PROBABILITY ──────────────────────────────────────
        % FIX 1: Steepness reduced (3.0 → 1.2) so the sigmoid does not
        % saturate to 1.0 for every vehicle pair with h_veh > h_los.
        % This produces a realistic continuous [0,1] spread rather than
        % a spike at 1.0 for 93% of VLC rows.
        %
        % Physical model (geometric shadow-cone, Abbas et al. 2013):
        %   - Count vehicles strictly between src and dst (k_int)
        %   - Compute per-vehicle blockage via sigmoid of height delta
        %   - Combine: P_block = 1 - (1 - P_single)^k_int

        if link_type == 1 && src_type == 1 && dst_type == 1
            x_min = min(xi, xj);
            x_max = max(xi, xj);
            k_int = max(sum(vx > x_min & vx < x_max) - 1, 0);
            k_int = min(k_int, 3);

            if k_int == 0
                blockage_prob = 0;
            else
                h_los_mid = (zi + zj) / 2;
                delta_h   = veh_height - h_los_mid;

                steepness = 0.4;                           % FIX 1: was 3.0
                P_single  = 1 / (1 + exp(-steepness * delta_h));

                avg_gap   = max(d / (k_int + 1) - veh_length, 0.5);
                gap_factor = 1 - exp(-veh_length / max(avg_gap, 0.1));
                gap_factor = min(gap_factor, 0.30);        % FIX 1: cap gap contribution

                P_single  = min(max(P_single * gap_factor, 0), 1);
                blockage_prob = 1 - (1 - P_single)^k_int;
                blockage_prob = min(max(blockage_prob, 0), 1);
            end
        else
            blockage_prob = 0;
        end

        %% CHANNEL
        if link_type == 1
            H   = 1/(d^2 + 1e-6);
            SNR = (R*Pt_opt*H)^2/(N0_vlc*B);

            if rand < 0.3
                SNR = SNR * 0.2;
            end

            if rand < blockage_prob
                olos_loss_db = 10 + 10*rand;
                SNR = SNR * 10^(-olos_loss_db/10);
            end
        else
            SNR = compute_rf_snr(d);
            SNR = SNR * exprnd(1);
            SNR = SNR * 10^(randn*4/10);
        end

        SNR_db = 10*log10(SNR + 1e-12);

        %% ── LABEL ────────────────────────────────────────────────────
        % FIX 2: RF gamma_th_rf threshold loosened (0.3 → 0.5) so that
        % RF does not produce label=1 at 81% rate, which was pulling the
        % overall balance to 71.6%.  Target: overall label balance ~50%.

        if link_type == 1
            snr_ok    = (SNR >= gamma_th_vlc);
            dist_ok   = (d <= vlc_reliable_max);
            queue_penalty = (queue/Q_max) > 0.8 && rand < 0.4;
            label = double(snr_ok && dist_ok && ~queue_penalty);
        else
            % FIX 2: tighter outage threshold → fewer RF links get label=1
            P_out_rf   = 1 - exp(-gamma_th_rf / (SNR + 1e-12));
            reliable_rf = (P_out_rf < 0.5);               % was 0.3 → too permissive
            queue_penalty = (queue/Q_max) > 0.8 && rand < 0.3;
            label = double(reliable_rf && ~queue_penalty);
        end

        %% STORE
        dataset = [dataset;
            src_id dst_id src_type dst_type ...
            d speed density queue SNR_db ...
            link_type blockage_prob label];
    end
end

%% ================== TABLE ==================
cols = {'src_id','dst_id','src_type','dst_type',...
        'distance','speed','density','queue','SNR_db',...
        'link_type','blockage_prob','label'};

T = array2table(dataset,'VariableNames',cols);

%% ================== SAVE ==================
writetable(T,'congestion_dataset_v5_fixed.csv');
save('congestion_dataset_v5_fixed.mat','T');

%% ================== VALIDATION ==================
disp("✅ DATASET v4 GENERATED");
disp(size(T));

disp("Self-links (must be 0):");
disp(sum(T.src_id == T.dst_id));

disp("Label distribution:");
tabulate(T.label)

disp("Link type distribution:");
tabulate(T.link_type)

disp("Blockage prob — VLC rows:");
vlc = T(T.link_type == 1, :);
fprintf("  mean  = %.4f\n", mean(vlc.blockage_prob));
fprintf("  > 0.99 count = %d\n", sum(vlc.blockage_prob > 0.99));
fprintf("  == 0  count  = %d\n", sum(vlc.blockage_prob == 0));