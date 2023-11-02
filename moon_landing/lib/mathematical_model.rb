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
    if t <= T_VERTICAL
        return Math::PI / 2
    elsif t <= t1
        return Math::PI / 2 + d_pitch_dt * (t - T_VERTICAL)
    elsif t < t2
        return Math::PI / 2 + d_pitch_dt * (t1 - T_VERTICAL)
    elsif t >= t2
        return pitch_2
    end
end

def do_thrust(t)
    if t <= T_1
        return THRUST_1
    elsif (t <= T_2) and (t > T_1)
        return 0
    elsif t > T_2
        return THRUST_1
    end
end

# Угол наклона траектории
def tetta (x, y, v_x, v_y)
    vel = velocity(v_x, v_y)
    r = (x ** 2 + (y + R_MOON) ** 2) ** 0.5

    Math.asin((x * v_x + (y + R_MOON) * v_y) / (r * vel))
end

def velocity(v_x, v_y)
    (v_x ** 2 + v_y ** 2) ** 0.5
end

# Текущая масса - надо поменять, убрав константы времени
# массу лучше интегрировать (как часть вектора состояяния)
def dm_dt(thrust)
    - 1 * thrust / W_EFF
end


### Уравнения движения ###

def dv_x_dt(thrust, m, pitch_angle, x, y, t)
    thrust / m * Math.cos(pitch_angle) + current_g_x(x, y)
end

def dv_y_dt(thrust, m, pitch_angle, x, y, t)
    # puts thrust, dm_dt(thrust), pitch_angle, current_g_y(x, y)
    thrust / m * Math.sin(pitch_angle) + current_g_y(x, y)
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
def issue_parameters(t, v_x, v_y, x, y, m, pitch_angle)
    alpha = degrees(pitch_angle) - degrees(tetta(x, y, v_x, v_y))

    [
        t, m, v_x.round(6), v_y.round(6), (x).round(6), (y).round(6),
        ((y + R_MOON) / 1000).round(6), (velocity(v_x, v_y)).round(6), (((x ** 2 + (y + R_MOON) ** 2) ** 0.5) / 1000).round(6),
        degrees(pitch_angle).round(6), degrees(tetta(x, y, v_x, v_y)).round(6), alpha.round(6), do_thrust(t)
    ]
end


