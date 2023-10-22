require_relative 'lib/mathematical_model'
require_relative 'lib/integration_method'
require_relative 'lib/excel_data'
require_relative 'lib/constants'


excel = ExcelData.new()

# Вставляем НУ
parameters = issue_parameters(T_0, V_X_0, V_Y_0, X_0, Y_0, pitch(T_0, T_1, T_2, T_END, D_PITCH_DT, PITCH_2))
excel.create_line(parameters)

# Первый участок
flight_parameters = [V_X_0, V_Y_0, X_0, Y_0]

flight_parameters = runge_kutta(flight_parameters, T_0, T_1, excel) 

# Второй участок
flight_parameters = runge_kutta(flight_parameters, T_1, T_2, excel)

# Третий участок
# flight_parameters = runge_kutta(flight_parameters, T_2, T_END, excel)

excel.create_sheet("_res_")
excel.clean
excel.save


# в конце траектории задробить шаг и остановиться четко по высоте (до 10^(-8)) - тогда получу адекватное значение производной тангажа
# внимание на отсечку тяги
# подумать, что лучше выбрать для краевого условия: скорость или радиус (какая-то из них удобнее)

# все, что выше упаковать в одну функцию

# выход: значения невязок (угла, скорости) + значение массы топлива
# вход: все, что влияет на выход - угол тангажа2 + производная тангажа


# потом составление краевой задачи
# для уточнения параметров входа - матрица якоби
# берем тангаж с точкой - добавляем дельту (не слишком маленькую)
# возвращаю значение - добавляю дельту к другой переменной
# по этим двум считаю разделенную разницу (центральную разницу) - получаю новые величины 
