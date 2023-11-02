require_relative 'constants'
require_relative 'mathematical_model'


def runge_kutta(arr_parameters, t, dt)

    v_x_old = arr_parameters[0]
    v_y_old = arr_parameters[1]
    x_old = arr_parameters[2]
    y_old = arr_parameters[3]
    m_old = arr_parameters[4]


    pitch_angle = pitch(t, T_1, T_2, T_END, D_PITCH_DT, PITCH_2)
    k_v_x_1 = dt * dv_x_dt(do_thrust(t), m_old, pitch_angle, x_old, y_old, t)
    k_v_y_1 = dt * dv_y_dt(do_thrust(t), m_old, pitch_angle, x_old, y_old, t)
    k_x_1 = dt * dx_dt(v_x_old)
    k_y_1 = dt * dy_dt(v_y_old)
    k_m_1 = dt * dm_dt(do_thrust(t))


    pitch_angle = pitch(t + dt / 2, T_1, T_2, T_END, D_PITCH_DT, PITCH_2)
    k_v_x_2 = dt * dv_x_dt(do_thrust(t), m_old + k_m_1 / 2, pitch_angle, x_old + k_x_1 / 2, y_old + k_y_1 / 2, t + dt / 2)
    k_v_y_2 = dt * dv_y_dt(do_thrust(t), m_old + k_m_1 / 2, pitch_angle, x_old + k_x_1 / 2, y_old + k_y_1 / 2, t + dt / 2)
    k_x_2 = dt * dx_dt(v_x_old + k_v_x_1 / 2)
    k_y_2 = dt * dy_dt(v_y_old + k_v_y_1 / 2)
    k_m_2 = dt * dm_dt(do_thrust(t))


    pitch_angle = pitch(t + dt / 2, T_1, T_2, T_END, D_PITCH_DT, PITCH_2)
    k_v_x_3 = dt * dv_x_dt(do_thrust(t), m_old + k_m_2 / 2, pitch_angle, x_old + k_x_2 / 2, y_old + k_y_2 / 2, t + dt / 2)
    k_v_y_3 = dt * dv_y_dt(do_thrust(t), m_old + k_m_2 / 2,pitch_angle, x_old + k_x_2 / 2, y_old + k_y_2 / 2, t + dt / 2)
    k_x_3 = dt * dx_dt(v_x_old + k_v_x_2 / 2)
    k_y_3 = dt * dy_dt(v_y_old + k_v_y_2 / 2)
    k_m_3 = dt * dm_dt(do_thrust(t))


    pitch_angle = pitch(t + dt, T_1, T_2, T_END, D_PITCH_DT, PITCH_2)
    k_v_x_4 = dt * dv_x_dt(do_thrust(t), m_old + k_m_3, pitch_angle, x_old + k_x_3, y_old + k_y_3, t + dt)
    k_v_y_4 = dt * dv_y_dt(do_thrust(t), m_old + k_m_3, pitch_angle, x_old + k_x_3, y_old + k_y_3, t + dt)
    k_x_4 = dt * dx_dt(v_x_old + k_v_x_3)
    k_y_4 = dt * dy_dt(v_y_old + k_v_y_3)
    k_m_4 = dt * dm_dt(do_thrust(t))


    v_x_new = v_x_old + (k_v_x_1 + 2 * k_v_x_2 + 2 * k_v_x_3 + k_v_x_4) / 6
    v_y_new = v_y_old + (k_v_y_1 + 2 * k_v_y_2 + 2 * k_v_y_3 + k_v_y_4) / 6
    x_new = x_old + (k_x_1 + 2 * k_x_2 + 2 * k_x_3 + k_x_4) / 6
    y_new = y_old + (k_y_1 + 2 * k_y_2 + 2 * k_y_3 + k_y_4) / 6
    m_new = m_old + (k_m_1 + 2 * k_m_2 + 2 * k_m_3 + k_m_4) / 6


    [v_x_new, v_y_new, x_new, y_new, m_new, pitch_angle]
end

def print_parameters(parameters, t, excel)
    out_parameters = issue_parameters(t, parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5])
    excel.create_line(out_parameters)
end

def calculate(h_orbit, d_pitch_dt, pitch_2, excel)

    parameters = [V_X_0, V_Y_0, X_0, Y_0, MASS_0, pitch(T_0, T_1, T_2, T_END, d_pitch_dt, pitch_2)]
    dt = DELTA_T
    t = 0
    t_prev = t
    parameters_prev = parameters
    print_parameters(parameters, t, excel)

    while (velocity(parameters[0], parameters[1]) - V_BOUND).abs > 10 ** (-7)
    # (y_old - h_orbit).abs < 10 ** (-7)
    # t < T_END

        if (t + dt > T_1) and (t < T_1)
            dt = T_1 - t
            t += dt

            parameters = runge_kutta(parameters, t, dt)
            print_parameters(parameters, t, excel)

            dt = DELTA_T - dt
            t += dt

            parameters = runge_kutta(parameters, t, dt)
            print_parameters(parameters, t, excel)
            dt = DELTA_T
        end

        if (t + dt > T_2) and (t < T_2)
            dt = T_2 - t
            t += dt

            parameters = runge_kutta(parameters, t, dt)
            print_parameters(parameters, t, excel)

            dt = DELTA_T - dt
            t += dt

            parameters = runge_kutta(parameters, t, dt)
            print_parameters(parameters, t, excel)
            dt = DELTA_T
        end

        parameters_prev = parameters
        t_prev = t
        parameters = runge_kutta(parameters, t, dt)
        t += dt

        if (velocity(parameters[0], parameters[1]) < V_BOUND) and (dt == DELTA_T)
            # (parameters[3] < h_orbit) and (dt == DELTA_T)
            print_parameters(parameters, t, excel)
        end

        if (velocity(parameters[0], parameters[1]) - V_BOUND).abs < 10 ** (-7)
            # (parameters[3] - h_orbit).abs < 10 ** (-7) 
            print_parameters(parameters, t, excel)
        end

        if velocity(parameters[0], parameters[1]) > V_BOUND
            # parameters[3] > h_orbit
            parameters = parameters_prev
            t = t_prev

            parameters_prev = parameters
            t_prev = t
            dt = dt / 10
        end

    end

    parameters
end