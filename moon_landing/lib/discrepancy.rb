require_relative 'mathematical_model'
require_relative 'integration_method_old'
require_relative 'excel_data'
require_relative 'constants'


def discrepancy (d_pitch_dt, pitch_2, excel)
    
    # Вставляем НУ
    parameters = issue_parameters(T_0, V_X_0, V_Y_0, X_0, Y_0, MASS_0, pitch(T_0, T_1, T_2, T_END, d_pitch_dt, pitch_2))
    excel.create_line(parameters)
    
    # Первый участок
    flight_parameters = [V_X_0, V_Y_0, X_0, Y_0, MASS_0]
    
    flight_parameters = runge_kutta_old(flight_parameters, T_0, T_1, d_pitch_dt, pitch_2, excel) 
    
    # Второй участок
    flight_parameters = runge_kutta_old(flight_parameters, T_1, T_2, d_pitch_dt, pitch_2, excel)
    
    # Третий участок
    flight_parameters = runge_kutta_old(flight_parameters, T_2, T_END, d_pitch_dt, pitch_2, excel)
    
       
    
end