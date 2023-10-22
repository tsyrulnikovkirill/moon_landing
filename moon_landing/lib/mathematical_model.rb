require_relative 'constants'

### Вспомогательные уравнения ###

# Проекции ускорения
def current_g_x (x, y)
    - (NU_MOON * x) / ((x ** 2 + (R_MOON + y) ** 2) ** 1.5)
end

def current_g_y (x, y)
    - (NU_MOON * (y + R_MOON)) / ((x ** 2 + (R_MOON + y) ** 2) ** 1.5)
end

# Угол тангажа !!! можно поменять входные данные, чтоб их не было
# !!!!!!!!!!!!!! поменял первый кейс
def pitch (t, t1, t2, t_end, d_pitch_dt, pitch_2)
    case t
    when (0..T_VERTICAL)
        Math::PI / 2
    when (T_VERTICAL..t1)
        Math::PI / 2 + d_pitch_dt * (t - T_VERTICAL)
    when (t2..t_end)
        pitch_2
    else
        0
    end
end

def do_thrust(t)
    case t
    when (0..T_1)
        THRUST_1
    when (T_2..T_END)
        THRUST_1
    else
        0
    end
end

# Угол наклона траектории
def tetta (x, y, v_x, v_y)
    velocity = (v_x ** 2 + v_y ** 2) ** 0.5
    r = (x ** 2 + (y + R_MOON) ** 2) ** 0.5

    Math.asin((x * v_x + (y + R_MOON) * v_y) / (r * velocity))
end

# Текущая масса - надо поменять, убрав константы времени
# массу лучше интегрировать (как часть вектора состояяния)
def dm_dt(t)
    dm = - THRUST_1 / W_EFF
    case t
    when (T_0..T_1)
        MASS_0 + dm * t
    when (T_1..T_2)
        MASS_0 + dm * T_1
    when (T_2..T_END)
        MASS_0 + dm * (T_1 + t)
    else    
        1   # заглушка
    end
end


### Уравнения движения ###

def dv_x_dt(pitch_angle, x, y, t)
    do_thrust(t) / dm_dt(t) * Math.cos(pitch_angle) + current_g_x(x, y)
end

def dv_y_dt(pitch_angle, x, y, t)
    do_thrust(t) / dm_dt(t) * Math.sin(pitch_angle) + current_g_y(x, y)
end

def dx_dt(velocity_x)
    velocity_x
end

def dy_dt(velocity_y)
    velocity_y
end


### Граничные условия ###

# !!! менять в зависимости от варианта тяги
R_BOUND = R_MOON + H_AMS_1_1

V_BOUND = (NU_MOON / R_BOUND) ** 0.5

TETTA_BOUND = 0

# Вывод параметров в Excel
def issue_parameters(t, v_x, v_y, x, y, pitch_angle)
    alpha = degrees(pitch_angle) - degrees(tetta(x, y, v_x, v_y))

    [
        t, dm_dt(t), v_x.round(6), v_y.round(6), (x / 1000).round(6), (y / 1000).round(6),
        ((y + R_MOON) / 1000).round(6), ((v_x ** 2 + v_y ** 2) ** 0.5).round(6), (((x ** 2 + (y + R_MOON) ** 2) ** 0.5) / 1000).round(6),
        degrees(pitch_angle).round(6), degrees(tetta(x, y, v_x, v_y)).round(6), alpha.round(6), do_thrust(t)
    ]
end

# puts DELTA_T - (t + dt % DELTA_T).round(4) % DELTA_T

