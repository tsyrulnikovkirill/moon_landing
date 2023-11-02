require_relative 'constants'
require_relative 'mathematical_model'

def runge_kutta_old(arr_parameters, t, t_end, d_pitch_dt, pitch_2, excel)
    
    v_x_old = arr_parameters[0]
    v_y_old = arr_parameters[1]
    x_old = arr_parameters[2]
    y_old = arr_parameters[3]
    m_old = arr_parameters[4]

    thrust = THRUST_1 #!!!!!
    h_orbit = H_AMS_1_1

    dt = DELTA_T

    # правая граница отсечки тяги
    if ((t + dt % DELTA_T).round(4) % DELTA_T).round(4) != 0.0
        dt = (DELTA_T - (t + dt % DELTA_T).round(4) % DELTA_T).round(4)
    end

    while t < t_end
        
        # левая граница отсечки тяги
        if t + dt > t_end
            dt = t_end - t
        end

        if (y_old - h_orbit).abs < 10 ** (-7) 
            break
        end

        pitch_angle = pitch(t, T_1, T_2, T_END, D_PITCH_DT, PITCH_2)

        pitch_angle = pitch(t, T_1, T_2, T_END, D_PITCH_DT, PITCH_2)
        k_v_x_1 = dt * dv_x_dt(do_thrust(t), pitch_angle, x_old, y_old, t)
        k_v_y_1 = dt * dv_y_dt(do_thrust(t), pitch_angle, x_old, y_old, t)
        # if t in 81..83
        #     puts (t) 
        #     puts (k_v_y_1)
        #     puts
        # end
        k_x_1 = dt * dx_dt(v_x_old)
        k_y_1 = dt * dy_dt(v_y_old)
        k_m_1 = dt * dm_dt(do_thrust(t))


        pitch_angle = pitch(t + dt / 2, T_1, T_2, T_END, D_PITCH_DT, PITCH_2)
        k_v_x_2 = dt * dv_x_dt(do_thrust(t), pitch_angle, x_old + k_x_1 / 2, y_old + k_y_1 / 2, t + dt / 2)
        k_v_y_2 = dt * dv_y_dt(do_thrust(t), pitch_angle, x_old + k_x_1 / 2, y_old + k_y_1 / 2, t + dt / 2)
        k_x_2 = dt * dx_dt(v_x_old + k_v_x_1 / 2)
        k_y_2 = dt * dy_dt(v_y_old + k_v_y_1 / 2)
        k_m_2 = dt * dm_dt(do_thrust(t))


        pitch_angle = pitch(t + dt / 2, T_1, T_2, T_END, D_PITCH_DT, PITCH_2)
        k_v_x_3 = dt * dv_x_dt(do_thrust(t), pitch_angle, x_old + k_x_2 / 2, y_old + k_y_2 / 2, t + dt / 2)
        k_v_y_3 = dt * dv_y_dt(do_thrust(t), pitch_angle, x_old + k_x_2 / 2, y_old + k_y_2 / 2, t + dt / 2)
        k_x_3 = dt * dx_dt(v_x_old + k_v_x_2 / 2)
        k_y_3 = dt * dy_dt(v_y_old + k_v_y_2 / 2)
        k_m_3 = dt * dm_dt(do_thrust(t))


        pitch_angle = pitch(t + dt, T_1, T_2, T_END, D_PITCH_DT, PITCH_2)
        k_v_x_4 = dt * dv_x_dt(do_thrust(t), pitch_angle, x_old + k_x_3, y_old + k_y_3, t + dt)
        k_v_y_4 = dt * dv_y_dt(do_thrust(t), pitch_angle, x_old + k_x_3, y_old + k_y_3, t + dt)
        k_x_4 = dt * dx_dt(v_x_old + k_v_x_3)
        k_y_4 = dt * dy_dt(v_y_old + k_v_y_3)
        k_m_4 = dt * dm_dt(do_thrust(t))


        v_x_new = v_x_old + (k_v_x_1 + 2 * k_v_x_2 + 2 * k_v_x_3 + k_v_x_4) / 6
        v_y_new = v_y_old + (k_v_y_1 + 2 * k_v_y_2 + 2 * k_v_y_3 + k_v_y_4) / 6
        x_new = x_old + (k_x_1 + 2 * k_x_2 + 2 * k_x_3 + k_x_4) / 6
        y_new = y_old + (k_y_1 + 2 * k_y_2 + 2 * k_y_3 + k_y_4) / 6
        m_new = m_old + (k_m_1 + 2 * k_m_2 + 2 * k_m_3 + k_m_4) / 6




        if y_new > h_orbit
            dt = dt * 0.5
        else
            v_x_old = v_x_new
            v_y_old = v_y_new
            x_old = x_new
            y_old = y_new
            m_old = m_new

            t += dt
            t = t.round(6)
            dt = DELTA_T
    
            # if t % 0.5 == 0.0 or t == t_end
                parameters = issue_parameters(t, v_x_old, v_y_old, x_old, y_old, m_old, pitch_angle)
                excel.create_line(parameters)
            # end
        end

        
    end

    return [v_x_old, v_y_old, x_old, y_old, m_old, t, parameters]
end
