require 'prawn'

class PayslipPdfGenerator
  include Prawn::View
  include ActionView::Helpers::NumberHelper
  WARNING_TEXT = 'Peringatan! dokumen ini bersifat rahasia dan tidak boleh disebarluaskan dan hanya boleh dilihat oleh pemilik slip gaji dan pemilik perusahaan. Bagi yang melanggar akan dikenakan sanksi dan dituntut sesuai UU ITE yang berlaku.'.freeze
  FONT_FAMILY = 'Times-Roman'.freeze
  def self.run!(payslip, options={})
    self.new(payslip).generate(options)
  end

  def initialize(payslip)
    @payslip = payslip
    @payslip_lines = payslip.payslip_lines.includes(:payroll_type).to_a.sort_by{|line|line.payroll_type.try(:order) || 9999}
  end

  def generate(options = {})
    file_path = options[:file_path] || TempFile.new(['Slip gaji','.pdf']).path
    file_margin = options[:file_margin] || 30
    file_size = options[:file_size] || 'A4'
    @document = Prawn::Document.new(page_size: file_size, margin: file_margin)
    font FONT_FAMILY
    define_grid(rows: 9, columns: 7, gutter: 10)
    add_permission
    add_header
    add_body
    save_as(file_path)
  end

  private

  def add_permission
    encrypt_document(
      # user_password: @payslip.employee.,
      owner_password: :random,
      permissions: {
        print_document: false,
        modify_contents: false,
        copy_contents: false,
        modify_annotations: false,
      },
    )
  end

  def add_header
    grid([0,0],[0,5]).bounding_box do
      text "Slip Gaji",align: :center, size: 22
      text WARNING_TEXT, size: 12,color: 'FF0000'
      stroke { line [0, 0], [550, 0] }
    end
  end

  def add_body
    font FONT_FAMILY, style: :bold do
      grid([1,0],[4,1]).bounding_box do
        text 'Periode'
        text 'Nama Karyawan'
        text 'Hari Kerja'
        text 'Total Kerja'
        text 'Lembur'
        text 'Telat'
        text 'Sakit'
        text 'Izin'
        text 'Alpha(Tanpa Kabar)'
        @payslip_lines.each do |payslip_line|
          text(payslip_line.payroll_type.try(:name) || payslip_line.description)
        end
        text 'Total Gaji Bersih'
        text 'Keterangan'
      end
    end
    grid([1,2],[4,6]).bounding_box do
      text ": #{date_format(@payslip.start_date)} - #{date_format(@payslip.end_date)}"
      move_down 0.5
      text ": #{@payslip.employee.name}"
      move_down 0.5
      text ": #{@payslip.work_days}"
      move_down 0.5
      text ": #{@payslip.total_day}"
      move_down 0.5
      text ": #{@payslip.overtime_hour}"
      move_down 0.5
      text ": #{@payslip.late}"
      move_down 0.5
      text ": #{@payslip.sick_leave}"
      move_down 0.5
      text ": #{@payslip.known_absence}"
      move_down 0.5
      text ": #{@payslip.unknown_absence}"
      @payslip_lines.each do |payslip_line|
        text ": #{money_format(payslip_line.amount)}",color: payslip_line.earning? ? '000000': 'FF0000'
        move_down 0.5
      end
      text ": #{money_format(@payslip.nett_salary)}"
      move_down 0.5
      text ": #{@payslip.notes}"
    end
  end

  def money_format(number)
    number_to_currency(number, unit: 'Rp ', separator: ',', delimiter: '.')
  end

  def date_format(date)
    date.strftime('%d/%m/%y')
  end
end
