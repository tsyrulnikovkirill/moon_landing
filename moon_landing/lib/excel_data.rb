#TODO: @tsyrulnikovkirill

require 'axlsx'
# require 'rubyXL'

class ExcelData

  def initialize
    @p = Axlsx::Package.new
    @wb = @p.workbook
    @lines = []
  end

  def head_text(sheet)
    sheet.add_row ['t, с', 'm, кг' ,'v_x, м/с', 'v_y, м/с', 'x, км', 'y, м', 'h, км', 'V, м/с', 'r, км', 'ϑ, град','θ_c, град', 'α, град', 'ϕ, град']
  end

  def create_line(parameters)
    @lines << parameters
  end

  def create_sheet(sheet_name)
    @wb.add_worksheet(:name => sheet_name) do |sheet|
      head_text(sheet)
      @lines.each do |line|
        sheet.add_row(line)
      end
    end
  end

  def clean
    @lines = []
  end

  def save
    @p.serialize 'data/_Результаты расчета_.xlsx'
  end

end
