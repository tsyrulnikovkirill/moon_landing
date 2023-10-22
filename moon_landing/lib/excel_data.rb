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
    sheet.add_row ['t, с', 'm, кг' ,'v_x, м/с', 'v_y, м/с', 'x, км', 'y, км', 'h, км', 'V, м/с', 'r, км', 'ϑ, град','θ_c, град', 'α, град', 'ϕ, град']
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

  def last_row
    # @wb.worksheets.each do |sheet|
    #   puts "Reading: #{sheet.sheet_name}"
    #   sheet.rows.last
    # end

    @wb.defined_names
  end

  # def last_row
  #   workbook = RubyXL::Parser.parse 'data/_Результаты расчета_.xlsx'
  #   worksheets = workbook.worksheets

  #   worksheets.each do |worksheet|
  #     puts "Reading: #{worksheet.sheet_name}"
  #     num_rows = 0
  #     worksheet.each do |row|
  #       row_cells = row.cells.map{ |cell| cell.value }
  #       num_rows += 1
  #     end
  #     puts "Read #{num_rows} rows"
  #   end

  # end
  
end
